import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'gemini_notes_service.dart';

class PdfGeneratorService {
  // Cache for texture
  pw.ImageProvider? _cachedTexture;

  Future<File> generateHandwrittenPdf(NoteContent note) async {
    final pdf = pw.Document();

    switch (note.style) {
      case 'Dark Mode':
        await _buildDarkMode(pdf, note);
        break;
      case 'Creative Sheet':
        await _buildCreativeSheet(pdf, note);
        break;
      case 'Research':
        await _buildResearch(pdf, note);
        break;
      case 'Book':
        await _buildBook(pdf, note);
        break;
      case 'Poem':
        await _buildPoem(pdf, note);
        break;
      case 'Classic Sheet':
      default:
        await _buildClassicSheet(pdf, note);
        break;
    }

    // Save file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/note_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // --- Helper: Rich Text Parser (Markdown **bold**) ---
  pw.RichText _parseRichText(String text, {
    required pw.TextStyle style,
    required PdfColor highlightColor,
    PdfColor? textColor,
  }) {
    final spans = <pw.InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*'); // Matches **text**
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(pw.TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style.copyWith(color: textColor ?? style.color),
        ));
      }
      
      spans.add(pw.TextSpan(
        text: match.group(1),
        style: style.copyWith(
          color: textColor ?? style.color,
          fontWeight: pw.FontWeight.bold,
          background: pw.BoxDecoration(color: highlightColor),
        ),
      ));
      
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(pw.TextSpan(
        text: text.substring(lastIndex),
        style: style.copyWith(color: textColor ?? style.color),
      ));
    }

    return pw.RichText(text: pw.TextSpan(children: spans));
  }

  // --- Helper: Fetch Mermaid Image ---
  Future<pw.ImageProvider?> _fetchMermaidImage(String? code) async {
    if (code == null || code.isEmpty) return null;
    try {
      // Basic base64 encode for simple diagrams. 
      // For complex ones, mermaid.ink usually takes a specific compression, 
      // but standard base64 works for many short strings.
      // Ideally we use 'pako' compression but we don't have that package.
      // We will rely on simple encoding for now or raw string if supported.
      // Actually mermaid.ink supports /img/<base64>.
      final encoded = base64Encode(utf8.encode(code));
      final url = 'https://mermaid.ink/img/$encoded?bgColor=FFFFFF'; // Force white bg
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (e) {
      print('Failed to load mermaid diagram: $e');
    }
    return null;
  }

  // --- 1. Classic Sheet (2-Column, Academic, Yellow Highlights) ---
  Future<void> _buildClassicSheet(pw.Document pdf, NoteContent note) async {
    final fontBase = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      theme: pw.ThemeData.withFont(base: fontBase, bold: fontBold),
    );
    
    // Pre-fetch diagrams to allow async in build
    final diagrams = <int, pw.ImageProvider?>{};
    for (int i = 0; i < note.sections.length; i++) {
        diagrams[i] = await _fetchMermaidImage(note.sections[i].mermaidCode);
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(note.title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                pw.Text(note.date, style: const pw.TextStyle(color: PdfColors.grey600)),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              ...note.sections.asMap().entries.map((entry) {
                final idx = entry.key;
                final section = entry.value;
                final diagram = diagrams[idx];
                
                return pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(color: PdfColors.amber, width: 4)),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(section.heading, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.SizedBox(height: 4),
                      _parseRichText(
                        section.content, 
                        style: const pw.TextStyle(fontSize: 10), 
                        highlightColor: PdfColors.yellow200
                      ),
                      if (diagram != null) ...[
                         pw.SizedBox(height: 10),
                         pw.Center(child: pw.Image(diagram, height: 150)),
                      ]
                    ],
                  ),
                );
              }).toList(),
            ]
          )
        ],
      ),
    );
  }

  // --- 2. Dark Mode (Cyber, Dark bg, Neon) ---
  Future<void> _buildDarkMode(pw.Document pdf, NoteContent note) async {
    final fontBase = await PdfGoogleFonts.robotoMonoRegular();
    final fontBold = await PdfGoogleFonts.robotoMonoBold();
    
    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      buildBackground: (context) => pw.Container(color: PdfColors.grey900),
      theme: pw.ThemeData.withFont(base: fontBase, bold: fontBold),
    );
    
    final diagrams = <int, pw.ImageProvider?>{};
    for (int i = 0; i < note.sections.length; i++) {
        // Dark mode diagrams need transparent or dark bg, but ink provides mostly white/transparent.
        // We can invert or just live with it.
        diagrams[i] = await _fetchMermaidImage(note.sections[i].mermaidCode);
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.cyanAccent, width: 2)),
            child: pw.Center(
              child: pw.Text(" // ${note.title.toUpperCase()} // ", style: pw.TextStyle(fontSize: 20, color: PdfColors.cyanAccent, fontWeight: pw.FontWeight.bold)),
            ),
          ),
          pw.SizedBox(height: 20),
          ...note.sections.asMap().entries.map((entry) {
            final idx = entry.key;
            final section = entry.value;
            final diagram = diagrams[idx];
            
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 15),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                gradient: const pw.LinearGradient(
                  colors: [PdfColors.grey800, PdfColors.grey900],
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight
                ),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "> ${section.heading}", 
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.greenAccent, fontWeight: pw.FontWeight.bold)
                  ),
                  pw.SizedBox(height: 5),
                  _parseRichText(
                    section.content, 
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.white), 
                    highlightColor: PdfColors.purple800, // Dark purple bg for highlights
                    textColor: PdfColors.yellowAccent, // Highlighter text color
                  ),
                  if (diagram != null) ...[
                      pw.SizedBox(height: 10),
                      // Add a white container for diagram visibility in dark mode since many are black text on transparent
                      pw.Container(
                          padding: const pw.EdgeInsets.all(5),
                          color: PdfColors.white,
                          child: pw.Image(diagram, height: 150)
                      )
                  ]
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- 3. Creative Sheet (Pastel Cards, Masonry feel) ---
  Future<void> _buildCreativeSheet(pw.Document pdf, NoteContent note) async {
    final fontBase = await PdfGoogleFonts.quicksandRegular();
    final fontBold = await PdfGoogleFonts.quicksandBold();
    
    final colors = [PdfColors.blue50, PdfColors.red50, PdfColors.green50, PdfColors.orange50, PdfColors.purple50];
    int colorIndex = 0;

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      theme: pw.ThemeData.withFont(base: fontBase, bold: fontBold),
    );
    
    final diagrams = <int, pw.ImageProvider?>{};
    for (int i = 0; i < note.sections.length; i++) {
        diagrams[i] = await _fetchMermaidImage(note.sections[i].mermaidCode);
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => [
            pw.Center(
               child: pw.Text(
                 note.title, 
                 style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.pink400)
               )
            ),
            pw.Divider(color: PdfColors.pink200, thickness: 2),
            pw.SizedBox(height: 20),
            
            // We use a Wrap to simulate masonry
            pw.Wrap(
              spacing: 15,
              runSpacing: 15,
              children: note.sections.asMap().entries.map((entry) {
                 final idx = entry.key;
                 final section = entry.value;
                 final diagram = diagrams[idx];
                 
                 final bg = colors[colorIndex % colors.length];
                 final border = [PdfColors.blue200, PdfColors.red200, PdfColors.green200, PdfColors.orange200, PdfColors.purple200][colorIndex % colors.length];
                 colorIndex++;
                 
                 return pw.Container(
                   width: 170, // Rough half width minus padding to simulate column
                   padding: const pw.EdgeInsets.all(12),
                   decoration: pw.BoxDecoration(
                     color: bg,
                     borderRadius: pw.BorderRadius.circular(12),
                     border: pw.Border.all(color: border),
                   ),
                   child: pw.Column(
                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                     children: [
                       pw.Center(child: pw.Text(section.heading, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700), textAlign: pw.TextAlign.center)),
                       pw.Divider(color: border, thickness: 0.5),
                       _parseRichText(
                          section.content, 
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                          highlightColor: PdfColors.white, // In creative, maybe just a white box or underline? Let's use standard highlighter.
                       ),
                       if (diagram != null) ...[
                           pw.SizedBox(height: 8),
                           pw.Image(diagram, height: 80)
                       ]
                     ],
                   )
                 );
              }).toList()
            ),
        ],
      ),
    );
  }

  // --- 3. Research Style (Formal, Serif, 2-Column feel) ---
  Future<void> _buildResearch(pw.Document pdf, NoteContent note) async {
    final fontBase = await PdfGoogleFonts.merriweatherRegular();
    final fontBold = await PdfGoogleFonts.merriweatherBold();
    final fontItalic = await PdfGoogleFonts.merriweatherItalic();

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 40),
      theme: pw.ThemeData.withFont(base: fontBase, bold: fontBold, italic: fontItalic),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => [
          pw.Center(
              child: pw.Text("Research Note", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
          ),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              note.title,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text("Date: ${note.date}", style: const pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic))),
          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.SizedBox(height: 20),
          
          ...note.sections.map((section) {
            return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(section.heading.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text(
                        section.content, 
                        style: const pw.TextStyle(fontSize: 11, lineSpacing: 2), 
                        textAlign: pw.TextAlign.justify
                    ),
                  ]
                )
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- 4. Book Style (Classic, Wide Margins, Chapter-like) ---
  Future<void> _buildBook(pw.Document pdf, NoteContent note) async {
    final fontBase = await PdfGoogleFonts.crimsonTextRegular();
    final fontBold = await PdfGoogleFonts.crimsonTextBold();
    final fontItalic = await PdfGoogleFonts.crimsonTextItalic();

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 60, vertical: 50),
      theme: pw.ThemeData.withFont(base: fontBase, bold: fontBold, italic: fontItalic),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => [
           pw.Center(
               child: pw.Padding(
                   padding: const pw.EdgeInsets.only(top: 100, bottom: 50),
                   child: pw.Text(note.title, style: const pw.TextStyle(fontSize: 36), textAlign: pw.TextAlign.center)
               )
           ),
           pw.Center(
               child: pw.Text("— ${note.date} —", style: const pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic))
           ),
           pw.NewPage(),
           ...note.sections.map((section) {
               return pw.Column(
                   crossAxisAlignment: pw.CrossAxisAlignment.start,
                   children: [
                       pw.Padding(
                           padding: const pw.EdgeInsets.only(top: 20, bottom: 10),
                           child: pw.Text(section.heading, style: const pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))
                       ),
                       pw.Text(
                           section.content,
                           style: const pw.TextStyle(fontSize: 14, lineSpacing: 4),
                           textAlign: pw.TextAlign.justify
                       ),
                   ]
               );
           }).toList()
        ]
      )
    );
  }

  // --- 5. Poem Style (Artistic, Centered) ---
  Future<void> _buildPoem(pw.Document pdf, NoteContent note) async {
     final fontScript = await PdfGoogleFonts.dancingScriptRegular();
     
     final pageTheme = pw.PageTheme(
       pageFormat: PdfPageFormat.a4,
       margin: const pw.EdgeInsets.all(50),
       buildBackground: (context) => pw.Container(
           decoration: pw.BoxDecoration(
               border: pw.Border.all(color: PdfColors.pink100, width: 5)
           )
       ),
       theme: pw.ThemeData.withFont(base: fontScript),
     );

     pdf.addPage(
       pw.MultiPage(
         pageTheme: pageTheme,
         build: (context) => [
             pw.Center(
                 child: pw.Text(
                     note.title, 
                     style: const pw.TextStyle(fontSize: 30, color: PdfColors.pink900),
                     textAlign: pw.TextAlign.center
                 )
             ),
             pw.SizedBox(height: 40),
             ...note.sections.map((section) {
                 return pw.Column(
                     children: [
                         if(section.heading.isNotEmpty && section.heading != 'Poem')
                            pw.Text(section.heading, style: const pw.TextStyle(fontSize: 18, color: PdfColors.pink700)),
                         pw.SizedBox(height: 10),
                         pw.Text(
                             section.content, 
                             style: const pw.TextStyle(fontSize: 20, color: PdfColors.black),
                             textAlign: pw.TextAlign.center
                         ),
                         pw.SizedBox(height: 30),
                     ]
                 );
             }).toList()
         ]
       )
     );
  }
}
