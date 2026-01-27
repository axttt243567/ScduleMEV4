import 'package:flutter/material.dart';
import '../models/note_model.dart';

class VaultData {
  static final List<NoteFolder> vaults = _initializeDemoData();

  static List<NoteFolder> _initializeDemoData() {
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

    return [
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
}
