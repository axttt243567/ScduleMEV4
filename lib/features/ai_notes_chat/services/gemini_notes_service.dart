import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class NoteContent {
  final String title;
  final String date;
  final String style;
  final List<NoteSection> sections;

  NoteContent({
    required this.title,
    required this.date,
    required this.sections,
    this.style = 'Study Note',
  });

  factory NoteContent.fromJson(Map<String, dynamic> json) {
    return NoteContent(
      title: json['title'] ?? 'Untitled Note',
      date: json['date'] ?? '',
      style: json['style'] ?? 'Study Note',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => NoteSection.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class NoteSection {
  final String heading;
  final String content;
  final String? mermaidCode;

  NoteSection({required this.heading, required this.content, this.mermaidCode});

  factory NoteSection.fromJson(Map<String, dynamic> json) {
    return NoteSection(
      heading: json['heading'] ?? '',
      content: json['content'] ?? '',
      mermaidCode: json['mermaid_code'],
    );
  }
}

class GeminiNotesService {
  final String apiKey;
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiNotesService(this.apiKey) {
    _initializeModel(_primaryModel);
  }

  void _initializeModel(String modelName) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
     // Note: This resets the chat session. If we want to persist history across model switches, 
     // we would need to save `_chat.history` and restore it. 
     // For this panic-fallback, losing recent context is acceptable vs crashing.
    _startNewSession(); 
  }

  // Models to try in order
  static const String _primaryModel = 'gemini-3-flash-preview';
  static const String _fallbackModel = 'gemini-2.0-flash-exp';

  void _startNewSession([String style = 'Classic Sheet']) {
    String styleInstruction = '';
    switch (style) {
      case 'Classic Sheet':
        styleInstruction = 'Create a dense, 2-column style cheat sheet. Be extremely concise. Use **bold** heavily for keywords, formulas, and definitions. Standard academic tone.';
        break;
      case 'Dark Mode':
        styleInstruction = 'Create a cyber/tech-themed cheat sheet. Use short, punchy sentences. Use **bold** for every important term or value. Focus on high-density information.';
        break;
      case 'Creative Sheet':
        styleInstruction = 'Create a visually organized note where sections are distinct topics. Use a friendly but educational tone. Use **bold** to highlight key takeaways.';
        break;
      case 'Research':
        styleInstruction = 'Use a formal academic tone. Include abstract-like summaries, methodology if applicable, and detailed analysis. Use structured sections.';
        break;
      case 'Book':
        styleInstruction = 'Use a narrative, literary tone. Write in paragraphs rather than bullet points where possible. Focus on flow and storytelling.';
        break;
      case 'Poem':
        styleInstruction = 'Write the content as a creative, artistic piece or a series of stanza-like sections if suitable. Focus on beauty and expression.';
        break;
      default:
        styleInstruction = 'Use a structured, educational tone. Use bullet points, clear definitions, and summary tables. Focus on clarity and retention.';
        break;
    }

    _chat = _model.startChat(history: [
      Content.text('''
You are an aesthetic note-taking assistant. Your goal is to generate structured notes based on the user's request.
Internal Instructions:
1. Output MUST be valid JSON.
2. Structure: { "type": "...", "message": "...", "note_content": { ... } }
3. $styleInstruction
4. Escape all special characters for JSON. Do not use single backslashes for LaTeX. Use double backslashes (e.g. \\\\alpha instead of \\alpha).
5. If the user greets you or wants to discuss a topic, return `type: "conversation"` and a helpful `message`.
6. If the user explicitly asks to generate the note, return `type: "note_plan"` with `topic`, `title`, and `style`. Do NOT generate the full content yet.
7. **Diagrams**: You can include Mermaid diagrams. To do so, add a `"mermaid_code"` field to the section object. 
   - Use standard Mermaid syntax (graph TD, pie, sequenceDiagram etc).
   - Keep diagrams simple and readable.
   - Example Section: { "heading": "Flow", "content": "Process flow...", "mermaid_code": "graph TD; A[Start]-->B[End];" }

JSON Format for Note Plan:
{
  "type": "note_plan",
  "topic": "...",
  "title": "...",
  "style": "$style"
}

JSON Format for Conversation:
{
  "type": "conversation",
  "message": "..."
}
'''),
    ]);
  }

  /// Generates a long-form note by first creating an outline and then expanding each section.
  /// [onProgress] callback returns (completedSections, totalSections).
  Future<NoteContent> generateLongNote(String prompt, {
    String style = 'Classic Sheet',
    required Function(int completed, int total) onProgress,
  }) async {
    // 1. Generate Outline
    onProgress(0, 0); // Indeterminate start
    final outlineValues = await _generateOutline(prompt, style);
    final totalSections = outlineValues['sections'].length;
    final noteTitle = outlineValues['title'];
    final noteDate = outlineValues['date'];
    
    // 2. Expand Sections
    List<NoteSection> expandedSections = [];
    for (int i = 0; i < totalSections; i++) {
        final heading = outlineValues['sections'][i];
        
        // Notify progress
        onProgress(i, totalSections);
        
        try {
           final section = await _generateSectionContent(heading, noteTitle, style, i, totalSections);
           expandedSections.add(section);
        } catch (e) {
           print("Failed to generate section $heading: $e");
           // Add a placeholder or brief error note so we don't fail the whole document
           expandedSections.add(NoteSection(
               heading: heading, 
               content: "Error generating content for this section.", 
               mermaidCode: null
           ));
        }
    }
    
    onProgress(totalSections, totalSections); // Done

    return NoteContent(
        title: noteTitle,
        date: noteDate,
        style: style,
        sections: expandedSections
    );
  }

  Future<Map<String, dynamic>> _generateOutline(String topic, String style) async {
      final prompt = '''
      Create a comprehensive outline for a long-form note about: "$topic".
      Style: $style.
      Target length: 15-25 sections.
      
      Output JSON Format:
      {
        "title": "...",
        "date": "...",
        "sections": [ "Heading 1", "Heading 2", ... ]
      }
      ''';
      
      final response = await _chat.sendMessage(Content.text(prompt));
      // Re-use existing parsing logic or simple decode
      final text = response.text!.replaceAll(RegExp(r'```json|```'), '').trim();
      return jsonDecode(text) as Map<String, dynamic>;
  }

  Future<NoteSection> _generateSectionContent(String heading, String title, String style, int index, int total) async {
      final prompt = '''
      Write detailed content for Section ${index + 1}/$total: "$heading" of the note "$title".
      Style: $style.
      
      Instructions:
      1. Write extensive, detailed paragraphs.
      2. Use **bold** for key terms.
      3. If relevant, provide a Mermaid diagram code in `mermaid_code`.
      4. Output strictly valid JSON.
      
      JSON Format:
      {
        "heading": "$heading",
        "content": "...",
        "mermaid_code": "..." (optional)
      }
      ''';
      
      final response = await _chat.sendMessage(Content.text(prompt));
      final text = response.text!; 
      // Reuse clean logic
      final clean = _cleanJson(text);
      return NoteSection.fromJson(jsonDecode(clean));
  }

  Future<Map<String, dynamic>> sendMessage(String prompt, {String style = 'Classic Sheet'}) async {
    // We append the style to the prompt to remind the model, as restarting session clears history
    final fullPrompt = "Style: $style\nUser: $prompt";

    try {
      return await _attemptSendMessage(fullPrompt, _primaryModel);
    } catch (e) {
      print('Primary model failed: $e. Switching to fallback...');
      try {
        _initializeModel(_fallbackModel);
        // We lose history here, but robust fallback is better than crash
        return await _attemptSendMessage(fullPrompt, _fallbackModel);
      } catch (e2) {
        throw Exception('All models failed. Last error: $e2');
      }
    }
  }

  Future<Map<String, dynamic>> _attemptSendMessage(String prompt, String modelName) async {
    final response = await _chat.sendMessage(Content.text(prompt));
    final text = response.text;

    if (text == null) throw Exception('Empty response from AI ($modelName)');

    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (e) {
      print('JSON Decode error: $e. Attempting sanitization...');
      final sanitized = _cleanJson(text);
      try {
        return jsonDecode(sanitized) as Map<String, dynamic>;
      } catch (e2) {
         print('Sanitized JSON failed: $sanitized');
         throw FormatException('Failed to parse note format from $modelName. Error: $e2');
      }
    }
  }

  String _cleanJson(String text) {
    String clean = text.replaceAll(RegExp(r'```json|```'), '').trim();
    // Fix unescaped backslashes not followed by valid escape chars
    clean = clean.replaceAllMapped(RegExp(r'\\(?![\\"/bfnrtu])'), (match) {
        return '\\\\'; 
    });
    return clean;
  }
}
