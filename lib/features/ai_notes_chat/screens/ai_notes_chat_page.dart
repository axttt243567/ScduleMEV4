import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:open_file/open_file.dart';
import 'package:scdulemev4o1/features/ai_notes_chat/services/gemini_notes_service.dart';
import 'package:scdulemev4o1/shared/services/settings_service.dart';
import '../services/pdf_generator_service.dart';

class AiNotesChatPage extends StatefulWidget {
  const AiNotesChatPage({super.key});

  @override
  State<AiNotesChatPage> createState() => _AiNotesChatPageState();
}

class _AiNotesChatPageState extends State<AiNotesChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  // Services
  GeminiNotesService? _geminiService;
  final PdfGeneratorService _pdfService = PdfGeneratorService();
  final SettingsService _settingsService = SettingsService();

  bool _isLoading = false;
  String _progressText = "";
  String? _apiKey;
  String _selectedStyle = 'Classic Sheet';
  final List<String> _styles = ['Classic Sheet', 'Dark Mode', 'Creative Sheet', 'Research', 'Book', 'Poem'];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final key = await _settingsService.getGeminiApiKey();
    setState(() {
      _apiKey = key;
      if (_apiKey != null) {
        _geminiService = GeminiNotesService(_apiKey!);
        _messages.add(ChatMessage(
          isUser: false,
          text: "Hello! I'm your aesthetic notes assistant (Gemini 3.0 Flash Preview).\n\nI'm ready to help you create beautiful handwritten notes. What topic shall we discuss?",
          isSystem: true,
        ));
      } else {
        _messages.add(ChatMessage(
          isUser: false,
          text: "Welcome! To use the AI Notes feature, you need to set up your Gemini API Key in Settings.",
          isSystem: true,
          isError: true,
        ));
      }
    });
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    if (_apiKey == null) {
      setState(() {
         _messages.add(ChatMessage(isUser: true, text: text));
         _messages.add(ChatMessage(
           isUser: false, 
           text: "Please go to Settings > Access & Security to configure your API Key first.", 
           isError: true
         ));
      });
      return;
    }

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(isUser: true, text: text));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Send message to Gemini with selected style
      final response = await _geminiService!.sendMessage(text, style: _selectedStyle);
      
      final type = response['type'] as String?;
      
      if (type == 'note_plan') {
         // INTERCEPTED: Start Long-Form Generation
         final topic = response['topic'] ?? "Unknown Topic";
         final title = response['title'] ?? "Untitled Note";
         final style = response['style'] ?? _selectedStyle;
         
         setState(() {
           _messages.add(ChatMessage(
             isUser: false, 
             text: "Great plan! I'll now research and write a detailed 20+ page note on **$title** ($style). This may take 1-2 minutes...",
             isSystem: true
           ));
           _progressText = "Initializing...";
         });

         final noteContent = await _geminiService!.generateLongNote(topic, style: style, onProgress: (completed, total) {
             setState(() {
                if (total > 0) {
                   _progressText = "Writing Section $completed of $total...";
                } else {
                   _progressText = "Designing Outline...";
                }
             });
             _scrollToBottom();
         });
         
         final pdfFile = await _pdfService.generateHandwrittenPdf(noteContent);

         setState(() {
            _progressText = "";
            _messages.add(ChatMessage(
              isUser: false,
              text: "Done! Here is your comprehensive note on ${noteContent.title}.",
              pdfFile: pdfFile,
            ));
         });

      } else if (type == 'note_generation') {
        // Fallback for short notes (should be rare now with prompt change)
        final noteData = response['note_content'];
        // Ensure style is passed if missing (though we put it in prompt)
        if (noteData['style'] == null) {
             noteData['style'] = _selectedStyle;
        }
        final noteContent = NoteContent.fromJson(noteData);
        
        setState(() {
          _messages.add(ChatMessage(
            isUser: false,
            text: "Perfect! Generating ${_selectedStyle} PDF for \"${noteContent.title}\"...",
            isSystem: true,
          ));
        });

        final pdfFile = await _pdfService.generateHandwrittenPdf(noteContent);
        
        setState(() {
          _messages.add(ChatMessage(
            isUser: false,
            text: "Here is your note on ${noteContent.title}!",
            pdfFile: pdfFile,
          ));
        });
      } else {
        // Handle Conversation
        final message = response['message'] as String? ?? "I'm not sure how to respond, but I'm listening.";
        setState(() {
          _messages.add(ChatMessage(
            isUser: false,
            text: message,
          ));
        });
      }

    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          isUser: false,
          text: "I encountered an error: $e. Please try again.",
          isError: true,
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        title: const Text(
          'Handwritten Notes AI',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_apiKey == null)
            TextButton(
              onPressed: () {
                // Navigate to Settings? Or show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Go to Settings page to configure API Key")),
                );
              },
              child: const Text("Set Key", style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
            if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
                  ),
                  if (_progressText.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Text(_progressText, style: const TextStyle(color: Colors.grey, fontSize: 12))
                  ]
                ],
              ),
            ),
          _buildStyleSelector(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF0A0A0C),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _styles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final style = _styles[index];
          final isSelected = style == _selectedStyle;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStyle = style;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.2) : const Color(0xFF16161E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF27272A),
                ),
              ),
              child: Text(
                style,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF60A5FA) : Colors.grey[400],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isSystem || message.isError) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: message.isError ? Colors.red.withOpacity(0.1) : const Color(0xFF16161E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              fontSize: 12,
              color: message.isError ? Colors.red[300] : Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF3B82F6) : const Color(0xFF16161E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFF27272A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text.isNotEmpty)
              MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: isUser ? Colors.white : Colors.grey[300]),
                ),
              ),
            if (message.pdfFile != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  OpenFile.open(message.pdfFile!.path);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Open PDF Note",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.open_in_new, color: Colors.grey[400], size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0C).withOpacity(0.95),
        border: const Border(top: BorderSide(color: Color(0xFF27272A))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF16161E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleSubmitted(_controller.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final bool isUser;
  final String text;
  final bool isSystem;
  final bool isError;
  final File? pdfFile;

  ChatMessage({
    required this.isUser,
    required this.text,
    this.isSystem = false,
    this.isError = false,
    this.pdfFile,
  });
}
