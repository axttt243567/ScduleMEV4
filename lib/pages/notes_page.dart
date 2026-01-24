import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path_lib;
import 'ai_chat_page.dart';
import 'settings_page.dart';

// Data models for nested file structure
enum FileType { pdf, jpeg, jpg, png, doc, txt, mp3, mp4 }

class NoteFile {
  final String name;
  final FileType type;
  final String size;
  final String date;
  final String? demoUrl; // For demo images/pdfs from network
  final String? assetPath; // For local asset files

  NoteFile({
    required this.name,
    required this.type,
    required this.size,
    required this.date,
    this.demoUrl,
    this.assetPath,
  });

  IconData get icon {
    switch (type) {
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.jpeg:
      case FileType.jpg:
      case FileType.png:
        return Icons.image;
      case FileType.doc:
        return Icons.description;
      case FileType.txt:
        return Icons.article;
      case FileType.mp3:
        return Icons.audiotrack;
      case FileType.mp4:
        return Icons.videocam;
    }
  }

  Color get color {
    switch (type) {
      case FileType.pdf:
        return const Color(0xFFEF4444);
      case FileType.jpeg:
      case FileType.jpg:
        return const Color(0xFF3B82F6);
      case FileType.png:
        return const Color(0xFF10B981);
      case FileType.doc:
        return const Color(0xFF2563EB);
      case FileType.txt:
        return const Color(0xFF6B7280);
      case FileType.mp3:
        return const Color(0xFFF59E0B);
      case FileType.mp4:
        return const Color(0xFF8B5CF6);
    }
  }

  String get extension {
    switch (type) {
      case FileType.pdf:
        return 'PDF';
      case FileType.jpeg:
        return 'JPEG';
      case FileType.jpg:
        return 'JPG';
      case FileType.png:
        return 'PNG';
      case FileType.doc:
        return 'DOC';
      case FileType.txt:
        return 'TXT';
      case FileType.mp3:
        return 'MP3';
      case FileType.mp4:
        return 'MP4';
    }
  }

  bool get isImage =>
      type == FileType.jpeg || type == FileType.jpg || type == FileType.png;
  bool get isPdf => type == FileType.pdf;
  bool get isAudio => type == FileType.mp3;
  bool get isVideo => type == FileType.mp4;
  bool get isDocument => type == FileType.doc || type == FileType.txt;

  bool get isLocalAsset => assetPath != null;
  bool get isNetworkFile => demoUrl != null;
}

class NoteFolder {
  final String name;
  final Color color;
  final IconData icon;
  final List<NoteFolder> subFolders;
  final List<NoteFile> files;
  final String? syncStatus;

  NoteFolder({
    required this.name,
    required this.color,
    required this.icon,
    this.subFolders = const [],
    this.files = const [],
    this.syncStatus,
  });

  int get totalFileCount {
    int count = files.length;
    for (var folder in subFolders) {
      count += folder.totalFileCount;
    }
    return count;
  }

  int get folderCount => subFolders.length;
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Navigation stack for nested folders
  List<NoteFolder> _navigationStack = [];

  // Demo data with nested structure
  late List<NoteFolder> _vaultDirectories;

  @override
  void initState() {
    super.initState();
    _initializeDemoData();
  }

  void _initializeDemoData() {
    // Demo URLs for real content
    const demoImages = [
      'https://picsum.photos/800/1200?random=1',
      'https://picsum.photos/800/1200?random=2',
      'https://picsum.photos/800/1200?random=3',
      'https://picsum.photos/800/1200?random=4',
      'https://picsum.photos/800/1200?random=5',
      'https://picsum.photos/800/1200?random=6',
      'https://picsum.photos/800/1200?random=7',
      'https://picsum.photos/800/1200?random=8',
      'https://picsum.photos/800/1200?random=9',
      'https://picsum.photos/800/1200?random=10',
    ];

    // Demo PDF URL (sample PDF from web)
    const demoPdfUrl =
        'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

    _vaultDirectories = [
      NoteFolder(
        name: 'CS101',
        color: const Color(0xFF3B82F6),
        icon: Icons.folder,
        syncStatus: 'SYNC',
        subFolders: [
          NoteFolder(
            name: 'Lectures',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'Week1_Intro',
                type: FileType.pdf,
                size: '2.4 MB',
                date: '01/15',
                demoUrl: demoPdfUrl,
              ),
              NoteFile(
                name: 'Week2_Variables',
                type: FileType.pdf,
                size: '3.1 MB',
                date: '01/18',
                demoUrl: demoPdfUrl,
              ),
              NoteFile(
                name: 'Week3_Loops',
                type: FileType.pdf,
                size: '2.8 MB',
                date: '01/22',
                demoUrl: demoPdfUrl,
              ),
            ],
          ),
          NoteFolder(
            name: 'Assignments',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'HW1_Solution',
                type: FileType.pdf,
                size: '1.2 MB',
                date: '01/20',
                demoUrl: demoPdfUrl,
              ),
              NoteFile(
                name: 'HW2_Draft',
                type: FileType.png,
                size: '890 KB',
                date: '01/23',
                demoUrl: demoImages[0],
              ),
            ],
          ),
          NoteFolder(
            name: 'Notes',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            subFolders: [
              NoteFolder(
                name: 'Handwritten',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(
                    name: 'Class_Notes_01',
                    type: FileType.jpg,
                    size: '1.5 MB',
                    date: '01/15',
                    demoUrl: demoImages[1],
                  ),
                  NoteFile(
                    name: 'Class_Notes_02',
                    type: FileType.jpeg,
                    size: '1.8 MB',
                    date: '01/18',
                    demoUrl: demoImages[2],
                  ),
                  NoteFile(
                    name: 'Diagram_FlowChart',
                    type: FileType.png,
                    size: '650 KB',
                    date: '01/20',
                    demoUrl: demoImages[3],
                  ),
                ],
              ),
            ],
            files: [
              NoteFile(
                name: 'Summary_Week1',
                type: FileType.pdf,
                size: '450 KB',
                date: '01/17',
                demoUrl: demoPdfUrl,
              ),
            ],
          ),
        ],
        files: [
          NoteFile(
            name: 'Syllabus',
            type: FileType.pdf,
            size: '320 KB',
            date: '01/10',
            demoUrl: demoPdfUrl,
          ),
          NoteFile(
            name: 'Course_Overview',
            type: FileType.png,
            size: '1.1 MB',
            date: '01/10',
            demoUrl: demoImages[4],
          ),
        ],
      ),
      NoteFolder(
        name: 'Calculus II',
        color: const Color(0xFF3B82F6),
        icon: Icons.functions,
        syncStatus: 'Static',
        subFolders: [
          NoteFolder(
            name: 'Integrals',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'Integration_Rules',
                type: FileType.pdf,
                size: '1.8 MB',
                date: '01/12',
                demoUrl: demoPdfUrl,
              ),
              NoteFile(
                name: 'Practice_Problems',
                type: FileType.pdf,
                size: '2.2 MB',
                date: '01/14',
                demoUrl: demoPdfUrl,
              ),
              NoteFile(
                name: 'Formula_Sheet',
                type: FileType.jpeg,
                size: '780 KB',
                date: '01/16',
                demoUrl: demoImages[5],
              ),
            ],
          ),
          NoteFolder(
            name: 'Series',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'Taylor_Series',
                type: FileType.pdf,
                size: '1.5 MB',
                date: '01/19',
                demoUrl: demoPdfUrl,
              ),
              NoteFile(
                name: 'Convergence_Tests',
                type: FileType.png,
                size: '920 KB',
                date: '01/21',
                demoUrl: demoImages[6],
              ),
            ],
          ),
        ],
        files: [
          NoteFile(
            name: 'Textbook_Ch5',
            type: FileType.pdf,
            size: '4.5 MB',
            date: '01/08',
            demoUrl: demoPdfUrl,
          ),
        ],
      ),
      NoteFolder(
        name: 'Art History',
        color: const Color(0xFF3B82F6),
        icon: Icons.palette,
        subFolders: [
          NoteFolder(
            name: 'Renaissance',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            subFolders: [
              NoteFolder(
                name: 'Italian Masters',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Botticelli_Birth_of_Venus', type: FileType.jpeg, size: '4.2 MB', date: '01/09', demoUrl: 'https://picsum.photos/1920/1080?random=50'),
                  NoteFile(name: 'Titian_Works', type: FileType.jpg, size: '3.1 MB', date: '01/10', demoUrl: 'https://picsum.photos/1920/1080?random=51'),
                ],
              ),
              NoteFolder(
                name: 'Northern Renaissance',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Durer_Prints', type: FileType.png, size: '2.5 MB', date: '01/11', demoUrl: 'https://picsum.photos/1920/1080?random=52'),
                  NoteFile(name: 'Van_Eyck_Detail', type: FileType.jpeg, size: '3.8 MB', date: '01/12', demoUrl: 'https://picsum.photos/1920/1080?random=53'),
                ],
              ),
            ],
            files: [
              NoteFile(
                name: 'DaVinci_Works',
                type: FileType.jpeg,
                size: '3.2 MB',
                date: '01/11',
                demoUrl: 'https://picsum.photos/800/1200?random=100',
              ),
              NoteFile(
                name: 'Michelangelo',
                type: FileType.jpg,
                size: '2.8 MB',
                date: '01/13',
                demoUrl: 'https://picsum.photos/800/1200?random=101',
              ),
              NoteFile(
                name: 'Raphael_Study',
                type: FileType.png,
                size: '2.1 MB',
                date: '01/15',
                demoUrl: 'https://picsum.photos/800/1200?random=102',
              ),
            ],
          ),
          NoteFolder(
            name: 'Baroque',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            subFolders: [
              NoteFolder(
                name: 'Dutch Golden Age',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Rembrandt_Portraits', type: FileType.jpeg, size: '4.5 MB', date: '01/14', demoUrl: 'https://picsum.photos/1920/1080?random=54'),
                  NoteFile(name: 'Vermeer_Interior', type: FileType.jpg, size: '3.2 MB', date: '01/15', demoUrl: 'https://picsum.photos/1920/1080?random=55'),
                  NoteFile(name: 'Frans_Hals_Study', type: FileType.png, size: '2.9 MB', date: '01/16', demoUrl: 'https://picsum.photos/1920/1080?random=56'),
                ],
              ),
            ],
            files: [
              NoteFile(name: 'Caravaggio_Light', type: FileType.jpeg, size: '3.8 MB', date: '01/13', demoUrl: 'https://picsum.photos/1920/1080?random=57'),
              NoteFile(name: 'Baroque_Notes', type: FileType.pdf, size: '1.2 MB', date: '01/14', demoUrl: demoPdfUrl),
            ],
          ),
          NoteFolder(
            name: 'Impressionism',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            subFolders: [
              NoteFolder(
                name: 'French Masters',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Renoir_Portraits', type: FileType.jpeg, size: '3.4 MB', date: '01/18', demoUrl: 'https://picsum.photos/1920/1080?random=58'),
                  NoteFile(name: 'Degas_Dancers', type: FileType.jpg, size: '2.9 MB', date: '01/19', demoUrl: 'https://picsum.photos/1920/1080?random=59'),
                  NoteFile(name: 'Cezanne_Landscapes', type: FileType.png, size: '3.1 MB', date: '01/20', demoUrl: 'https://picsum.photos/1920/1080?random=60'),
                ],
              ),
            ],
            files: [
              NoteFile(
                name: 'Monet_Gallery',
                type: FileType.jpeg,
                size: '4.1 MB',
                date: '01/17',
                demoUrl: 'https://picsum.photos/800/1200?random=103',
              ),
              NoteFile(
                name: 'Van_Gogh',
                type: FileType.jpg,
                size: '3.5 MB',
                date: '01/19',
                demoUrl: 'https://picsum.photos/800/1200?random=104',
              ),
            ],
          ),
          NoteFolder(
            name: 'Modern Art',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            subFolders: [
              NoteFolder(
                name: 'Abstract',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                subFolders: [
                  NoteFolder(
                    name: 'Color Field',
                    color: const Color(0xFF3B82F6),
                    icon: Icons.folder,
                    files: [
                      NoteFile(name: 'Rothko_Study', type: FileType.jpeg, size: '2.1 MB', date: '01/22', demoUrl: 'https://picsum.photos/1920/1080?random=61'),
                      NoteFile(name: 'Newman_Works', type: FileType.jpg, size: '1.8 MB', date: '01/23', demoUrl: 'https://picsum.photos/1920/1080?random=62'),
                    ],
                  ),
                ],
                files: [
                  NoteFile(
                    name: 'Kandinsky',
                    type: FileType.png,
                    size: '1.9 MB',
                    date: '01/20',
                    demoUrl: 'https://picsum.photos/800/1200?random=105',
                  ),
                  NoteFile(
                    name: 'Mondrian',
                    type: FileType.jpeg,
                    size: '1.2 MB',
                    date: '01/21',
                    demoUrl: 'https://picsum.photos/800/1200?random=106',
                  ),
                ],
              ),
              NoteFolder(
                name: 'Cubism',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Braque_Still_Life', type: FileType.jpeg, size: '2.4 MB', date: '01/19', demoUrl: 'https://picsum.photos/1920/1080?random=63'),
                  NoteFile(name: 'Gris_Analysis', type: FileType.pdf, size: '1.5 MB', date: '01/20', demoUrl: demoPdfUrl),
                ],
              ),
              NoteFolder(
                name: 'Surrealism',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Dali_Dreams', type: FileType.jpeg, size: '3.6 MB', date: '01/21', demoUrl: 'https://picsum.photos/1920/1080?random=64'),
                  NoteFile(name: 'Magritte_Analysis', type: FileType.pdf, size: '1.8 MB', date: '01/22', demoUrl: demoPdfUrl),
                  NoteFile(name: 'Miro_Symbols', type: FileType.png, size: '2.2 MB', date: '01/23', demoUrl: 'https://picsum.photos/1920/1080?random=65'),
                ],
              ),
            ],
            files: [
              NoteFile(
                name: 'Picasso_Analysis',
                type: FileType.pdf,
                size: '2.3 MB',
                date: '01/18',
                demoUrl: demoPdfUrl,
              ),
            ],
          ),
          NoteFolder(
            name: 'Contemporary',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            subFolders: [
              NoteFolder(
                name: 'Pop Art',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Warhol_Prints', type: FileType.jpeg, size: '2.8 MB', date: '01/24', demoUrl: 'https://picsum.photos/1920/1080?random=66'),
                  NoteFile(name: 'Lichtenstein_Comics', type: FileType.jpg, size: '2.1 MB', date: '01/24', demoUrl: 'https://picsum.photos/1920/1080?random=67'),
                ],
              ),
              NoteFolder(
                name: 'Street Art',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Banksy_Works', type: FileType.jpeg, size: '3.2 MB', date: '01/24', demoUrl: 'https://picsum.photos/1920/1080?random=68'),
                  NoteFile(name: 'Basquiat_Study', type: FileType.pdf, size: '2.5 MB', date: '01/24', demoUrl: demoPdfUrl),
                ],
              ),
            ],
            files: [
              NoteFile(name: 'Contemporary_Overview', type: FileType.pdf, size: '3.1 MB', date: '01/24', demoUrl: demoPdfUrl),
            ],
          ),
          NoteFolder(
            name: 'Sculpture',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            subFolders: [
              NoteFolder(
                name: 'Classical',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Greek_Statues', type: FileType.jpeg, size: '4.1 MB', date: '01/08', demoUrl: 'https://picsum.photos/1920/1080?random=69'),
                  NoteFile(name: 'Roman_Busts', type: FileType.jpg, size: '3.5 MB', date: '01/09', demoUrl: 'https://picsum.photos/1920/1080?random=70'),
                ],
              ),
              NoteFolder(
                name: 'Modern Sculpture',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Rodin_Analysis', type: FileType.pdf, size: '2.8 MB', date: '01/15', demoUrl: demoPdfUrl),
                  NoteFile(name: 'Brancusi_Forms', type: FileType.jpeg, size: '2.2 MB', date: '01/16', demoUrl: 'https://picsum.photos/1920/1080?random=71'),
                ],
              ),
            ],
            files: [
              NoteFile(name: 'Sculpture_History', type: FileType.pdf, size: '4.5 MB', date: '01/10', demoUrl: demoPdfUrl),
            ],
          ),
          NoteFolder(
            name: 'Lecture Slides',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            subFolders: [
              NoteFolder(
                name: 'Midterm Review',
                color: const Color(0xFF3B82F6),
                icon: Icons.folder,
                files: [
                  NoteFile(name: 'Chapters_1_5', type: FileType.pdf, size: '8.2 MB', date: '01/20', demoUrl: demoPdfUrl),
                  NoteFile(name: 'Practice_Questions', type: FileType.pdf, size: '1.5 MB', date: '01/21', demoUrl: demoPdfUrl),
                ],
              ),
            ],
            files: [
              NoteFile(
                name: 'Week1_Slides',
                type: FileType.pdf,
                size: '5.2 MB',
                date: '01/10',
                demoUrl: demoPdfUrl,
              ),
              NoteFile(
                name: 'Week2_Slides',
                type: FileType.pdf,
                size: '4.8 MB',
                date: '01/17',
                demoUrl: demoPdfUrl,
              ),
              NoteFile(name: 'Week3_Slides', type: FileType.pdf, size: '5.5 MB', date: '01/24', demoUrl: demoPdfUrl),
            ],
          ),
        ],
        files: [
          NoteFile(
            name: 'Course_Syllabus',
            type: FileType.pdf,
            size: '280 KB',
            date: '01/08',
            demoUrl: demoPdfUrl,
          ),
          NoteFile(name: 'Reading_List', type: FileType.txt, size: '15 KB', date: '01/08'),
          NoteFile(name: 'Museum_Map', type: FileType.png, size: '1.8 MB', date: '01/09', demoUrl: 'https://picsum.photos/1920/1080?random=72'),
        ],
      ),
      NoteFolder(
        name: 'Microecon',
        color: const Color(0xFF3B82F6),
        icon: Icons.insights,
        subFolders: [
          NoteFolder(
            name: 'Supply & Demand',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'Market_Equilibrium',
                type: FileType.pdf,
                size: '1.6 MB',
                date: '01/12',
                demoUrl: demoPdfUrl,
              ),
              NoteFile(
                name: 'Price_Elasticity',
                type: FileType.png,
                size: '720 KB',
                date: '01/14',
                demoUrl: demoImages[7],
              ),
              NoteFile(
                name: 'Graph_Examples',
                type: FileType.jpg,
                size: '1.1 MB',
                date: '01/16',
                demoUrl: demoImages[8],
              ),
            ],
          ),
          // Test folder with all file formats - includes LOCAL PDFs
          NoteFolder(
            name: 'Test Files',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              // LOCAL PDF files from TEST_FILES folder
              NoteFile(
                name: 'TEST',
                type: FileType.pdf,
                size: '1.0 MB',
                date: '01/24',
                assetPath: 'TEST_FILES/TEST.PDF',
              ),
              NoteFile(
                name: 'TEST02',
                type: FileType.pdf,
                size: '1.0 MB',
                date: '01/24',
                assetPath: 'TEST_FILES/TEST02.pdf',
              ),
              // Network PDF for comparison
              NoteFile(
                name: 'Sample_Document',
                type: FileType.pdf,
                size: '2.5 MB',
                date: '01/20',
                demoUrl: 'https://www.africau.edu/images/default/sample.pdf',
              ),
              NoteFile(
                name: 'Test_Image_PNG',
                type: FileType.png,
                size: '1.2 MB',
                date: '01/20',
                demoUrl: 'https://picsum.photos/1920/1080?random=100',
              ),
              NoteFile(
                name: 'Test_Image_JPG',
                type: FileType.jpg,
                size: '980 KB',
                date: '01/20',
                demoUrl: 'https://picsum.photos/1920/1080?random=101',
              ),
              NoteFile(
                name: 'Test_Image_JPEG',
                type: FileType.jpeg,
                size: '1.5 MB',
                date: '01/20',
                demoUrl: 'https://picsum.photos/1920/1080?random=102',
              ),
              NoteFile(
                name: 'Lecture_Notes',
                type: FileType.doc,
                size: '350 KB',
                date: '01/21',
              ),
              NoteFile(
                name: 'Quick_Notes',
                type: FileType.txt,
                size: '12 KB',
                date: '01/21',
              ),
              NoteFile(
                name: 'Lecture_Recording',
                type: FileType.mp3,
                size: '45 MB',
                date: '01/22',
              ),
              NoteFile(
                name: 'Tutorial_Video',
                type: FileType.mp4,
                size: '250 MB',
                date: '01/22',
              ),
            ],
          ),
        ],
        files: [
          NoteFile(
            name: 'Econ_Textbook_Ch1',
            type: FileType.pdf,
            size: '3.8 MB',
            date: '01/09',
            demoUrl: demoPdfUrl,
          ),
          NoteFile(
            name: 'Formula_Reference',
            type: FileType.jpeg,
            size: '450 KB',
            date: '01/11',
            demoUrl: demoImages[9],
          ),
        ],
      ),
      // TEST VAULT - All file types for testing
      NoteFolder(
        name: 'test',
        color: const Color(0xFF3B82F6),
        icon: Icons.science,
        syncStatus: 'TEST',
        subFolders: [
          NoteFolder(
            name: 'PDFs',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'Local_Test_PDF',
                type: FileType.pdf,
                size: '1.9 MB',
                date: '01/24',
                assetPath: 'TEST_FILES/TEST.PDF',
              ),
              NoteFile(
                name: 'Local_Test_PDF_02',
                type: FileType.pdf,
                size: '1.4 MB',
                date: '01/24',
                assetPath: 'TEST_FILES/TEST02.pdf',
              ),
              NoteFile(
                name: 'Network_Sample_PDF',
                type: FileType.pdf,
                size: '2.5 MB',
                date: '01/24',
                demoUrl: 'https://www.africau.edu/images/default/sample.pdf',
              ),
            ],
          ),
          NoteFolder(
            name: 'Images',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'Sample_JPG',
                type: FileType.jpg,
                size: '1.2 MB',
                date: '01/24',
                demoUrl: 'https://picsum.photos/1920/1080?random=200',
              ),
              NoteFile(
                name: 'Sample_JPEG',
                type: FileType.jpeg,
                size: '980 KB',
                date: '01/24',
                demoUrl: 'https://picsum.photos/1920/1080?random=201',
              ),
              NoteFile(
                name: 'Sample_PNG',
                type: FileType.png,
                size: '1.5 MB',
                date: '01/24',
                demoUrl: 'https://picsum.photos/1920/1080?random=202',
              ),
            ],
          ),
          NoteFolder(
            name: 'Videos',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'Big_Buck_Bunny',
                type: FileType.mp4,
                size: '5.3 MB',
                date: '01/24',
                demoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              ),
              NoteFile(
                name: 'Elephant_Dream',
                type: FileType.mp4,
                size: '8.0 MB',
                date: '01/24',
                demoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
              ),
            ],
          ),
          NoteFolder(
            name: 'Audio',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'Sample_Audio_1',
                type: FileType.mp3,
                size: '3.2 MB',
                date: '01/24',
                demoUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
              ),
              NoteFile(
                name: 'Sample_Audio_2',
                type: FileType.mp3,
                size: '4.1 MB',
                date: '01/24',
                demoUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
              ),
            ],
          ),
          NoteFolder(
            name: 'Documents',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(
                name: 'Quick_Notes',
                type: FileType.txt,
                size: '12 KB',
                date: '01/24',
              ),
              NoteFile(
                name: 'Lecture_Notes',
                type: FileType.doc,
                size: '350 KB',
                date: '01/24',
              ),
            ],
          ),
        ],
        files: [
          NoteFile(
            name: 'README',
            type: FileType.txt,
            size: '2 KB',
            date: '01/24',
          ),
        ],
      ),
      // Additional Vault Directories - All Blue
      NoteFolder(
        name: 'Physics 201',
        color: const Color(0xFF3B82F6),
        icon: Icons.brightness_high,
        syncStatus: 'SYNC',
        subFolders: [
          NoteFolder(
            name: 'Mechanics',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(name: 'Newton_Laws', type: FileType.pdf, size: '2.1 MB', date: '01/20', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
              NoteFile(name: 'Kinematics', type: FileType.pdf, size: '1.8 MB', date: '01/21', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
            ],
          ),
          NoteFolder(
            name: 'Thermodynamics',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(name: 'Heat_Transfer', type: FileType.pdf, size: '3.2 MB', date: '01/22', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
            ],
          ),
        ],
        files: [
          NoteFile(name: 'Syllabus', type: FileType.pdf, size: '450 KB', date: '01/15', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
        ],
      ),
      NoteFolder(
        name: 'Chemistry',
        color: const Color(0xFF3B82F6),
        icon: Icons.science,
        subFolders: [
          NoteFolder(
            name: 'Organic',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(name: 'Carbon_Compounds', type: FileType.pdf, size: '2.5 MB', date: '01/18', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
              NoteFile(name: 'Reactions', type: FileType.pdf, size: '1.9 MB', date: '01/19', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
            ],
          ),
        ],
        files: [
          NoteFile(name: 'Periodic_Table', type: FileType.png, size: '1.2 MB', date: '01/10', demoUrl: 'https://picsum.photos/1920/1080?random=300'),
        ],
      ),
      NoteFolder(
        name: 'Biology',
        color: const Color(0xFF3B82F6),
        icon: Icons.eco,
        subFolders: [
          NoteFolder(
            name: 'Cell Biology',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(name: 'Cell_Structure', type: FileType.pdf, size: '3.8 MB', date: '01/16', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
              NoteFile(name: 'Mitosis', type: FileType.jpg, size: '2.1 MB', date: '01/17', demoUrl: 'https://picsum.photos/1920/1080?random=301'),
            ],
          ),
        ],
        files: [],
      ),
      NoteFolder(
        name: 'Literature',
        color: const Color(0xFF3B82F6),
        icon: Icons.menu_book,
        syncStatus: 'SYNC',
        subFolders: [
          NoteFolder(
            name: 'Shakespeare',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(name: 'Hamlet_Analysis', type: FileType.pdf, size: '1.5 MB', date: '01/12', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
              NoteFile(name: 'Macbeth_Notes', type: FileType.pdf, size: '1.8 MB', date: '01/14', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
            ],
          ),
        ],
        files: [
          NoteFile(name: 'Reading_List', type: FileType.txt, size: '15 KB', date: '01/08'),
        ],
      ),
      NoteFolder(
        name: 'History',
        color: const Color(0xFF3B82F6),
        icon: Icons.history_edu,
        subFolders: [
          NoteFolder(
            name: 'World War II',
            color: const Color(0xFF3B82F6),
            icon: Icons.folder,
            files: [
              NoteFile(name: 'Timeline', type: FileType.pdf, size: '4.2 MB', date: '01/11', demoUrl: 'https://www.africau.edu/images/default/sample.pdf'),
              NoteFile(name: 'Key_Events', type: FileType.jpg, size: '2.8 MB', date: '01/13', demoUrl: 'https://picsum.photos/1920/1080?random=302'),
            ],
          ),
        ],
        files: [],
      ),
    ];
  }

  void _enterFolder(NoteFolder folder) {
    setState(() {
      _navigationStack.add(folder);
    });
  }

  void _goBack() {
    if (_navigationStack.isNotEmpty) {
      setState(() {
        _navigationStack.removeLast();
      });
    }
  }

  void _goToRoot() {
    setState(() {
      _navigationStack.clear();
    });
  }

  NoteFolder? get _currentFolder {
    return _navigationStack.isNotEmpty ? _navigationStack.last : null;
  }

  String get _currentPath {
    if (_navigationStack.isEmpty) return 'VAULT';
    return _navigationStack.map((f) => f.name).join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Header - only show at root level
              if (_navigationStack.isEmpty) ...[
                _buildHeader(),
                const SizedBox(height: 24),
              ],

              // Vault Directories Section or Current Folder Contents
              _buildVaultDirectoriesSection(),

              // Show recently opened only at root level (below vault directories)
              if (_navigationStack.isEmpty) ...[
                const SizedBox(height: 28),
                // Recently Opened Section
                _buildRecentlyOpenedSection(),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Handle notification tap
            },
            child: _buildIconButton(Icons.notifications_outlined),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatPage()),
              );
            },
            child: _buildIconButton(Icons.auto_awesome, isHighlighted: true),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: _buildIconButton(Icons.tune),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {bool isHighlighted = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Icon(
        icon,
        color: isHighlighted ? const Color(0xFF3B82F6) : Colors.grey[400],
        size: 20,
      ),
    );
  }

  Widget _buildRecentlyOpenedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'RECENTLY OPENED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.grey[500],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildRecentCard(
                subject: 'CS101',
                title: 'Recursion & Base Cases',
                openedTime: 'Opened 15m ago',
                fileCount: 12,
                color: const Color(0xFF3B82F6),
                icon: Icons.code,
              ),
              const SizedBox(width: 16),
              _buildRecentCard(
                subject: 'CALC_II',
                title: 'Integration by Parts',
                openedTime: 'Opened 2h ago',
                fileCount: 8,
                color: const Color(0xFF3B82F6),
                icon: Icons.functions,
              ),
              const SizedBox(width: 16),
              _buildRecentCard(
                subject: 'PHY201',
                title: 'Quantum Mechanics',
                openedTime: 'Opened 1d ago',
                fileCount: 6,
                color: const Color(0xFF3B82F6),
                icon: Icons.science,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCard({
    required String subject,
    required String title,
    required String openedTime,
    required int fileCount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview area with icon
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(icon, size: 40, color: color.withOpacity(0.3)),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subject,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$openedTime • $fileCount Files',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Get the root vault folder from the navigation stack
  NoteFolder get _rootVault => _navigationStack.first;

  // Build file type summary string like "PDF(2), JPEG(1)"
  String _getFileTypeSummary(List<NoteFile> files) {
    if (files.isEmpty) return '';
    final Map<String, int> typeCounts = {};
    for (var file in files) {
      typeCounts[file.extension] = (typeCounts[file.extension] ?? 0) + 1;
    }
    return typeCounts.entries.map((e) => '${e.key}(${e.value})').join(', ');
  }

  // Build clickable breadcrumb with multiline support
  Widget _buildClickableBreadcrumb() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: _navigationStack.asMap().entries.map((entry) {
        final index = entry.key;
        final folder = entry.value;
        final isLast = index == _navigationStack.length - 1;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to this folder in the stack
                setState(() {
                  _navigationStack.removeRange(index + 1, _navigationStack.length);
                });
              },
              child: Text(
                folder.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                  color: isLast ? const Color(0xFF3B82F6) : Colors.grey[400],
                ),
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '/',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildVaultTreeStructure() {
    if (_navigationStack.isEmpty) return const SizedBox.shrink();
    
    final rootVault = _rootVault;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Build clean tree
          _buildCleanTreeNode(rootVault, 0, true),
        ],
      ),
    );
  }

  Widget _buildCleanTreeNode(NoteFolder folder, int depth, bool isRoot) {
    final isCurrentFolder = _currentFolder == folder;
    final hasSubfolders = folder.subFolders.isNotEmpty;
    
    // Check if this folder is in the navigation path (should be expanded)
    final isInNavigationPath = _navigationStack.contains(folder);
    
    // Only expand subfolders if this folder is in the navigation path
    final shouldExpandSubfolders = isInNavigationPath;
    
    // Only show files if this is the current folder the user is viewing
    final shouldShowFiles = isCurrentFolder;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Folder row (always visible)
        GestureDetector(
          onTap: () {
            if (isRoot) {
              _goToRoot();
              _enterFolder(folder);
            } else {
              _navigateToFolder(folder);
            }
          },
          child: Container(
            padding: EdgeInsets.only(left: depth * 20.0),
            child: Row(
              children: [
                // Indent line
                if (depth > 0)
                  Container(
                    width: 2,
                    height: 20,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isCurrentFolder 
                          ? const Color(0xFF3B82F6) 
                          : isInNavigationPath
                              ? const Color(0xFF3B82F6).withOpacity(0.4)
                              : const Color(0xFF2A2A36),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                // Expand/collapse indicator for folders with children
                if (hasSubfolders || folder.files.isNotEmpty)
                  Icon(
                    shouldExpandSubfolders 
                        ? Icons.keyboard_arrow_down_rounded 
                        : Icons.keyboard_arrow_right_rounded,
                    size: 14,
                    color: isCurrentFolder 
                        ? const Color(0xFF3B82F6) 
                        : Colors.grey[600],
                  )
                else
                  const SizedBox(width: 14),
                const SizedBox(width: 4),
                // Folder icon
                Icon(
                  isRoot ? Icons.folder_special_rounded : Icons.folder_rounded,
                  size: 16,
                  color: isCurrentFolder 
                      ? const Color(0xFF3B82F6) 
                      : isInNavigationPath
                          ? const Color(0xFF3B82F6).withOpacity(0.7)
                          : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                // Folder name
                Expanded(
                  child: Text(
                    folder.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isCurrentFolder ? FontWeight.w600 : FontWeight.w400,
                      color: isCurrentFolder 
                          ? Colors.white 
                          : isInNavigationPath
                              ? Colors.grey[300]
                              : Colors.grey[400],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Current location indicator
                if (isCurrentFolder)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '●',
                      style: TextStyle(
                        fontSize: 6,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  // File count (subtle) - shows total content count
                  Text(
                    '${folder.totalFileCount}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Subfolders - only show if this folder is expanded (in navigation path)
        if (hasSubfolders && shouldExpandSubfolders)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: folder.subFolders.map((subFolder) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildCleanTreeNode(subFolder, depth + 1, false),
                );
              }).toList(),
            ),
          ),
        // Files - only show if this is the current folder
        if (folder.files.isNotEmpty && shouldShowFiles)
          Padding(
            padding: EdgeInsets.only(top: hasSubfolders ? 4 : 6, left: (depth + 1) * 20.0 + 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: folder.files.map((file) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 16,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A36),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Icon(
                        file.icon,
                        size: 12,
                        color: file.color.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          file.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: file.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          file.extension,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: file.color.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _navigateToFolder(NoteFolder targetFolder) {
    // Clear current stack and rebuild path to target folder
    final rootVault = _rootVault;
    _navigationStack.clear();
    _navigationStack.add(rootVault);
    
    // Find path to target folder
    _findAndNavigate(rootVault, targetFolder);
    setState(() {});
  }

  bool _findAndNavigate(NoteFolder current, NoteFolder target) {
    if (current == target) return true;
    for (var subFolder in current.subFolders) {
      if (subFolder == target) {
        _navigationStack.add(subFolder);
        return true;
      }
      if (_findAndNavigate(subFolder, target)) {
        _navigationStack.insert(_navigationStack.length - 1, subFolder);
        return true;
      }
    }
    return false;
  }

  Widget _buildVaultDirectoriesSection() {
    final isInFolder = _navigationStack.isNotEmpty;
    final currentFolder = _currentFolder;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb / Navigation Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isInFolder) ...[
                GestureDetector(
                  onTap: _goBack,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF27272A)),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _goToRoot,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF27272A)),
                    ),
                    child: Icon(
                      Icons.home_outlined,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: isInFolder 
                    ? _buildClickableBreadcrumb()
                    : Text(
                        'VAULT DIRECTORIES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Vault Tree Structure - show when inside a folder
          if (isInFolder) ...[
            _buildVaultTreeStructure(),
            const SizedBox(height: 20),
          ],

          // Content: Folders and Files
          if (isInFolder) ...[
            // Show subfolders
            if (currentFolder!.subFolders.isNotEmpty) ...[
              Text(
                'FOLDERS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: currentFolder.subFolders.map((folder) {
                  return _buildSubFolderCard(folder);
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Show files
            if (currentFolder.files.isNotEmpty) ...[
              Text(
                'FILES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              ...currentFolder.files.map((file) => _buildFileCard(file)),
            ],

            // Empty folder message
            if (currentFolder.subFolders.isEmpty && currentFolder.files.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 48,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This folder is empty',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
          ] else ...[
            // Root level: Show vault directories
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: [
                ..._vaultDirectories.map(
                  (dir) => _buildDirectoryCard(folder: dir),
                ),
                _buildAddNewCard(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubFolderCard(NoteFolder folder) {
    return GestureDetector(
      onTap: () => _enterFolder(folder),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: folder.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.folder, color: folder.color, size: 18),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey[600]),
              ],
            ),
            const Spacer(),
            Text(
              folder.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${folder.files.length} files • ${folder.subFolders.length} folders',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(NoteFile file) {
    return GestureDetector(
      onTap: () => _showFilePreview(file),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: file.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(file.icon, color: file.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${file.extension} • ${file.size} • ${file.date}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: file.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                file.extension,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: file.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilePreview(NoteFile file) {
    if (file.isImage) {
      _showImageViewer(file);
    } else if (file.isPdf) {
      _showPdfViewer(file);
    } else if (file.isVideo) {
      _showVideoPlayer(file);
    } else if (file.isAudio) {
      _showAudioPlayer(file);
    } else {
      _showUnsupportedFileDialog(file);
    }
  }

  void _showImageViewer(NoteFile file) {
    // Get all image files from current folder for swipe navigation
    final currentFolder = _currentFolder;
    if (currentFolder == null) return;
    
    final allImages = currentFolder.files.where((f) => f.isImage).toList();
    final startIndex = allImages.indexOf(file);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImageViewerPage(
          images: allImages,
          initialIndex: startIndex >= 0 ? startIndex : 0,
        ),
      ),
    );
  }

  void _showPdfViewer(NoteFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _PdfViewerPage(file: file)),
    );
  }

  void _showVideoPlayer(NoteFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _VideoPlayerPage(file: file)),
    );
  }

  void _showAudioPlayer(NoteFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _AudioPlayerPage(file: file)),
    );
  }

  void _showUnsupportedFileDialog(NoteFile file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF16161E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: file.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(file.icon, size: 40, color: file.color),
            ),
            const SizedBox(height: 16),
            Text(
              '${file.name}.${file.extension.toLowerCase()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${file.extension} • ${file.size}',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[500], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Preview for ${file.extension} files is not available yet. Coming soon!',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: file.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryCard({required NoteFolder folder}) {
    return GestureDetector(
      onTap: () => _enterFolder(folder),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: folder.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(folder.icon, color: folder.color, size: 20),
                ),
              ],
            ),
            const Spacer(),
            Text(
              folder.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'FILE_COUNT: ${folder.totalFileCount.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'FOLDER_COUNT: ${folder.folderCount.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF27272A),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: CustomPaint(
        painter: DashedBorderPainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 32, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                'INITIAL ENTRY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF27272A)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const radius = 20.0;
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ),
    );

    // Create dashed effect
    final dashPath = Path();
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final start = distance;
        final end = distance + dashWidth;
        dashPath.addPath(
          metric.extractPath(start, end.clamp(0, metric.length)),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// Full-screen Image Viewer with Swipe Navigation
class _ImageViewerPage extends StatefulWidget {
  final List<NoteFile> images;
  final int initialIndex;

  const _ImageViewerPage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  NoteFile get _currentFile => widget.images[_currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_currentFile.name}.${_currentFile.extension.toLowerCase()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              '${_currentIndex + 1} / ${widget.images.length} • ${_currentFile.size}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Swipeable PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _buildImageView(widget.images[index]);
            },
          ),
          // Page indicator dots at bottom
          if (widget.images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF3B82F6)
                          : Colors.grey[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageView(NoteFile file) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: file.demoUrl != null
            ? Image.network(
                file.demoUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: file.color,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
              )
            : _buildErrorWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// Full-screen PDF Viewer using Syncfusion
class _PdfViewerPage extends StatefulWidget {
  final NoteFile file;

  const _PdfViewerPage({required this.file});

  @override
  State<_PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<_PdfViewerPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _hasError = false;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.file.name}.pdf',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (_totalPages > 0)
              Text(
                'Page $_currentPage of $_totalPages',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  (_pdfViewerController.zoomLevel - 0.25).clamp(0.5, 3.0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  (_pdfViewerController.zoomLevel + 0.25).clamp(0.5, 3.0);
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.grey[400]),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: _hasError ? _buildErrorWidget() : _buildPdfViewer(),
    );
  }

  Widget _buildPdfViewer() {
    // Check if it's a local asset file
    if (widget.file.isLocalAsset) {
      return SfPdfViewer.asset(
        widget.file.assetPath!,
        controller: _pdfViewerController,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
        },
        onPageChanged: (PdfPageChangedDetails details) {
          setState(() {
            _currentPage = details.newPageNumber;
          });
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _hasError = true;
          });
        },
      );
    }

    // Check if it's a network file
    if (widget.file.isNetworkFile) {
      return SfPdfViewer.network(
        widget.file.demoUrl!,
        controller: _pdfViewerController,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
        },
        onPageChanged: (PdfPageChangedDetails details) {
          setState(() {
            _currentPage = details.newPageNumber;
          });
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _hasError = true;
          });
        },
      );
    }

    // No valid source
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Failed to load PDF',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.file.color,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Video Player Page
class _VideoPlayerPage extends StatefulWidget {
  final NoteFile file;

  const _VideoPlayerPage({required this.file});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.file.demoUrl != null) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.file.demoUrl!),
      );
      _controller.initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      }).catchError((error) {
        setState(() {
          _hasError = true;
        });
      });
      _controller.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.file.name}.mp4',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: _hasError
          ? _buildErrorWidget()
          : _isInitialized
              ? _buildVideoPlayer()
              : const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
    );
  }

  Widget _buildVideoPlayer() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF16161E),
          child: Column(
            children: [
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: widget.file.color,
                          inactiveTrackColor: Colors.grey[800],
                          thumbColor: widget.file.color,
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: value.position.inMilliseconds.toDouble(),
                          max: value.duration.inMilliseconds.toDouble(),
                          onChanged: (newValue) {
                            _controller.seekTo(Duration(milliseconds: newValue.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(value.position), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            Text(_formatDuration(value.duration), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                    onPressed: () {
                      final newPosition = _controller.value.position - const Duration(seconds: 10);
                      _controller.seekTo(newPosition);
                    },
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      _isPlaying ? _controller.pause() : _controller.play();
                    },
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: widget.file.color, shape: BoxShape.circle),
                      child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                    onPressed: () {
                      final newPosition = _controller.value.position + const Duration(seconds: 10);
                      _controller.seekTo(newPosition);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text('Failed to load video', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// Audio Player Page
class _AudioPlayerPage extends StatefulWidget {
  final NoteFile file;

  const _AudioPlayerPage({required this.file});

  @override
  State<_AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<_AudioPlayerPage> {
  late just_audio.AudioPlayer _player;
  bool _isInitialized = false;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = just_audio.AudioPlayer();
    _initializeAudio();
  }

  void _initializeAudio() async {
    if (widget.file.demoUrl != null) {
      try {
        await _player.setUrl(widget.file.demoUrl!);
        _player.durationStream.listen((d) { if (d != null && mounted) setState(() => _duration = d); });
        _player.positionStream.listen((p) { if (mounted) setState(() => _position = p); });
        _player.playerStateStream.listen((state) { if (mounted) setState(() => _isPlaying = state.playing); });
        setState(() => _isInitialized = true);
      } catch (e) {
        setState(() => _hasError = true);
      }
    } else {
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161E),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('${widget.file.name}.mp3', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: _hasError ? _buildErrorWidget() : _isInitialized ? _buildAudioPlayer() : const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B))),
    );
  }

  Widget _buildAudioPlayer() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200, height: 200,
              decoration: BoxDecoration(color: widget.file.color.withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
              child: Icon(Icons.audiotrack, size: 80, color: widget.file.color),
            ),
            const SizedBox(height: 32),
            Text(widget.file.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            Text('${widget.file.size} • ${widget.file.date}', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 32),
            SliderTheme(
              data: SliderThemeData(activeTrackColor: widget.file.color, inactiveTrackColor: Colors.grey[800], thumbColor: widget.file.color),
              child: Slider(
                value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
                max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1,
                onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Text(_formatDuration(_duration), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.replay_10, color: Colors.white, size: 32), onPressed: () => _player.seek(_position - const Duration(seconds: 10))),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _isPlaying ? _player.pause() : _player.play(),
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: widget.file.color, shape: BoxShape.circle),
                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(icon: const Icon(Icons.forward_10, color: Colors.white, size: 32), onPressed: () => _player.seek(_position + const Duration(seconds: 10))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text('Failed to load audio', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
