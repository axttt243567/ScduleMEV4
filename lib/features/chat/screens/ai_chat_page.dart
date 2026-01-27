import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../memory/screens/memory_page.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

// Helper class for Dev Test Mode
class TestItem {
  final String id;
  final String description;
  final List<AIContentBlock> blocks;

  TestItem({required this.id, required this.description, required this.blocks});
}

class _AiChatPageState extends State<AiChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = []; // Start with empty chat
  bool _isTyping = false;

  // -- DEV TEST MODE STATE --
  bool _isTestMode = false;
  int _currentTestIndex = 0;
  List<TestItem> _testQueue = [];
  Map<String, String> _testResults = {}; // id -> response (keep/delete/more)


  // Attachment state
  final List<PendingAttachment> _pendingAttachments = [];
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  AnimationController? _recordingAnimController;

  // Lorem ipsum sentences for random AI responses
  static const _loremSentences = [
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
    'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    'Curabitur pretium tincidunt lacus, nec gravida ante vehicula vel.',
    'Praesent blandit laoreet nibh, eu pretium nisl blandit ut.',
    'Fusce lacinia arcu et nulla, vivamus quis tellus sed odio accumsan.',
    'Nullam quis risus eget urna mollis ornare vel eu leo.',
    'Maecenas sed diam eget risus varius blandit sit amet non magna.',
    'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae.',
    'Integer posuere erat a ante venenatis dapibus posuere velit aliquet.',
    'Morbi leo risus, porta ac consectetur ac, vestibulum at eros.',
    'Aenean eu leo quam pellentesque ornare sem lacinia quam venenatis vestibulum.',
    'Donec ullamcorper nulla non metus auctor fringilla.',
  ];

  @override
  void initState() {
    super.initState();
    _recordingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  String _generateLoremIpsum() {
    final random = Random();
    final sentenceCount = random.nextInt(3) + 2; // 2-4 sentences
    final sentences = <String>[];
    for (int i = 0; i < sentenceCount; i++) {
      sentences.add(_loremSentences[random.nextInt(_loremSentences.length)]);
    }
    return sentences.join(' ');
  }

  // Sample placeholder image URLs for demo
  List<AIResponseImage>? _generateSampleImages() {
    final random = Random();
    final shouldIncludeImages = random.nextBool(); // 50% chance
    if (!shouldIncludeImages) return null;

    final imageCount = random.nextInt(4) + 1; // 1-4 images
    final sampleTitles = [
      'Schedule Overview',
      'Class Analysis',
      'Attendance Chart',
      'Course Statistics',
    ];
    final sampleCaptions = [
      'Your weekly schedule breakdown',
      'Performance analytics for this semester',
      'Monthly attendance trends',
      'Subject-wise distribution',
    ];

    return List.generate(
      imageCount,
      (i) => AIResponseImage(
        url: 'placeholder_${i + 1}', // Placeholder - will show demo image
        title: sampleTitles[i % sampleTitles.length],
        caption: sampleCaptions[i % sampleCaptions.length],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty && _pendingAttachments.isEmpty) return;

    // Create message with attachments
    final attachmentsCopy = List<PendingAttachment>.from(_pendingAttachments);

    // Check for dev testing keywords
    int? devImageCount;
    bool useMultiBlock = false;
    bool useCodeBlock = false;

    // Check for #imgN keyword
    final imgRegex = RegExp(r'#img(\d+)', caseSensitive: false);
    final imgMatch = imgRegex.firstMatch(text);
    if (imgMatch != null) {
      devImageCount = int.tryParse(imgMatch.group(1) ?? '');
    }

    // Check for #multi keyword for multi-block testing
    if (text.toLowerCase().contains('#multi')) {
      useMultiBlock = true;
    }

    // Check for #code keyword for code block testing
    if (text.toLowerCase().contains('#code')) {
      useCodeBlock = true;
    }

    // Check for #map keyword for map block testing
    bool useMapBlock = text.toLowerCase().contains('#map');

    // Check for chart keywords
    bool useBarChart = text.toLowerCase().contains('#bar');
    bool usePieChart = text.toLowerCase().contains('#pie');

    // Check for #all keyword to show all content types
    bool useAllBlocks = text.toLowerCase().contains('#all');

    // Check for individual new keywords
    bool useLineChart = text.toLowerCase().contains('#line');
    bool useRadarChart = text.toLowerCase().contains('#radar');
    bool useProgress = text.toLowerCase().contains('#progress');
    bool useTimeline = text.toLowerCase().contains('#timeline');
    bool useQuiz = text.toLowerCase().contains('#quiz');
    bool useChecklist = text.toLowerCase().contains('#checklist');
    bool useTable = text.toLowerCase().contains('#table');
    bool useCarousel = text.toLowerCase().contains('#cards');
    bool useAudio = text.toLowerCase().contains('#audio');
    bool useVideo = text.toLowerCase().contains('#video');
    bool useContact = text.toLowerCase().contains('#contact');
    bool useEvent = text.toLowerCase().contains('#event');
    bool useWeather = text.toLowerCase().contains('#weather');
    bool useCountdown = text.toLowerCase().contains('#countdown');
    bool useFlash = text.toLowerCase().contains('#flash');
    bool useActions = text.toLowerCase().contains('#actions');

    // Check for new paper/note styles
    bool useNote = text.toLowerCase().contains('#note');
    bool usePaper = text.toLowerCase().contains('#paper');
    bool useLetter = text.toLowerCase().contains('#letter');

    // Check for #papernotesall
    bool usePaperNotesAll = text.toLowerCase().contains('#papernotesall');

    // Check for #pynotes
    bool usePyNotes = text.toLowerCase().contains('#pynotes');

    // Check for #textstyles (20 styles showcase)
    bool useTextStyles = text.toLowerCase().contains('#textstyles');

    // Check for #lettervariants
    bool useLetterVariants = text.toLowerCase().contains('#lettervariants');

    // Check for #newletterstyles
    bool useNewLetterStyles = text.toLowerCase().contains('#newletterstyles');

    // Check for #morelettervariants
    bool useMoreLetterVariants = text.toLowerCase().contains('#morelettervariants');

    // Check for #playwritevariants
    bool usePlaywriteVariants = text.toLowerCase().contains('#playwritevariants');

    // Check for #codevariants
    bool useCodeVariants = text.toLowerCase().contains('#codevariants');

    // Check for #pycs
    bool usePythonCheatsheet = text.toLowerCase().contains('#pycs');

    // Check for Dev Test Mode
    if (text.toLowerCase() == '#starttesto1') {
      _startDevTestMode();
      return; 
    }

    // Check for #keywords
    if (text.toLowerCase() == '#keywords') {
      setState(() {
         // User message
        _messages.add(
          ChatMessage(
            isAi: false,
            sender: 'User',
            message: text,
          ),
        );
        // AI Response
        for (var blockList in _generateKeywordsResponse()) {
          _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: blockList,
              ),
            );
        }
      });
      _messageController.clear();
      _scrollToBottom();
      return;
    }

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(
          isAi: false,
          sender: 'You',
          message: text.isNotEmpty
              ? text
              : _getAttachmentSummary(attachmentsCopy),
          pendingAttachments: attachmentsCopy,
        ),
      );
      _messageController.clear();
      _pendingAttachments.clear();
      _isTyping = true;
    });

    // Scroll to bottom
    _scrollToBottom();

    // Simulate AI "thinking" delay (1-2 seconds)
    Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(1000)), () {
      if (mounted) {
        setState(() {
          _isTyping = false;

          if (useAllBlocks) {
            // #all - Show ALL content types in one response
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateAllBlocksResponse(),
              ),
            );
          } else if (usePaperNotesAll) {
            // #papernotesall - Show 5 variants
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generatePaperNotesAllResponse(),
              ),
            );
          } else if (usePyNotes) {
            // #pynotes - Show rich "magazine style" Python tutorial
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generatePyNotesResponse(),
              ),
            );
          } else if (useTextStyles) {
            // #textstyles - Show 20 showcase text blocks
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateTextStylesResponse(),
              ),
            );
          } else if (useLetterVariants) {
             // #lettervariants - Show 10 variants
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateLetterVariantsResponse(),
              ),
            );
          } else if (useNewLetterStyles) {
            // #newletterstyles - Specific requested content
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateNewLetterStylesResponse(),
              ),
            );
          } else if (useMoreLetterVariants) {
             // #morelettervariants - Show 10 NEW variants (10-19)
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateMoreLetterVariantsResponse(),
              ),
            );
          } else if (usePlaywriteVariants) {
             // #playwritevariants - Show 30 Aesthetic Variants
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generatePlaywriteShowcase(),
              ),
            );
          } else if (useCodeVariants) {
             // #codevariants - Show 20 Code/IDE Variants
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateCodeVariantsShowcase(),
              ),
            );
          } else if (usePythonCheatsheet) {
            // #pycs - Python Cheatsheet (3 Varied Responses)
            for (var blockList in _generatePythonCheatsheetResponse()) {
               _messages.add(
                ChatMessage(
                  isAi: true,
                  sender: 'Nexus AI',
                  message: '',
                  contentBlocks: blockList,
                ),
              );
            }
          } else if (useLineChart) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateLineChartResponse(),
              ),
            );
          } else if (useRadarChart) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateRadarChartResponse(),
              ),
            );
          } else if (useProgress) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateProgressResponse(),
              ),
            );
          } else if (useTimeline) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateTimelineResponse(),
              ),
            );
          } else if (useQuiz) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateQuizResponse(),
              ),
            );
          } else if (useChecklist) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateChecklistResponse(),
              ),
            );
          } else if (useTable) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateTableResponse(),
              ),
            );
          } else if (useCarousel) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateCarouselResponse(),
              ),
            );
          } else if (useAudio) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateAudioResponse(),
              ),
            );
          } else if (useVideo) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateVideoResponse(),
              ),
            );
          } else if (useContact) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateContactResponse(),
              ),
            );
          } else if (useEvent) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateEventResponse(),
              ),
            );
          } else if (useActions) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateActionsResponse(),
              ),
            );
          } else if (useWeather) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateWeatherResponse(),
              ),
            );
          } else if (useCountdown) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateCountdownResponse(),
              ),
            );
          } else if (useFlash) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateFlashcardsResponse(),
              ),
            );
          } else if (useBarChart) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateBarChartResponse(),
              ),
            );
          } else if (usePieChart) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generatePieChartResponse(),
              ),
            );
          } else if (useMapBlock) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateMapBlockResponse(),
              ),
            );
          } else if (useCodeBlock) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateCodeBlockResponse(),
              ),
            );
          } else if (useMultiBlock) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: _generateMultiBlockResponse(devImageCount ?? 3),
              ),
            );
          } else if (useNote) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: [
                  AIContentBlock.note(
                    text.replaceAll('#note', '').trim().isEmpty
                        ? 'Don\'t forget to study for the exam tomorrow!'
                        : text.replaceAll('#note', '').trim(),
                  ),
                ],
              ),
            );
          } else if (usePaper) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: [
                  AIContentBlock.paper(
                    text.replaceAll('#paper', '').trim().isEmpty
                        ? 'Chapter 1 Notes:\n\n1. Introduction to Physics\n2. Newton\'s Laws\n3. Kinetic Energy'
                        : text.replaceAll('#paper', '').trim(),
                  ),
                ],
              ),
            );
          } else if (useLetter) {
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: '',
                contentBlocks: [
                  AIContentBlock.letter(
                    text.replaceAll('#letter', '').trim().isEmpty
                        ? 'Dear Student,\n\nWe are pleased to inform you that your application for the advanced research program has been accepted.\n\nSincerely,\nThe Dean'
                        : text.replaceAll('#letter', '').trim(),
                  ),
                ],
              ),
            );
          } else {
            // Standard response (backward compatible)
            _messages.add(
              ChatMessage(
                isAi: true,
                sender: 'Nexus AI',
                message: _generateLoremIpsum(),
                images: devImageCount != null
                    ? _generateTestImages(devImageCount)
                    : _generateSampleImages(),
              ),
            );
          }
        });
        _scrollToBottom();
      }
    });
  }

  /// Dev testing: Generate response with interactive map
  List<AIContentBlock> _generateMapBlockResponse() {
    final blocks = <AIContentBlock>[];
    final random = Random();

    // Sample locations (universities and landmarks)
    final sampleLocations = [
      MapLocation(
        latitude: 28.6139,
        longitude: 77.2090,
        title: 'India Gate, New Delhi',
        description:
            'A historic war memorial located in the heart of New Delhi, India.',
      ),
      MapLocation(
        latitude: 19.0760,
        longitude: 72.8777,
        title: 'Gateway of India, Mumbai',
        description: 'An iconic arch monument overlooking the Arabian Sea.',
      ),
      MapLocation(
        latitude: 12.9716,
        longitude: 77.5946,
        title: 'Vidhana Soudha, Bangalore',
        description: 'The seat of Karnataka\'s state legislature in Bangalore.',
      ),
      MapLocation(
        latitude: 22.5726,
        longitude: 88.3639,
        title: 'Victoria Memorial, Kolkata',
        description: 'A large marble building dedicated to Queen Victoria.',
      ),
      MapLocation(
        latitude: 13.0827,
        longitude: 80.2707,
        title: 'Marina Beach, Chennai',
        description: 'One of the longest urban beaches in the world.',
      ),
    ];

    // Pick a random location
    final location = sampleLocations[random.nextInt(sampleLocations.length)];

    // Intro text
    blocks.add(AIContentBlock.text('Here\'s the location you asked about:'));

    // Map block
    blocks.add(
      AIContentBlock.map(
        mapCenter: location,
        mapMarkers: [location],
        mapZoom: 14.0,
      ),
    );

    // Follow-up text
    blocks.add(
      AIContentBlock.text(
        'You can zoom and pan the map to explore the area. Tap the marker for more details.',
      ),
    );

    return blocks;
  }

  /// Dev testing: Generate response with bar chart
  List<AIContentBlock> _generateBarChartResponse() {
    final blocks = <AIContentBlock>[];

    // Sample data for bar chart (course scores)
    final chartData = [
      ChartDataItem(label: 'Math', value: 85),
      ChartDataItem(label: 'Physics', value: 78),
      ChartDataItem(label: 'Chemistry', value: 92),
      ChartDataItem(label: 'English', value: 88),
      ChartDataItem(label: 'History', value: 74),
    ];

    // Intro text
    blocks.add(
      AIContentBlock.text('Here\'s your performance analysis across subjects:'),
    );

    // Bar chart
    blocks.add(
      AIContentBlock.barChart(
        chartData: chartData,
        chartTitle: 'Subject-wise Scores',
      ),
    );

    // Analysis text
    blocks.add(
      AIContentBlock.text(
        'Chemistry shows your best performance at 92%. Consider focusing more on History to improve your overall average.',
      ),
    );

    return blocks;
  }

  /// Dev testing: Generate response with pie chart
  List<AIContentBlock> _generatePieChartResponse() {
    final blocks = <AIContentBlock>[];

    // Sample data for pie chart (time allocation)
    final chartData = [
      ChartDataItem(label: 'Classes', value: 35),
      ChartDataItem(label: 'Study', value: 25),
      ChartDataItem(label: 'Assignments', value: 20),
      ChartDataItem(label: 'Breaks', value: 12),
      ChartDataItem(label: 'Other', value: 8),
    ];

    // Intro text
    blocks.add(
      AIContentBlock.text('Here\'s how your time is distributed this week:'),
    );

    // Pie chart
    blocks.add(
      AIContentBlock.pieChart(
        chartData: chartData,
        chartTitle: 'Weekly Time Allocation',
      ),
    );

    // Analysis text
    blocks.add(
      AIContentBlock.text(
        'You\'re spending 35% of your time in classes. Consider allocating more time to self-study for better exam preparation.',
      ),
    );

    return blocks;
  }

  /// Dev testing: Generate response with ALL content types (with labels)
  List<AIContentBlock> _generateAllBlocksResponse() {
    return [
      AIContentBlock.text(
        '🎉 ALL AI Response Content Types Showcase\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      ),

      // New Styles
      AIContentBlock.text('📝 NOTE BLOCK  →  #note'),
      AIContentBlock.note("This is a sticky note. Don't forget to buy milk!"),

      AIContentBlock.text('📄 PAPER BLOCK  →  #paper'),
      AIContentBlock.paper(
        "This is a lined paper block.\nIt looks like a notebook page.",
      ),

      AIContentBlock.text('✉️ LETTER BLOCK  →  #letter'),
      AIContentBlock.letter(
        "My Dearest Friend,\n\nI hope this letter finds you well. The weather here has been quite peculiar lately...\n\nSincerely,\nNexus AI",
      ),

      // Bar Chart
      AIContentBlock.text('📊 BAR CHART  →  #bar'),
      AIContentBlock.barChart(
        chartData: [
          ChartDataItem(label: 'Mon', value: 85),
          ChartDataItem(label: 'Tue', value: 72),
          ChartDataItem(label: 'Wed', value: 90),
          ChartDataItem(label: 'Thu', value: 68),
        ],
        chartTitle: 'Weekly Progress',
      ),

      // Pie Chart
      AIContentBlock.text('🥧 PIE CHART  →  #pie'),
      AIContentBlock.pieChart(
        chartData: [
          ChartDataItem(label: 'Study', value: 40),
          ChartDataItem(label: 'Class', value: 30),
          ChartDataItem(label: 'Break', value: 30),
        ],
        chartTitle: 'Time Split',
      ),

      // Line Chart
      AIContentBlock.text('📈 LINE CHART  →  #line'),
      AIContentBlock.lineChart(
        lineData: [
          ChartDataPoint(x: 0, y: 60, label: 'Jan'),
          ChartDataPoint(x: 1, y: 75, label: 'Feb'),
          ChartDataPoint(x: 2, y: 85, label: 'Mar'),
          ChartDataPoint(x: 3, y: 90, label: 'Apr'),
        ],
        chartTitle: 'Grade Trend',
      ),

      // Radar Chart
      AIContentBlock.text('🎯 RADAR CHART  →  #radar'),
      AIContentBlock.radarChart(
        chartData: [
          ChartDataItem(label: 'Math', value: 80),
          ChartDataItem(label: 'Science', value: 70),
          ChartDataItem(label: 'English', value: 90),
          ChartDataItem(label: 'History', value: 65),
          ChartDataItem(label: 'Art', value: 85),
        ],
        chartTitle: 'Skill Radar',
      ),

      // Progress Bars
      AIContentBlock.text('📶 PROGRESS BARS  →  #progress'),
      AIContentBlock.progressBars(
        progressItems: [
          ProgressItem(label: 'Assignment 1', value: 80),
          ProgressItem(label: 'Assignment 2', value: 45),
          ProgressItem(label: 'Project', value: 100),
        ],
        chartTitle: 'Task Progress',
      ),

      // Timeline
      AIContentBlock.text('⏱️ TIMELINE  →  #timeline'),
      AIContentBlock.timeline(
        timelineEvents: [
          TimelineEvent(title: 'Class Start', date: '9:00 AM'),
          TimelineEvent(title: 'Lunch Break', date: '12:00 PM'),
          TimelineEvent(title: 'Lab Session', date: '2:00 PM'),
        ],
      ),

      // Quiz
      AIContentBlock.text('❓ QUIZ  →  #quiz'),
      AIContentBlock.quiz(
        quizData: QuizData(
          question: 'What is 2 + 2?',
          options: ['3', '4', '5', '6'],
          correctIndex: 1,
        ),
      ),

      // Checklist
      AIContentBlock.text('✅ CHECKLIST  →  #checklist'),
      AIContentBlock.checklist(
        checklistItems: [
          ChecklistItem(text: 'Review notes'),
          ChecklistItem(text: 'Complete HW', checked: true),
          ChecklistItem(text: 'Study for exam'),
        ],
        chartTitle: 'To-Do',
      ),

      // Collapsible
      AIContentBlock.text('🔽 COLLAPSIBLE  →  (no keyword)'),
      AIContentBlock.collapsible(
        collapsibleTitle: 'Click to expand details',
        collapsibleContent:
            'This is the hidden content that appears when you tap on the header! Great for FAQs or additional info.',
      ),

      // Data Table
      AIContentBlock.text('📋 DATA TABLE  →  #table'),
      AIContentBlock.dataTable(
        tableData: TableData(
          headers: ['Subject', 'Grade', 'Credits'],
          rows: [
            ['Math', 'A', '4'],
            ['Physics', 'B+', '3'],
            ['English', 'A-', '3'],
          ],
        ),
        chartTitle: 'Grades',
      ),

      // Carousel
      AIContentBlock.text('🎠 CARDS CAROUSEL  →  #cards'),
      AIContentBlock.carousel(
        carouselItems: [
          InfoCard(
            title: 'Physics 101',
            subtitle: 'Room 204',
            icon: Icons.science,
          ),
          InfoCard(
            title: 'Math 201',
            subtitle: 'Room 105',
            icon: Icons.calculate,
          ),
          InfoCard(
            title: 'English 101',
            subtitle: 'Room 302',
            icon: Icons.book,
          ),
        ],
      ),

      // Audio Player
      AIContentBlock.text('🎵 AUDIO PLAYER  →  #audio'),
      AIContentBlock.audioPlayer(
        mediaUrl: 'lecture.mp3',
        mediaTitle: 'Lecture Recording',
        mediaDuration: const Duration(minutes: 45),
      ),

      // Video Player
      AIContentBlock.text('🎬 VIDEO PLAYER  →  #video'),
      AIContentBlock.videoPlayer(
        mediaUrl: 'tutorial.mp4',
        mediaTitle: 'Video Tutorial',
      ),

      // File Attachment
      AIContentBlock.text('📎 FILE ATTACHMENT  →  (no keyword)'),
      AIContentBlock.fileAttachment(
        mediaUrl: 'notes.pdf',
        mediaTitle: 'Study_Notes.pdf',
      ),

      // Voice Message
      AIContentBlock.text('🎤 VOICE MESSAGE  →  (no keyword)'),
      AIContentBlock.voiceMessage(mediaDuration: const Duration(seconds: 32)),

      // Quick Actions
      AIContentBlock.text('⚡ QUICK ACTIONS  →  #actions'),
      AIContentBlock.quickActions(
        actionButtons: [
          ActionButton(
            label: 'Calendar',
            icon: Icons.calendar_today,
            color: const Color(0xFF3B82F6),
          ),
          ActionButton(
            label: 'Reminder',
            icon: Icons.alarm,
            color: const Color(0xFFF59E0B),
          ),
          ActionButton(
            label: 'Share',
            icon: Icons.share,
            color: const Color(0xFF10B981),
          ),
        ],
      ),

      // Contact Card
      AIContentBlock.text('👤 CONTACT CARD  →  #contact'),
      AIContentBlock.contactCard(
        contactData: ContactData(
          name: 'Prof. Johnson',
          role: 'Mathematics',
          phone: '+1234567890',
          email: 'prof.j@edu.com',
        ),
      ),

      // Calendar Event
      AIContentBlock.text('📅 CALENDAR EVENT  →  #event'),
      AIContentBlock.calendarEvent(
        eventData: CalendarEventData(
          title: 'Final Exam',
          date: 'Jan 28',
          time: '10:00 AM',
          location: 'Hall A',
        ),
      ),

      // Math Equation
      AIContentBlock.text('🧮 MATH EQUATION  →  (no keyword)'),
      AIContentBlock.mathEquation(mathEquation: 'E = mc² + ∫f(x)dx'),

      // Weather
      AIContentBlock.text('🌤️ WEATHER WIDGET  →  #weather'),
      AIContentBlock.weather(
        weatherData: WeatherData(
          location: 'Campus',
          temperature: 24,
          condition: 'Sunny',
          icon: Icons.wb_sunny,
        ),
      ),

      // Countdown
      AIContentBlock.text('⏳ COUNTDOWN TIMER  →  #countdown'),
      AIContentBlock.countdown(
        countdownData: CountdownData(
          title: 'Exam in...',
          targetDate: DateTime.now().add(const Duration(days: 5)),
        ),
      ),

      // Flashcards
      AIContentBlock.text('🃏 FLASHCARDS  →  #flash'),
      AIContentBlock.flashcards(
        flashcards: [
          FlashcardData(front: 'H₂O', back: 'Water molecule'),
          FlashcardData(front: 'F = ma', back: 'Force = mass × acceleration'),
        ],
      ),

      // PDF Preview
      AIContentBlock.text('📄 PDF PREVIEW  →  (no keyword)'),
      AIContentBlock.pdfPreview(
        mediaUrl: 'syllabus.pdf',
        mediaTitle: 'Course Syllabus',
      ),

      // Map (separate keyword)
      AIContentBlock.text('🗺️ MAP  →  #map'),

      // Code Block (separate keyword)
      AIContentBlock.text('💻 CODE BLOCK  →  #code'),

      // Note Block
      AIContentBlock.text('📝 STICKY NOTE → #note'),
      AIContentBlock.note('Don\'t forget: Exam tomorrow at 9 AM!'),

      // Paper Block
      AIContentBlock.text('📓 LINED PAPER → #paper'),
      AIContentBlock.paper(
        'History Notes:\n- World War II started in 1939\n- Ended in 1945\n- Major powers: Allies vs Axis',
      ),

      // Letter Block
      AIContentBlock.text('📜 VINTAGE LETTER → #letter'),
      AIContentBlock.letter(
        'Dear Student,\n\nCongratulations on your excellent performance this semester. Keep up the great work!\n\nBest,\nDean of Students',
      ),

      AIContentBlock.text(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n✨ Total: 27 content types!\nUse individual #keywords to test each one.',
      ),
      AIContentBlock.text(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n✨ Total: 27 content types!\nUse individual #keywords to test each one.',
      ),
    ];
  }

  /// Dev testing: Generate response with 5 variants of Note, Paper, and Letter
  List<AIContentBlock> _generatePaperNotesAllResponse() {
    return [
      AIContentBlock.text('📝 NOTES SHOWCASE (5 Styles)\n━━━━━━━━━━━━━━━━'),
      AIContentBlock.note('Variant 0: Default Yellow', variant: 0),
      AIContentBlock.note('Variant 1: Pink', variant: 1),
      AIContentBlock.note('Variant 2: Blue', variant: 2),
      AIContentBlock.note('Variant 3: Green', variant: 3),
      AIContentBlock.note('Variant 4: Orange', variant: 4),

      AIContentBlock.text('📄 PAPER SHOWCASE (5 Styles)\n━━━━━━━━━━━━━━━━'),
      AIContentBlock.paper('Variant 0: Standard Lined', variant: 0),
      AIContentBlock.paper('Variant 1: Grid / Graph', variant: 1),
      AIContentBlock.paper('Variant 2: Legal Pad', variant: 2),
      AIContentBlock.paper('Variant 3: Blueprint', variant: 3),
      AIContentBlock.paper('Variant 4: Dot Grid', variant: 4),

      AIContentBlock.text('✉️ LETTER SHOWCASE (5 Styles)\n━━━━━━━━━━━━━━━━'),
      AIContentBlock.letter('Variant 0: Parchment', variant: 0),
      AIContentBlock.letter('Variant 1: Royal / Formal', variant: 1),
      AIContentBlock.letter('Variant 2: Love Letter', variant: 2),
      AIContentBlock.letter('Variant 3: Ancient', variant: 3),
      AIContentBlock.letter('Variant 4: Dark / Mysterious', variant: 4),
    ];
  }

  /// Dev testing: Generate structured "magazine style" Python tutorial
  List<AIContentBlock> _generatePyNotesResponse() {
    return [
      // --- HEADER & INTRO ---
      AIContentBlock.text('# 🐍 The Pythonic Way\n*A Journey into Clean Code*'),

      AIContentBlock.letter(
        'To the Aspiring Developer,\n\nLong ago, in the late 1980s, a man named Guido van Rossum set out to create a language that was not only powerful, but beautiful to read. He named it "Python," not after the snake, but after the British comedy troupe "Monty Python\'s Flying Circus".\n\nToday, we embark on a quest to master its elegance.\n\nYours in Code,\nNexus AI',
        variant: 3,
      ), // Ancient variant

      AIContentBlock.note(
        '💡 FUN FACT:\nPython uses indentation to define code blocks instead of curly braces {} like C++ or Java. This forces you to write clean, readable code!',
        variant: 4,
      ), // Orange variant (Highlight)
      // --- THEORY SECTION ---
      AIContentBlock.text('## ONE: The Basics'),

      AIContentBlock.paper(
        'CONCEPT: VARIABLES\n\nThink of a variable as a labeled box where you store data.\n\nname = "Alice"  <-- The Box Label\n\nInside the box is the string "Alice".\n\nWe can change what\'s in the box:\nname = "Bob"',
        variant: 2,
      ), // Legal Pad variant

      AIContentBlock.text('### Control Flow Logic:'),
      AIContentBlock.markdown(markdownContent: '''
```mermaid
graph TD;
    A[Start] --> B{Is Hungry?};
    B -- Yes --> C[Eat Pizza];
    B -- No --> D[Code Python];
    C --> D;
    D --> E[Sleep];
```
'''),

      // --- CODE SECTION ---
      AIContentBlock.text('## TWO: The Blueprint'),

      AIContentBlock.paper(
        'SPECIFICATION: GUESSING GAME\n\nObjective: The computer picks a random number. The user guesses it.\n\nRequirements:\n1. Import random module\n2. Generate number 1-10\n3. Loop until correct',
        variant: 3,
      ), // Blueprint variant

      AIContentBlock.code('''import random

secret_number = random.randint(1, 10)
guess = None

print("I am thinking of a number between 1 and 10.")

while guess != secret_number:
    guess = int(input("Take a guess: "))
    
    if guess < secret_number:
        print("Too low!")
    elif guess > secret_number:
        print("Too high!")
    else:
        print("You got it!")''', language: 'python'),

      // --- VISUAL SUMMARY ---
      AIContentBlock.text('## THREE: Key Takeaways'),

      AIContentBlock.carousel(
        carouselItems: [
          InfoCard(
            title: 'Readability',
            subtitle: 'Clean & Clear',
            description: 'Code is read more often than it is written.',
            icon: Icons.visibility,
            color: Colors.blue,
          ),
          InfoCard(
            title: 'Batteries Included',
            subtitle: 'Standard Lib',
            description: 'Huge library of pre-built tools for everything.',
            icon: Icons.battery_charging_full,
            color: Colors.green,
          ),
          InfoCard(
            title: 'Community',
            subtitle: 'Massive Support',
            description: 'Millions of devs ready to help you learn.',
            icon: Icons.group,
            color: Colors.orange,
          ),
        ],
      ),

      AIContentBlock.note(
        '📝 HOMEWORK:\n1. Install Python from python.org\n2. Write a script to print your name 100 times!\n3. Have fun!',
        variant: 1,
      ), // Pink variant (Urgent/Action)
    ];
  }

  List<AIContentBlock> _generateTextStylesResponse() {
    return [
      AIContentBlock.text(
        'Here is a showcase of 20 distinct text styles for Typography, Readability, and Structure:',
        variant: 0,
      ),

      // 1. Modern Minimal
      AIContentBlock.text(
        '1. Modern Minimal\nClean, light weight, wide letter spacing. Ideal for modern UI aesthetics.',
        variant: 1,
      ),

      // 2. Classic Serif
      AIContentBlock.text(
        '2. Classic Serif\nTraditional, elegant, and trustworthy. Uses Georgia font on a cream background.',
        variant: 2,
      ),

      // 3. Terminal
      AIContentBlock.text(
        '3. Terminal / Code\n> SYSTEM_READY\n> EXECUTE_PROTOCOL_7\nMonospaced, green on black. Perfect for logs and technical output.',
        variant: 3,
      ),

      // 4. Editorial
      AIContentBlock.text(
        '4. Editorial Quote\n"Design is not just what it looks like and feels like. Design is how it works."\n- Steve Jobs',
        variant: 4,
      ),

      // 5. Handwritten
      AIContentBlock.text(
        '5. Handwritten Note\nJust a quick reminder to pick up groceries and call mom later!',
        variant: 5,
      ),

      // 6. Bold Headline
      AIContentBlock.text('6. BOLD HEADLINE STYLE', variant: 6),

      // 7. Technical/Blue
      AIContentBlock.text(
        '7. Technical Log\nScanning system architecture...\nOptimization complete. Latency reduced by 14%.',
        variant: 7,
      ),

      // 8. Neon
      AIContentBlock.text('8. NEON NIGHTS\nGlowing text effect.', variant: 8),

      // 9. Typewriter
      AIContentBlock.text(
        '9. Vintage Typewriter\nThe quick brown fox jumps over the lazy dog.\nCourier New font for a retro feel.',
        variant: 9,
      ),

      // 10. Review/Quote
      AIContentBlock.text(
        '10. Review Block\nAn absolute masterpiece of design and functionality. Five stars.',
        variant: 10,
      ),

      // 11. Warning
      AIContentBlock.text(
        '11. Warning Alert\nCaution: Unsaved changes will be lost if you proceed without saving.',
        variant: 11,
      ),

      // 12. Success
      AIContentBlock.text(
        '12. Success Message\nOperation completed successfully. All files have been uploaded.',
        variant: 12,
      ),

      // 13. Info
      AIContentBlock.text(
        '13. Information Panel\nDid you know? You can swipe left on messages to see timestamp details.',
        variant: 13,
      ),

      // 14. Luxury
      AIContentBlock.text(
        '14. Luxury / Premium\nExclusive member benefits unlocked. Welcome to the elite circle.',
        variant: 14,
      ),

      // 15. Brutalism
      AIContentBlock.text(
        '15. BRUTALIST\nRAW. UNFILTERED. BOLD.',
        variant: 15,
      ),

      // 16. Pastel
      AIContentBlock.text(
        '16. Soft Pastel\nGentle, calming colors for a stress-free reading experience.',
        variant: 16,
      ),

      // 17. Accessibility
      AIContentBlock.text(
        '17. High Contrast\nMaximum readability for accessibility compliance.',
        variant: 17,
      ),

       // 18. Retro Computer
      AIContentBlock.text(
         '18. Retro BIOS\nInitializing memory...\n640K RAM OK.',
         variant: 18,
      ),

      // 19. Blueprint
      AIContentBlock.text(
         '19. Blueprint Spec\nwidth: 100%;\nheight: auto;\ndisplay: flex;',
         variant: 19,
      ),
      
      AIContentBlock.text('End of Showcase.', variant: 0),
    ];
  }

  List<AIContentBlock> _generateLetterVariantsResponse() {
    return [
       AIContentBlock.text('Here are the 10 distinct Letter Block variants:', variant: 0),
       
       AIContentBlock.text('Variant 0: Standard (Default)'),
       AIContentBlock.letter('This is the standard letter style. Simple, elegant, and timeless.', variant: 0),

       AIContentBlock.text('Variant 1: Royal'),
       AIContentBlock.letter('To His Majesty,\n\nWe are pleased to announce the arrival of the golden carriage.', variant: 1),

       AIContentBlock.text('Variant 2: Love'),
       AIContentBlock.letter('My Dearest,\n\nRoses are red, violets are blue, this letter style is pink for you.', variant: 2),

       AIContentBlock.text('Variant 3: Ancient'),
       AIContentBlock.letter('From the Archives:\n\nThis parchment dates back to the third era of the kingdom.', variant: 3),

       AIContentBlock.text('Variant 4: Dark Mode'),
       AIContentBlock.letter('Classified Protocol:\n\nOperation Nightfall is a go. Maintain radio silence.', variant: 4),

       AIContentBlock.text('Variant 5: Cyber / Holographic'),
       AIContentBlock.letter('// SYSTEM_MESSAGE\n\n> CONNECTION_ESTABLISHED\n> UPLOADING_DATA_PACKET...', variant: 5),

       AIContentBlock.text('Variant 6: Formal / Diplomatic'),
       AIContentBlock.letter('To Whom It May Concern,\n\nThis document certifies the agreement between the parties.', variant: 6),

       AIContentBlock.text('Variant 7: Natural / Eco'),
       AIContentBlock.letter('Nature Note:\n\nPlease recycle this paper after reading. Save the trees!', variant: 7),

       AIContentBlock.text('Variant 8: Urgent / Redacted'),
       AIContentBlock.letter('WARNING:\n\nThis message contains sensitive information. DO NOT SHARE.', variant: 8),

       AIContentBlock.text('Variant 9: Magic / Mystic'),
       AIContentBlock.letter('A Wizard\'s Scroll:\n\nThe stars align tonight for the great summoning.', variant: 9),
    ];
  }

  List<AIContentBlock> _generateNewLetterStylesResponse() {
    return [
      AIContentBlock.text('🔥 ERROR 404 EXPLANATION (Variant 8 - Urgent/Redacted)'),
      AIContentBlock.letter(
        'ERROR 404: RESOURCE NOT FOUND\n\nThe requested URL was not found on this server. This implies a broken link or removed content.\n\nPlease verify your connection settings and check the destination path immediately. Do not ignore this critical system warning as data loss may occur.',
        variant: 8,
      ),

      AIContentBlock.text('🌿 REDUCING CARBON EMISSIONS (Variant 7 - Natural/Eco)'),
      AIContentBlock.letter(
        'Towards a Greener Future:\n\nReducing carbon emissions is the defining challenge of our time, requiring a harmonious blend of individual responsibility and systemic change. We must aggressively transition from fossil fuels to renewable energy sources like wind, solar, and hydroelectric power. Simultaneously, protecting our existing forests and planting new ones is vital, as they serve as the planet\'s lungs, absorbing excess carbon dioxide.\n\nOn a personal level, we can contribute by reducing energy consumption, minimizing waste, and opting for sustainable transportation. Every small action—from recycling to choosing local produce—creates a ripple effect. Together, these efforts weave a cleaner, more resilient future for our planet.',
        variant: 7,
      ),

      AIContentBlock.text('📜 FREEDOM OF SPEECH (Variant 6 - Formal/Diplomatic)'),
      AIContentBlock.letter(
        'Declaration on Freedom of Speech:\n\nFreedom of speech is a fundamental human right, serving as the cornerstone of a democratic society. It grants individuals the liberty to express their opinions, beliefs, and ideas without fear of government retaliation, censorship, or societal sanction. This freedom fosters an open marketplace of ideas where truth can emerge from debate and where diverse perspectives can coexist.\n\nHowever, this right is not absolute. It carries with it the responsibility to respect the rights and reputations of others. Speech that incites violence, defamation, or hatred is often subject to legal limitations to ensure the safety and cohesiveness of the community. Navigating these boundaries is a complex challenge for any nation.\n\nIn the digital age, the dialogue around free speech has evolved, extending into online spaces where information travels instantly. Protecting this right requires vigilant defense against suppression while acknowledging the need for civil discourse. Ultimately, freedom of speech empowers citizens to hold power accountable, advocate for change, and participate fully in the governance of their society.',
        variant: 6,
      ),
    ];
  }

  List<AIContentBlock> _generateMoreLetterVariantsResponse() {
    return [
      AIContentBlock.text('🎨 10 NEW HANDWRITTEN & PLAYFUL VARIANTS'),
      
      AIContentBlock.text('Variant 10: Playful Sticky'),
      AIContentBlock.letter('Don\'t forget the meeting at 3 PM! Bring donuts! 🍩', variant: 10),

      AIContentBlock.text('Variant 11: Academic Notebook'),
      AIContentBlock.letter('Physics Notes:\nE = mc² implies that mass and energy are interchangeable. fascinating!', variant: 11),

      AIContentBlock.text('Variant 12: Dev Sketch'),
      AIContentBlock.letter('// TODO: Refactor the login module.\n// It\'s a bit messy right now.', variant: 12),

      AIContentBlock.text('Variant 13: Corporate Note'),
      AIContentBlock.letter('To the Board:\n\nQ3 projections look promising. We should proceed with the merger.', variant: 13),

      AIContentBlock.text('Variant 14: Learner Flashcard'),
      AIContentBlock.letter('VOCABULARY:\n\nSerendipity (n.)\nThe occurrence of events by chance in a happy way.', variant: 14),

      AIContentBlock.text('Variant 15: Tech Blueprint'),
      AIContentBlock.letter('ARCHITECTURE DRAFT:\n\nClient -> API Gateway -> Microservices -> Database', variant: 15),

      AIContentBlock.text('Variant 16: Journal Entry'),
      AIContentBlock.letter('Dear Diary,\n\nToday I learned about Flutter animations. They are smoother than I expected.', variant: 16),

      AIContentBlock.text('Variant 17: Code Review'),
      AIContentBlock.letter('CRITICAL:\n\nLine 42 causes a memory leak. Please fix before deploying.', variant: 17),

      AIContentBlock.text('Variant 18: Brainstorming'),
      AIContentBlock.letter('IDEAS:\n- App for cats\n- AI that writes poetry\n- Uber for pigeons', variant: 18),

      AIContentBlock.text('Variant 19: Love Note (Modern)'),
      AIContentBlock.letter('Thinking of you...\n\nCan\'t wait to see you this weekend! ❤️', variant: 19),
    ];
  }

  List<AIContentBlock> _generatePlaywriteShowcase() {
    return [
      AIContentBlock.text('🖋️ PLAYWRITE AESTHETIC COLLECTION\nTwo-font combinations • Institutional, Academic, Study, Programming'),
      
      // --- GROUP 1: SHORT (10-20 words) ---
      AIContentBlock.text('SHORT FORM (10-20 Words)'),
      
      AIContentBlock.letter('UNIVERSITY NOTICE\n\nLibrary hours extended until midnight for finals week. Study hard!', variant: 20),
      AIContentBlock.letter('CS101 REMINDER\n\nDon\'t forget to submit your Python assignment by Friday 11:59 PM.', variant: 21),
      AIContentBlock.letter('LAB SAFETY\n\nSafety goggles must be worn at all times near chemicals. No exceptions.', variant: 22),
      AIContentBlock.letter('DEAN\'S LIST\n\nCongratulations on achieving a 4.0 GPA this semester. Keep it up!', variant: 23),
      AIContentBlock.letter('HACKATHON ALERT\n\nJoin us this weekend for 48 hours of coding, pizza, and prizes.', variant: 24),
      AIContentBlock.letter('STUDY GROUP\n\nMeeting at the quad @ 2 PM. Bringing flashcards for Biology.', variant: 25),
      AIContentBlock.letter('SYSADMIN LOG\n\nServer maintenance scheduled for 3 AM. Expect brief downtime.', variant: 26),
      AIContentBlock.letter('RESEARCH GRANT\n\nYour proposal for "AI in Education" has been approved for funding.', variant: 27),
      AIContentBlock.letter('EXAM TIP\n\nFocus on Chapter 4: Thermodynamics. It will be 40% of the test.', variant: 28),
      AIContentBlock.letter('WELCOME FRESHMEN\n\nOrientation begins in the main hall. Grab your welcome packet!', variant: 29),

      // --- GROUP 2: MEDIUM (20-50 words) ---
      AIContentBlock.text('MEDIUM FORM (20-50 Words)'),

      AIContentBlock.letter('DEPARTMENT OF COMPUTER SCIENCE\n\nTo all students: The new AI laboratory on the 3rd floor is now open. It features high-performance GPUs for deep learning projects. Please reserve your slot online before visiting.', variant: 30),
      AIContentBlock.letter('HISTORY OF ART STUDY GUIDE\n\nRemember that the Renaissance was not just about art, but a rebirth of classical learning. Pay attention to the shift from medieval scholasticism to humanism. Key figures: da Vinci, Michelangelo, Raphael.', variant: 31),
      AIContentBlock.letter('INTERNSHIP OPPORTUNITY\n\nTechCorp is looking for junior developers. If you know React and Flutter, send your resume to careers@techcorp.com. This is a paid 3-month summer position with a chance for full-time employment.', variant: 32),
      AIContentBlock.letter('CAMPUS SUSTAINABILITY PLEDGE\n\nWe are committed to reducing our carbon footprint. Please use the recycling bins provided in every classroom. Single-use plastics are banned from the cafeteria starting next month. Let\'s go green!', variant: 33),
      AIContentBlock.letter('ALGORITHM ANALYSIS\n\nWhen optimizing your sorting algorithm, consider the time complexity. QuickSort is O(n log n) on average, but degrades to O(n²) in worst-case scenarios. MergeSort is a safer bet for consistent performance.', variant: 34),
      AIContentBlock.letter('PHILOSOPHY 101\n\n"I think, therefore I am." - Descartes. elaborate on this statement. Does existence precede essence, or is it the other way around? Submit your 2-page reflection by Monday morning.', variant: 35),
      AIContentBlock.letter('CODE CONDUCT\n\nRespect your peers in code reviews. Constructive criticism helps us grow, but harsh words discourage innovation. Always suggest a better way rather than just pointing out the flaw.', variant: 36),
      AIContentBlock.letter('BIOLOGY FIELD TRIP\n\nWe depart for the botanical gardens at 8:00 AM sharp. Bring a notebook, a pen, and a packed lunch. We will be identifying native plant species for the term project.', variant: 37),
      AIContentBlock.letter('DATA SECURITY MEMO\n\nNever commit API keys to public repositories. Use environment variables (.env) and add them to your .gitignore file. A leaked key can compromise the entire infrastructure within minutes.', variant: 38),
      AIContentBlock.letter('LIBRARY POLICY UPDATE\n\nQuiet zones are strictly enforced on floors 4 and 5. Group study rooms must be booked in advance. Please return all borrowed books to the front desk or the automated drop box.', variant: 39),

      // --- GROUP 3: LONG (200 words) ---
      AIContentBlock.text('LONG FORM (~200 Words)'),

      AIContentBlock.letter('ACADEMIC INTEGRITY POLICY\n\nPlagiarism is a serious offense in the academic world. It undermines the value of your degree and the trust placed in you by the institution. When you cite sources, you acknowledge the intellectual debt you owe to those who came before you. It is not merely a rule to follow, but a practice of honesty and respect.\n\nIn the age of AI, the temptation to generate essays is high. However, true learning comes from the struggle to articulate your own thoughts. Use tools to assist, not replace, your critical thinking. If you are caught submitting work that is not your own, you face sanctions ranging from a failing grade to expulsion.\n\nWe uphold these standards to ensure that every graduate of this university represents the highest caliber of knowledge and ethics. Your integrity is your most valuable asset. Protect it fiercely.', variant: 40),
      
      AIContentBlock.letter('THE ART OF PROGRAMMING\n\nProgramming is often called a science, but it is equally an art. Like a poet chooses words to evoke emotion, a programmer chooses logic to evoke action. A well-written function is elegant, concise, and serves a singular purpose. It flows logically, guiding the reader—be it a machine or another human—through its intent without confusion.\n\nSpaghetti code, on the other hand, is chaos. It is the result of rushing, of patching without understanding, of neglecting the structure for the sake of the output. As you progress in your career, you will learn that writing code that works is the easy part. Writing code that is maintainable, readable, and scalable is the true challenge.\n\nTake pride in your craft. Comment your complex logic, refactor correctly, and never stop learning. The landscape of technology changes daily, but the principles of clean code remain timeless.', variant: 41),
      
      AIContentBlock.letter('STUDY TECHNIQUES FOR RETENTION\n\nCramming is the enemy of long-term retention. To truly master a subject, one must employ active recall and spaced repetition. Passive reading—glancing over notes expecting them to stick—is the least effective method of study. Instead, close the book and try to explain the concept to an empty chair.\n\nIf you cannot explain it simply, you do not understand it well enough. Use flashcards for facts, but use mind maps for connections. Sleep is also a crucial part of the learning process; it is during deep sleep that the brain consolidates short-term memories into long-term ones.\n\nPlan your study schedule backwards from the exam date. Break large topics into manageable chunks. And remember to take breaks—the Pomodoro technique suggests 25 minutes of focus followed by 5 minutes of rest. Your brain needs this downtime to process information.', variant: 42),
      
      AIContentBlock.letter('INSTITUTIONAL HISTORY\n\nFounded in 1895, this institution began as a small vocational school with just three classrooms. It has since grown into a premier research university, home to five Nobel laureates and countless pioneers in their fields. The original brick building, Old Main, still stands at the center of campus as a testament to our enduring legacy.\n\nOver the decades, we have weathered wars, economic depressions, and social upheavals, always remaining a beacon of light and learning. Our motto, "Veritas et Lux" (Truth and Light), guides every decision we make. We believe that education is the key to unlocking human potential and solving the world\'s most pressing problems.\n\nAs you walk these halls, remember that you walk in the footsteps of giants. You are part of a tradition that stretches back over a century. Contribute to it, honor it, and leave your own mark for future generations.', variant: 43),
      
      AIContentBlock.letter('THE FUTURE OF AI IN ACADEMIA\n\nArtificial Intelligence is reshaping the landscape of education. From personalized tutors that adapt to a student\'s learning pace to sophisticated research tools that analyze vast datasets in seconds, the potential is limitless. However, we must approach this integration with caution.\n\nWe must ensure that AI serves to augment human intelligence, not replace it. Critical thinking, creativity, and empathy are skills that algorithms cannot replicate. The classroom of the future will not be a room of students staring at screens, but a collaborative space where AI handles the rote memorization, freeing humans to debate, create, and innovate.\n\nWe are preparing students not just for the jobs of today, but for a future we can specifically imagine. Adaptability is the new literacy. Embrace these tools, understand their limitations, and use them to build a better world.', variant: 44),
      
      AIContentBlock.letter('DEBUGGING MANIFESTO\n\nDebugging is twice as hard as writing the code in the first place. Therefore, if you write the code as cleverly as possible, you are, by definition, not smart enough to debug it. - Brian Kernighan.\n\nWhen you encounter a bug, do not panic. It is simply the computer doing exactly what you told it to do, not what you wanted it to do. Isolate the variable. Check your assumptions. Print the state. Walk away for five minutes.\n\nRubber duck debugging works: explain your code line-by-line to an inanimate object. You will often find the error in your own explanation. Remember, every error is a lesson. A cleanly solved bug is a heavy lift for your understanding of the system. Embrace the red text, for it leads to the green checkmark.', variant: 45),
      
      AIContentBlock.letter('SEMESTER SYLLABUS OVERVIEW\n\nThis course is designed to challenge your understanding of macroeconomics. We will begin with the fundamental principles of supply and demand, moving quickly into fiscal policy, monetary theory, and international trade. There will be three midterms and one cumulative final exam.\n\nParticipation is mandatory. Economics is not a spectator sport; it requires engagement, debate, and the application of theory to real-world scenarios. Read the Wall Street Journal daily. Come to class prepared to discuss current events through the lens of economic theory.\n\nOffice hours are open to all. Do not wait until you are drowning to ask for a life raft. I am here to help you succeed, but you must take the first step. Let us make this a productive and enlightening semester.', variant: 46),
      
      AIContentBlock.letter('LABORATORY PROTOCOL v2.0\n\nSafety is our top priority. Before entering the lab, verify that you are wearing closed-toe shoes, long pants, and a lab coat. Long hair must be tied back. No food or drink is permitted in the lab area under any circumstances.\n\nWhen handling volatile substances, work exclusively under the fume hood. Label every beaker and test tube clearly with the contents, date, and your initials. Unlabeled chemicals are a hazard to everyone. In the event of a spill, alert the instructor immediately; do not attempt to clean it up yourself.\n\nDispose of chemical waste in the designated containers, never down the drain. Wash your hands thoroughly before leaving. Your compliance ensures that we can all continue to learn and discover in a safe environment.', variant: 47),
      
      AIContentBlock.letter('ETHICS IN ENGINEERING\n\nAs engineers, we hold the safety of the public in our hands. A bridge designed poorly can collapse; software with a loophole can be exploited; a medical device that fails can costs lives. Technical competence is only half the job; ethical responsibility is the other half.\n\nWe must refuse to cut corners. We must speak up when we see unsafe practices. We must consider the environmental and societal impact of our designs. The Code of Ethics is not just a document to memorize for the exam; it is a vow to society.\n\nWhen you design, ask yourself: Would I feel safe using this? Would I want my family to use this? If the answer is no, go back to the drawing board. Determine the right thing to do, and then do it, even if it is the harder path.', variant: 48),
      
      AIContentBlock.letter('FINAL THESIS GUIDELINES\n\nYour thesis is the culmination of your undergraduate journey. It is an opportunity to contribute original thought to your field of study. Choose a topic that ignites your curiosity, for you will be living with it for the next year.\n\nStart with a strong thesis statement. Conduct rigorous research, citing primary sources wherever possible. Structure your argument logically, leading the reader from premise to conclusion. Revise, revise, revise. Good writing is rewriting.\n\nMeet with your advisor regularly. They are your guide through the wilderness of academic research. Do not fear feedback; welcome it. It makes your work stronger. This document will live in the university archives long after you graduate. Make it something you are proud of.', variant: 49),
    ];
  }



  List<AIContentBlock> _generateCodeVariantsShowcase() {
    return [
      AIContentBlock.text('💻 CODE & IDE THEME COLLECTION\n20 Developer-Focused Variants (50-69)'),
      
      AIContentBlock.letter('// VS Code Dark (Default)\nfunction init() {\n  console.log("Hello World");\n}', variant: 50),
      AIContentBlock.letter('# Dracula Theme\nbody {\n  background-color: #282a36;\n  color: #f8f8f2;\n}', variant: 51),
      AIContentBlock.letter('"""Monokai Classic"""\nclass User:\n    def __init__(self, name):\n        self.name = name', variant: 52),
      AIContentBlock.letter('// Solarized Dark\nvar solarized = true;\nif (solarized) {\n  return "Eye Comfort";\n}', variant: 53),
      AIContentBlock.letter('// Solarized Light\n// Good for bright environments\nlet contrast = "low";', variant: 54),
      AIContentBlock.letter('# GitHub Dark\ngit commit -m "Initial commit"\ngit push origin main', variant: 55),
      AIContentBlock.letter('// GitHub Light\n// Classic open source feel\nconst repo = "scduleme";', variant: 56),
      AIContentBlock.letter('> MATRIX TERMINAL\n> WAKE UP NEO...\n> FOLLOW THE WHITE RABBIT.', variant: 57),
      AIContentBlock.letter('\$ RETRO AMBER CRT\n\$ sudo apt-get update\n\$ installing packages...', variant: 58),
      AIContentBlock.letter('PS C:\\> PowerShell\nGet-Process | Where-Object {\$_.CPU -gt 10}\n# System Administration', variant: 59),
      AIContentBlock.letter('user@ubuntu:~\$ \n# Ubuntu Terminal\nsudo service nginx restart\n[OK] Service started.', variant: 60),
      AIContentBlock.letter('/* HIGH CONTRAST */\ndisplay: block;\nvisibility: visible;\n// Maximum readability', variant: 61),
      AIContentBlock.letter('// CYBERPUNK 2077\nNET_RUNNER_INTERFACE_V2\nSTATUS: CONNECTED\nSIGNAL: 100%', variant: 62),
      AIContentBlock.letter('<!-- BLUEPRINT -->\n<div class="wireframe">\n  <header>Prototype</header>\n</div>', variant: 63),
      AIContentBlock.letter('Sublime Text (Molokai)\nimport "fmt"\nfunc main() {\n\tfmt.Println("Speed")\n}', variant: 64),
      AIContentBlock.letter('// Atom One Dark\nconst atom = "Discontinued";\nconsole.warn(atom);', variant: 65),
      AIContentBlock.letter('/* Nord Theme */\n.arctic {\n  color: #D8DEE9;\n  background: #2E3440;\n}', variant: 66),
      AIContentBlock.letter('Gruvbox Style\nlet warm_tone = true;\n// Retro groove aesthetic', variant: 67),
      AIContentBlock.letter('// SYNTHWAVE \'84\nconst neon = "GLOWING";\n// Retrowave vibes only', variant: 68),
      AIContentBlock.letter('// Cobalt 2\nconst wes_bos = true;\n// Deep blue hues', variant: 69),
    ];
  }

  List<List<AIContentBlock>> _generateKeywordsResponse() {
    return [
      [
        AIContentBlock.text('🔍 **AVAILABLE KEYWORDS**\nTap any button to execute the command.'),
        
        // VISUALIZATIONS
        AIContentBlock.text('📊 **Data Visualizations**'),
        AIContentBlock.quickActions(actionButtons: [
          ActionButton(label: 'Bar Chart', icon: Icons.bar_chart, action: '#bar', color: Colors.blue),
          ActionButton(label: 'Pie Chart', icon: Icons.pie_chart, action: '#pie', color: Colors.purple),
          ActionButton(label: 'Line Chart', icon: Icons.show_chart, action: '#line', color: Colors.green),
          ActionButton(label: 'Radar Chart', icon: Icons.radar, action: '#radar', color: Colors.orange),
        ]),

        // INTERACTIVE
        AIContentBlock.text('✨ **Interactive Elements**'),
        AIContentBlock.quickActions(actionButtons: [
          ActionButton(label: 'Quiz', icon: Icons.quiz, action: '#quiz', color: Colors.amber),
          ActionButton(label: 'Checklist', icon: Icons.checklist, action: '#checklist', color: Colors.teal),
          ActionButton(label: 'Table', icon: Icons.table_chart, action: '#table', color: Colors.indigo),
          ActionButton(label: 'Cards', icon: Icons.view_carousel, action: '#cards', color: Colors.cyan),
          ActionButton(label: 'Flashcards', icon: Icons.flip, action: '#flash', color: Colors.pink),
        ]),
        
        // MEDIA
        AIContentBlock.text('🎬 **Media & Files**'),
        AIContentBlock.quickActions(actionButtons: [
          ActionButton(label: 'Audio', icon: Icons.audiotrack, action: '#audio', color: Colors.deepPurple),
          ActionButton(label: 'Video', icon: Icons.videocam, action: '#video', color: Colors.red),
          ActionButton(label: 'Images', icon: Icons.image, action: '#img3', color: Colors.lightBlue),
          ActionButton(label: 'Map', icon: Icons.map, action: '#map', color: Colors.greenAccent),
        ]),

         // HANDWRITTEN & CODE
        AIContentBlock.text('✍️ **Styles & Themes**'),
        AIContentBlock.quickActions(actionButtons: [
          ActionButton(label: 'Note', icon: Icons.note, action: '#note', color: Colors.brown),
          ActionButton(label: 'Paper', icon: Icons.description, action: '#paper', color: Colors.grey),
          ActionButton(label: 'Handwriting', icon: Icons.create, action: '#playwritevariants', color: Colors.deepOrange),
          ActionButton(label: 'Code Themes', icon: Icons.code, action: '#codevariants', color: Colors.blueGrey),
          ActionButton(label: 'PyCheats', icon: Icons.terminal, action: '#pycs', color: Colors.yellow),
        ]),

        // UTILITIES
        AIContentBlock.text('🛠️ **Utilities**'),
        AIContentBlock.quickActions(actionButtons: [
          ActionButton(label: 'Timeline', icon: Icons.timeline, action: '#timeline', color: Colors.blue),
          ActionButton(label: 'Contact', icon: Icons.contact_page, action: '#contact', color: Colors.lightGreen),
          ActionButton(label: 'Event', icon: Icons.event, action: '#event', color: Colors.redAccent),
          ActionButton(label: 'Weather', icon: Icons.wb_sunny, action: '#weather', color: Colors.orangeAccent),
          ActionButton(label: 'Timer', icon: Icons.timer, action: '#countdown', color: Colors.purpleAccent),
        ]),
        
        // DEV
        AIContentBlock.text('👨‍💻 **Developer**'),
        AIContentBlock.quickActions(actionButtons: [
          ActionButton(label: 'Dev Test Mode', icon: Icons.bug_report, action: '#starttesto1', color: Colors.amber),
        ]),
      ]
    ];
  }

  List<List<AIContentBlock>> _generatePythonCheatsheetResponse() {
    return [
      // RESPONSE 1: VARIABLES & TYPES
      [
        AIContentBlock.text('🐍 PYTHON BASICS: VARIABLES & DATA TYPES'),
        AIContentBlock.letter('CONCEPT: DYNAMIC TYPING\n\nPython is dynamically typed, meaning you don\'t need to declare variable types explicitly. The interpreter infers the type at runtime.', variant: 14), // Learner variant
        AIContentBlock.letter('# Variables & Types\nname = "Alice"       # String\nage = 30             # Integer\nheight = 5.9         # Float\nis_student = True    # Boolean\n\n# Lists & Dicts\nskills = ["Python", "Dart"]\nstats = {"hp": 100, "mp": 50}', variant: 50), // VS Code Code variant
        AIContentBlock.text('PRO TIP: Use type hints for better code clarity in larger projects.'),
        AIContentBlock.letter('REFERENCE: TYPE HINTS\n\ndef greet(name: str) -> str:\n    return f"Hello, {name}"', variant: 64), // Sublime Text Code variant
      ],

      // RESPONSE 2: CONTROL FLOW
      [
        AIContentBlock.text('twisted_rightwards_arrows CONTROL FLOW: DECISIONS & LOOPS'),
        AIContentBlock.letter('EXPLANATION: INDENTATION\n\nUnlike many other languages that use curly braces {}, Python uses indentation (whitespace) to define blocks of code. Consistency is key!', variant: 11), // Academic Note variant
        AIContentBlock.letter('# If-Else Statement\nscore = 85\n\nif score >= 90:\n    print("Grade: A")\nelif score >= 80:\n    print("Grade: B")\nelse:\n    print("Grade: C")', variant: 51), // Dracula Code variant
        AIContentBlock.letter('# Loops (For & While)\n\n# Iterate over a list\nfor i in range(5):\n    print(f"Count: {i}")\n\n# While loop\nwhile is_running:\n    check_status()', variant: 59), // PowerShell Code variant (System admin feel)
      ],

      // RESPONSE 3: FUNCTIONS & MODULES
      [
        AIContentBlock.text('📦 FUNCTIONS & MODULARITY'),
        AIContentBlock.letter('DEV NOTE: DRY PRINCIPLE\n\nDon\'t Repeat Yourself. If you find yourself copying and pasting code, wrap it in a function. Functions make code reusable and easier to debug.', variant: 12), // Dev Sketch variant
        AIContentBlock.letter('def calculate_area(radius):\n    """Calculates circle area."""\n    import math\n    return math.pi * (radius ** 2)\n\n# Main execution\nif __name__ == "__main__":\n    print(calculate_area(5))', variant: 52), // Monokai Code variant
        AIContentBlock.letter('IMPORTING MODULES\n\nimport math\nfrom datetime import datetime\nimport pandas as pd  # Alias', variant: 60), // Ubuntu Terminal variant
      ]
    ];
  }
  List<AIContentBlock> _generateLineChartResponse() => [
    AIContentBlock.text('Here\'s your grade progression:'),
    AIContentBlock.lineChart(
      lineData: [
        ChartDataPoint(x: 0, y: 65, label: 'Week 1'),
        ChartDataPoint(x: 1, y: 72, label: 'Week 2'),
        ChartDataPoint(x: 2, y: 78, label: 'Week 3'),
        ChartDataPoint(x: 3, y: 85, label: 'Week 4'),
        ChartDataPoint(x: 4, y: 88, label: 'Week 5'),
      ],
      chartTitle: 'Grade Trend',
    ),
    AIContentBlock.text(
      'Great improvement! You\'ve gained 23 points over 5 weeks.',
    ),
  ];

  List<AIContentBlock> _generateRadarChartResponse() => [
    AIContentBlock.text('Here\'s your skill assessment:'),
    AIContentBlock.radarChart(
      chartData: [
        ChartDataItem(label: 'Problem Solving', value: 85),
        ChartDataItem(label: 'Communication', value: 70),
        ChartDataItem(label: 'Creativity', value: 90),
        ChartDataItem(label: 'Leadership', value: 65),
        ChartDataItem(label: 'Teamwork', value: 80),
      ],
      chartTitle: 'Skills Radar',
    ),
  ];

  List<AIContentBlock> _generateProgressResponse() => [
    AIContentBlock.text('Here\'s your assignment progress:'),
    AIContentBlock.progressBars(
      progressItems: [
        ProgressItem(label: 'Math Homework', value: 100),
        ProgressItem(label: 'Science Project', value: 75),
        ProgressItem(label: 'Essay Draft', value: 40),
        ProgressItem(label: 'Lab Report', value: 60),
      ],
      chartTitle: 'Assignments',
    ),
  ];

  List<AIContentBlock> _generateTimelineResponse() => [
    AIContentBlock.text('Here\'s today\'s schedule:'),
    AIContentBlock.timeline(
      timelineEvents: [
        TimelineEvent(
          title: 'Morning Lecture',
          description: 'Introduction to Calculus',
          date: '9:00 AM',
        ),
        TimelineEvent(
          title: 'Lab Session',
          description: 'Chemistry Lab B',
          date: '11:00 AM',
        ),
        TimelineEvent(
          title: 'Study Group',
          description: 'Library Room 3',
          date: '2:00 PM',
        ),
        TimelineEvent(
          title: 'Office Hours',
          description: 'Prof. Smith',
          date: '4:00 PM',
        ),
      ],
    ),
  ];

  List<AIContentBlock> _generateQuizResponse() => [
    AIContentBlock.text('Quick Quiz Time! 📝'),
    AIContentBlock.quiz(
      quizData: QuizData(
        question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctIndex: 1,
      ),
    ),
  ];

  List<AIContentBlock> _generateChecklistResponse() => [
    AIContentBlock.text('Here\'s your study checklist:'),
    AIContentBlock.checklist(
      checklistItems: [
        ChecklistItem(text: 'Read Chapter 5', checked: true),
        ChecklistItem(text: 'Complete practice problems'),
        ChecklistItem(text: 'Review lecture notes'),
        ChecklistItem(text: 'Prepare questions for class'),
      ],
      chartTitle: 'Study Tasks',
    ),
  ];

  List<AIContentBlock> _generateTableResponse() => [
    AIContentBlock.text('Here\'s your grade summary:'),
    AIContentBlock.dataTable(
      tableData: TableData(
        headers: ['Subject', 'Midterm', 'Final', 'Grade'],
        rows: [
          ['Mathematics', '88', '92', 'A'],
          ['Physics', '75', '82', 'B+'],
          ['Chemistry', '90', '88', 'A-'],
          ['English', '85', '90', 'A'],
        ],
      ),
      chartTitle: 'Term Grades',
    ),
  ];

  List<AIContentBlock> _generateCarouselResponse() => [
    AIContentBlock.text('Your enrolled courses:'),
    AIContentBlock.carousel(
      carouselItems: [
        InfoCard(
          title: 'Calculus II',
          subtitle: 'MWF 9:00 AM',
          description: 'Room 201',
          icon: Icons.calculate,
          color: const Color(0xFF3B82F6),
        ),
        InfoCard(
          title: 'Physics 101',
          subtitle: 'TTH 11:00 AM',
          description: 'Lab B',
          icon: Icons.science,
          color: const Color(0xFF8B5CF6),
        ),
        InfoCard(
          title: 'English Lit',
          subtitle: 'MWF 2:00 PM',
          description: 'Room 305',
          icon: Icons.book,
          color: const Color(0xFF10B981),
        ),
      ],
    ),
  ];

  List<AIContentBlock> _generateAudioResponse() => [
    AIContentBlock.text('Here\'s the lecture recording:'),
    AIContentBlock.audioPlayer(
      mediaUrl: 'lecture.mp3',
      mediaTitle: 'Calculus Lecture - Week 4',
      mediaDuration: const Duration(minutes: 52, seconds: 30),
    ),
  ];

  List<AIContentBlock> _generateVideoResponse() => [
    AIContentBlock.text('Watch this tutorial:'),
    AIContentBlock.videoPlayer(
      mediaUrl: 'tutorial.mp4',
      mediaTitle: 'Quadratic Equations Explained',
    ),
  ];

  List<AIContentBlock> _generateContactResponse() => [
    AIContentBlock.text('Here\'s your professor\'s contact info:'),
    AIContentBlock.contactCard(
      contactData: ContactData(
        name: 'Dr. Sarah Miller',
        role: 'Professor of Mathematics',
        phone: '+1 (555) 123-4567',
        email: 'smiller@university.edu',
      ),
    ),
  ];

  List<AIContentBlock> _generateEventResponse() => [
    AIContentBlock.text('Upcoming event:'),
    AIContentBlock.calendarEvent(
      eventData: CalendarEventData(
        title: 'Midterm Exam',
        date: 'Feb 15',
        time: '10:00 AM - 12:00 PM',
        location: 'Examination Hall A',
        color: const Color(0xFFEF4444),
      ),
    ),
  ];

  List<AIContentBlock> _generateActionsResponse() => [
    AIContentBlock.text('Quick actions available:'),
    AIContentBlock.quickActions(
      actionButtons: [
        ActionButton(
          label: 'Add to Calendar',
          icon: Icons.calendar_today,
          color: const Color(0xFF3B82F6),
        ),
        ActionButton(
          label: 'Set Reminder',
          icon: Icons.alarm,
          color: const Color(0xFFF59E0B),
        ),
        ActionButton(
          label: 'Share',
          icon: Icons.share,
          color: const Color(0xFF10B981),
        ),
        ActionButton(
          label: 'Download',
          icon: Icons.download,
          color: const Color(0xFF8B5CF6),
        ),
      ],
    ),
  ];

  List<AIContentBlock> _generateWeatherResponse() => [
    AIContentBlock.text('Current campus weather:'),
    AIContentBlock.weather(
      weatherData: WeatherData(
        location: 'University Campus',
        temperature: 22,
        condition: 'Partly Cloudy',
        icon: Icons.cloud,
      ),
    ),
  ];

  List<AIContentBlock> _generateCountdownResponse() => [
    AIContentBlock.text('Exam countdown:'),
    AIContentBlock.countdown(
      countdownData: CountdownData(
        title: 'Final Exam - Mathematics',
        targetDate: DateTime.now().add(const Duration(days: 7, hours: 5)),
        color: const Color(0xFFEF4444),
      ),
    ),
  ];

  List<AIContentBlock> _generateFlashcardsResponse() => [
    AIContentBlock.text('Study flashcards:'),
    AIContentBlock.flashcards(
      flashcards: [
        FlashcardData(front: 'What is the derivative of x²?', back: '2x'),
        FlashcardData(front: '∫sin(x)dx = ?', back: '-cos(x) + C'),
        FlashcardData(front: 'lim(x→0) sin(x)/x = ?', back: '1'),
      ],
    ),
  ];

  /// Dev testing: Generate response with code blocks
  List<AIContentBlock> _generateCodeBlockResponse() {
    final blocks = <AIContentBlock>[];
    final random = Random();

    // Intro text
    blocks.add(
      AIContentBlock.text('Here\'s an example of how you can implement this:'),
    );

    // Sample code snippets
    final sampleCodes = [
      (
        '''void main() {
  print('Hello, World!');
  
  final numbers = [1, 2, 3, 4, 5];
  final doubled = numbers.map((n) => n * 2);
  print(doubled.toList());
}''',
        'dart',
      ),
      (
        '''def calculate_average(numbers):
    if not numbers:
        return 0
    return sum(numbers) / len(numbers)

# Example usage
scores = [85, 92, 78, 90, 88]
avg = calculate_average(scores)
print(f"Average: {avg}")''',
        'python',
      ),
      (
        '''async function fetchUserData(userId) {
  try {
    const response = await fetch(\`/api/users/\${userId}\`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}''',
        'javascript',
      ),
    ];

    // Pick a random code sample
    final codeIndex = random.nextInt(sampleCodes.length);
    final (code, lang) = sampleCodes[codeIndex];
    blocks.add(AIContentBlock.code(code, language: lang));

    // Explanation text
    blocks.add(
      AIContentBlock.text(
        'This code demonstrates the basic pattern. You can modify it according to your specific requirements.',
      ),
    );

    return blocks;
  }

  /// Dev testing: Generate multi-block response with text and images in order
  List<AIContentBlock> _generateMultiBlockResponse(int imageCount) {
    final blocks = <AIContentBlock>[];
    final random = Random();

    // First text block
    blocks.add(AIContentBlock.text(_generateLoremIpsum()));

    // First image set (half of requested images)
    final firstImageCount = (imageCount / 2).ceil();
    if (firstImageCount > 0) {
      blocks.add(AIContentBlock.images(_generateTestImages(firstImageCount)));
    }

    // Second text block
    blocks.add(AIContentBlock.text(_generateLoremIpsum()));

    // Second image set (remaining images)
    final secondImageCount = imageCount - firstImageCount;
    if (secondImageCount > 0) {
      blocks.add(AIContentBlock.images(_generateTestImages(secondImageCount)));
    }

    // Third text block (conclusion)
    if (random.nextBool()) {
      blocks.add(AIContentBlock.text(_generateLoremIpsum()));
    }

    return blocks;
  }

  /// Dev testing: Generate exact number of images for #imgN keyword
  List<AIResponseImage>? _generateTestImages(int count) {
    if (count <= 0) return null;

    final sampleTitles = [
      'Schedule Overview',
      'Class Analysis',
      'Attendance Chart',
      'Course Statistics',
      'Grade Report',
      'Study Plan',
      'Exam Timeline',
      'Notes Summary',
    ];
    final sampleCaptions = [
      'Your weekly schedule breakdown',
      'Performance analytics for this semester',
      'Monthly attendance trends',
      'Subject-wise distribution',
      'Term grade overview',
      'Weekly study goals',
      'Upcoming exam dates',
      'Lecture notes compilation',
    ];

    return List.generate(
      count,
      (i) => AIResponseImage(
        url: 'test_image_${i + 1}',
        title: sampleTitles[i % sampleTitles.length],
        caption: sampleCaptions[i % sampleCaptions.length],
      ),
    );
  }

  String _getAttachmentSummary(List<PendingAttachment> attachments) {
    if (attachments.isEmpty) return '';
    final types = attachments.map((a) => a.type.name).toSet().join(', ');
    return 'Sent ${attachments.length} attachment(s): $types';
  }

  void _addAttachment(AttachmentType type, String name) {
    setState(() {
      _pendingAttachments.add(
        PendingAttachment(
          type: type,
          name: name,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
    });
  }

  void _removeAttachment(String id) {
    setState(() {
      _pendingAttachments.removeWhere((a) => a.id == id);
    });
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    final duration = _recordingDuration;
    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });
    // Add voice recording as attachment
    _addAttachment(
      AttachmentType.voice,
      'Voice (${_formatDuration(duration)})',
    );
  }

  void _cancelRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();
    _recordingAnimController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with Back Button
            _buildAppBar(),
            // Main Chat Area
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      // Feature Highlight Card
                      _buildFeatureCard(),
                      const SizedBox(height: 20),
                      // Date Separator
                      if (_messages.isNotEmpty) ...[
                        _buildDateSeparator('Today'),
                        const SizedBox(height: 16),
                      ],
                      // Messages
                      ..._messages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final msg = entry.value;
                        // Check if this is the latest AI message
                        final isLatestAi =
                            msg.isAi &&
                            index == _messages.lastIndexWhere((m) => m.isAi);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildMessage(msg, isLatest: isLatestAi),
                        );
                      }),
                      // Typing Indicator (only when AI is "thinking")
                      if (_isTyping) _buildTypingIndicator(),
                    ],
                  ),
                  // Test Mode Overlay (Counter)
                  if (_isTestMode)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Text(
                          'TEST MODE: ${_currentTestIndex + 1} / ${_testQueue.length}',
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom Input Bar (or Test Controls)
            if (_isTestMode)
               Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   Text(
                      _testQueue.isNotEmpty ? _testQueue[_currentTestIndex].description : 'Loading...',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                   ),
                   const SizedBox(height: 12),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text('DELETE'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _nextTestItem('delete'),
                      ),
                       ElevatedButton.icon(
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('KEEP'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _nextTestItem('keep'),
                      ),
                       ElevatedButton.icon(
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                        label: const Text('MORE'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () => _nextTestItem('more'),
                      ),
                    ],
                   ),
                ],
              ),
            )
            else
              _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0C).withOpacity(0.9),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF27272A), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          // Spacer to push icon to right
          const Spacer(),
          // Memory Button - Navigate to Memory Page
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MemoryPage()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Icon(
                Icons.memory,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
          ),
          // Hashtag Button - Dev Testing
          GestureDetector(
            onTap: () => _showHashtagsBottomSheet(),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Icon(
                Icons.terminal_rounded, // Dev/Terminal icon
                color: Colors.grey[400],
                size: 20,
              ),
            ),
          ),
          // Dev Test Mode Button
          GestureDetector(
            onTap: _startDevTestMode,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: const Icon(
                Icons.bug_report_rounded,
                color: Colors.amber, 
                size: 20,
              ),
            ),
          ),
          // Thunder Button - Quick Actions
          GestureDetector(
            onTap: () => _showQuickActionsSheet(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: Colors.grey[400],
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHashtagsBottomSheet() {
    final hashtags = [
      '#all', '#multi', '#papernotesall', '#pynotes', '#textstyles',
      '#note', '#paper', '#letter', '#lettervariants', '#newletterstyles', '#morelettervariants', '#playwritevariants', '#codevariants', '#pycs',
      '#code', '#flash', '#bar', '#pie', '#line', '#radar',
      '#img3', '#audio', '#video', '#cards',
      '#map', '#timeline', '#quiz', '#checklist',
      '#contact', '#event', '#weather', '#countdown', '#actions',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: const BoxDecoration(
          color: Color(0xFF16161E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3F46),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.terminal, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Dev Hashtags',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
               'Tap to fill, Send icon to auto-send',
               style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
             const SizedBox(height: 16),
             Expanded(
              child: ListView.separated(
                itemCount: hashtags.length,
                separatorBuilder: (c, i) => const Divider(color: Color(0xFF27272A), height: 1),
                itemBuilder: (context, index) {
                  final tag = hashtags[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xFF27272A),
                            borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.tag, color: Colors.blueGrey, size: 18),
                    ),
                    title: Text(tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      _messageController.text = tag;
                    },
                    trailing: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.blue),
                        onPressed: () {
                             Navigator.pop(context);
                             _messageController.text = tag;
                             _sendMessage();
                        },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DESIGN SELECTOR ==========

  void _startDevTestMode() {
    setState(() {
      _isTestMode = true;
      _currentTestIndex = 0;
      _testResults = {};
      _messages.clear(); // Clear chat for focus
      
      // Generate Test Queue
      _testQueue = [
        TestItem(id: 'text_basic', description: 'Simple Text Message', blocks: [AIContentBlock.text('Hello World! This is a simple text.')]),
        TestItem(id: 'markdown_basic', description: 'Markdown Formatting', blocks: [AIContentBlock.markdown(markdownContent: '# Header\n* Bullet\n* List')]),
        // Charts
        TestItem(id: 'chart_bar', description: 'Bar Chart', blocks: _generateBarChartResponse()),
        TestItem(id: 'chart_line', description: 'Line Chart', blocks: _generateLineChartResponse()),
        TestItem(id: 'chart_pie', description: 'Pie Chart', blocks: _generatePieChartResponse()),
        TestItem(id: 'chart_radar', description: 'Radar Chart', blocks: _generateRadarChartResponse()),
        // Interactive
        TestItem(id: 'inter_quiz', description: 'Quiz Widget', blocks: _generateQuizResponse()),
        TestItem(id: 'inter_checklist', description: 'Checklist Widget', blocks: _generateChecklistResponse()),
        TestItem(id: 'inter_table', description: 'Data Table', blocks: _generateTableResponse()),
        // Media
        TestItem(id: 'media_audio', description: 'Audio Player', blocks: _generateAudioResponse()),
        TestItem(id: 'media_video', description: 'Video Player', blocks: _generateVideoResponse()),
         // Letters - Samples
        TestItem(id: 'letter_base', description: 'Base Letter', blocks: [AIContentBlock.letter('Standard Letter Format', variant: 0)]),
        TestItem(id: 'letter_hand_10', description: 'Handwritten Style 1', blocks: [AIContentBlock.letter('Handwritten Note', variant: 10)]),
        TestItem(id: 'letter_playwrite_20', description: 'Playwrite Dual Font', blocks: [AIContentBlock.letter('Playwrite Aesthetic', variant: 20)]),
        TestItem(id: 'letter_code_50', description: 'Code VS Dark', blocks: [AIContentBlock.letter('function test() {}', variant: 50)]),
         // New PyCS
        TestItem(id: 'pycs_sample', description: 'Python Cheatsheet', blocks: _generatePythonCheatsheetResponse()[0]),
      ];
      
      // Load first item
      _loadCurrentTestItem();
    });
  }

  void _loadCurrentTestItem() {
    if (_currentTestIndex < _testQueue.length) {
      setState(() {
         _messages.add(
            ChatMessage(
              isAi: true,
              sender: 'Dev Bot',
              message: '',
              contentBlocks: _testQueue[_currentTestIndex].blocks,
            ),
         );
      });
    }
  }

  void _nextTestItem(String response) {
    if (_currentTestIndex >= _testQueue.length) return;
    
    // Save result
    _testResults[_testQueue[_currentTestIndex].id] = response;
    
    setState(() {
      _currentTestIndex++;
      _messages.clear(); // Clear previous for focus
      
      if (_currentTestIndex < _testQueue.length) {
        _loadCurrentTestItem();
      } else {
        _finishTestMode();
      }
    });
  }

  void _finishTestMode() {
    String jsonReport = const JsonEncoder.withIndent('  ').convert(_testResults);
    
    setState(() {
      _isTestMode = false;
      _messages.add(
        ChatMessage(
          isAi: true,
          sender: 'Test System', 
          message: 'Test Complete! Here is your report:',
          contentBlocks: [
            AIContentBlock.code(jsonReport, language: 'json'),
            AIContentBlock.text('Copy this JSON to analyze your preferences.')
          ]
        )
      );
    });
  }

  // ========== DESIGN SELECTOR ==========
  void _showDesignSelectorSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF16161E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3F3F46),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Bottom Sheet Design',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 340,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDesignOption('Design 1', 'Minimal Cards', () {
                      Navigator.pop(context);
                      _showDesign1();
                    }),
                    _buildDesignOption('Design 2', 'Icon Grid', () {
                      Navigator.pop(context);
                      _showDesign2();
                    }),
                    _buildDesignOption('Design 3', 'Glassmorphism', () {
                      Navigator.pop(context);
                      _showDesign3();
                    }),
                    _buildDesignOption('Design 4', 'Compact List', () {
                      Navigator.pop(context);
                      _showDesign4();
                    }),
                    _buildDesignOption('Design 5', 'Gradient Cards', () {
                      Navigator.pop(context);
                      _showDesign5();
                    }),
                    _buildDesignOption('Design 6', 'Schedule Cards', () {
                      Navigator.pop(context);
                      _showDesign6();
                    }),
                    _buildDesignOption('Design 7', 'Stats Dashboard', () {
                      Navigator.pop(context);
                      _showDesign7();
                    }),
                    _buildDesignOption('Design 8', 'Progress Rings', () {
                      Navigator.pop(context);
                      _showDesign8();
                    }),
                    _buildDesignOption('Design 9', 'Active Accent', () {
                      Navigator.pop(context);
                      _showDesign9();
                    }),
                    _buildDesignOption('Design 10', 'Technical Style', () {
                      Navigator.pop(context);
                      _showDesign10();
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignOption(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  // ========== DESIGN 1: Minimal Cards ==========
  void _showDesign1() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _design1Item(Icons.psychology_outlined, 'Memory'),
            _design1Item(Icons.description_outlined, 'Instructions'),
            _design1Item(Icons.history_rounded, 'Chat History'),
            _design1Item(Icons.tune_rounded, 'Agent Customizations'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design1Item(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ========== DESIGN 2: Icon Grid (2x2) ==========
  void _showDesign2() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF16161E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3F3F46),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _design2Item(
                    Icons.psychology_outlined,
                    'Memory',
                    const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _design2Item(
                    Icons.description_outlined,
                    'Instructions',
                    const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _design2Item(
                    Icons.history_rounded,
                    'History',
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _design2Item(
                    Icons.tune_rounded,
                    'Agent',
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _design2Item(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ========== DESIGN 3: Glassmorphism ==========
  void _showDesign3() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E1E2E).withOpacity(0.95),
              const Color(0xFF0A0A0C),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _design3Item(
              Icons.psychology_outlined,
              'Memory',
              'Context & Memory',
            ),
            _design3Item(
              Icons.description_outlined,
              'Instructions',
              'Custom Instructions',
            ),
            _design3Item(
              Icons.history_rounded,
              'Chat History',
              'Past Conversations',
            ),
            _design3Item(Icons.tune_rounded, 'Agent', 'Customizations'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design3Item(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
        ],
      ),
    );
  }

  // ========== DESIGN 4: Compact List ==========
  void _showDesign4() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF16161E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF3F3F46),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _design4Item(Icons.psychology_outlined, 'Memory'),
            Divider(color: Colors.grey[800], height: 1),
            _design4Item(Icons.description_outlined, 'Instructions'),
            Divider(color: Colors.grey[800], height: 1),
            _design4Item(Icons.history_rounded, 'Chat History'),
            Divider(color: Colors.grey[800], height: 1),
            _design4Item(Icons.tune_rounded, 'Agent Customizations'),
          ],
        ),
      ),
    );
  }

  Widget _design4Item(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 22),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, size: 20, color: Colors.grey[600]),
        ],
      ),
    );
  }

  // ========== DESIGN 5: Gradient Cards ==========
  void _showDesign5() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _design5Item(Icons.psychology_outlined, 'Memory', [
              const Color(0xFF8B5CF6),
              const Color(0xFF6366F1),
            ]),
            _design5Item(Icons.description_outlined, 'Instructions', [
              const Color(0xFF3B82F6),
              const Color(0xFF0EA5E9),
            ]),
            _design5Item(Icons.history_rounded, 'Chat History', [
              const Color(0xFF10B981),
              const Color(0xFF14B8A6),
            ]),
            _design5Item(Icons.tune_rounded, 'Agent Customizations', [
              const Color(0xFFF59E0B),
              const Color(0xFFF97316),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design5Item(IconData icon, String title, List<Color> gradientColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors[0].withOpacity(0.15),
            gradientColors[1].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gradientColors[0].withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  // ========== DESIGN 6: Schedule Cards (Like Schedule UI) ==========
  void _showDesign6() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _design6Card(
              Icons.psychology_outlined,
              'Memory',
              '08:30 - 10:00',
              'CONTEXT_MANAGER',
              false,
            ),
            const SizedBox(height: 10),
            _design6Card(
              Icons.description_outlined,
              'Instructions',
              '10:30 - 12:00',
              'PROMPT_ACTIVE',
              true,
            ),
            const SizedBox(height: 10),
            _design6Card(
              Icons.history_rounded,
              'Chat History',
              '14:00 - 15:30',
              'CONVERSATION_LOG',
              false,
            ),
            const SizedBox(height: 10),
            _design6Card(
              Icons.tune_rounded,
              'Agent',
              '16:00 - 17:00',
              'CUSTOMIZATIONS',
              false,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design6Card(
    IconData icon,
    String title,
    String time,
    String label,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF16161E) : const Color(0xFF0F0F14),
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (isActive)
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF22D3EE),
                          letterSpacing: 1,
                        ),
                      ),
                  ],
                ),
              ),
              if (isActive)
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[500], size: 14),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'OPEN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'VIEW',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ========== DESIGN 7: Stats Dashboard (Like Consistency/Total Cards) ==========
  void _showDesign7() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _design7StatCard(
                    'MEMORY',
                    '24',
                    'Items Stored',
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _design7StatCard(
                    'HISTORY',
                    '128',
                    'Conversations',
                    const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _design7ListItem(
              Icons.description_outlined,
              'Instructions',
              'Custom prompts',
            ),
            const SizedBox(height: 8),
            _design7ListItem(
              Icons.tune_rounded,
              'Agent Customizations',
              'Behavior settings',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design7StatCard(
    String label,
    String value,
    String subtitle,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _design7ListItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }

  // ========== DESIGN 8: Progress Rings (Like Attendance Subject Cards) ==========
  void _showDesign8() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _design8Item(
              Icons.psychology_outlined,
              'Memory',
              85,
              const Color(0xFF3B82F6),
            ),
            _design8Item(
              Icons.description_outlined,
              'Instructions',
              92,
              const Color(0xFF3B82F6),
            ),
            _design8Item(
              Icons.history_rounded,
              'Chat History',
              68,
              const Color(0xFF8B5CF6),
            ),
            _design8Item(
              Icons.tune_rounded,
              'Agent Customizations',
              45,
              const Color(0xFFEF4444),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design8Item(
    IconData icon,
    String title,
    int percentage,
    Color ringColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey[400], size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 3,
                    backgroundColor: const Color(0xFF27272A),
                    valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  ),
                ),
                Text(
                  '$percentage',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ringColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== DESIGN 9: Active Accent (PROCESS_ACTIVE Style) ==========
  void _showDesign9() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _design9Item(
              Icons.psychology_outlined,
              'Memory',
              'MEMORY_ACTIVE',
              true,
            ),
            _design9Item(
              Icons.description_outlined,
              'Instructions',
              'PROMPT_READY',
              false,
            ),
            _design9Item(
              Icons.history_rounded,
              'Chat History',
              'HISTORY_LOG',
              false,
            ),
            _design9Item(
              Icons.tune_rounded,
              'Agent Customizations',
              'AGENT_CONFIG',
              false,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design9Item(
    IconData icon,
    String title,
    String status,
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: const Color(0xFF22D3EE).withOpacity(0.4))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF22D3EE).withOpacity(0.15)
                  : const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF22D3EE) : Colors.grey[500],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF22D3EE)
                        : Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF22D3EE),
                shape: BoxShape.circle,
              ),
            ),
          if (!isActive)
            Icon(Icons.chevron_right, color: Colors.grey[600], size: 18),
        ],
      ),
    );
  }

  // ========== DESIGN 10: Technical/Monospace Style ==========
  void _showDesign10() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// Quick Actions',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _design10Item('memory', '--context'),
                  _design10Item('instructions', '--prompt'),
                  _design10Item('history', '--log'),
                  _design10Item('agent', '--config'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'CYCLE_COMPLETE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design10Item(String cmd, String flag) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '> ',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: const Color(0xFF3B82F6),
            ),
          ),
          Text(
            cmd,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: Colors.white,
            ),
          ),
          Text(
            ' $flag',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: Colors.grey[500],
            ),
          ),
          const Spacer(),
          Icon(Icons.play_arrow, color: const Color(0xFF3B82F6), size: 16),
        ],
      ),
    );
  }

  // ========== QUICK ACTIONS (Thunder Button) - Design 7 Style ==========
  void _showQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'MEMORY',
                    '24',
                    'Items Stored',
                    const Color(0xFF3B82F6),
                    Icons.psychology_outlined,
                    () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'HISTORY',
                    '128',
                    'Conversations',
                    const Color(0xFF8B5CF6),
                    Icons.history_rounded,
                    () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActionListItem(
              Icons.description_outlined,
              'Instructions',
              'Custom prompts',
              () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
            _buildActionListItem(
              Icons.tune_rounded,
              'Agent Customizations',
              'Behavior settings',
              () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String subtitle,
    Color accentColor,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionListItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_note,
              color: Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ask me about your upcoming exams',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'I can check your schedule and lecture notes.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0C),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF27272A)),
            ),
            child: const Icon(
              Icons.chevron_right,
              color: Color(0xFF3B82F6),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String date) {
    return Center(
      child: Text(
        date.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, {bool isLatest = false}) {
    if (message.isAi) {
      return _buildAiMessage(message, isLatest: isLatest);
    } else {
      return _buildUserMessage(message);
    }
  }

  Widget _buildAiMessage(ChatMessage message, {bool isLatest = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        // Message Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // New: Render content blocks if available
              if (message.contentBlocks != null &&
                  message.contentBlocks!.isNotEmpty) ...[
                ...message.contentBlocks!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final block = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(top: index > 0 ? 10 : 0),
                    child: _buildContentBlock(block),
                  );
                }),
              ] else ...[
                // Fallback to old behavior
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161E),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: Text(
                    message.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                // AI Response Images Gallery (old behavior)
                if (message.images != null && message.images!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildImageGallery(message.images!),
                ],
              ],
              // Attachment if exists
              if (message.attachment != null) ...[
                const SizedBox(height: 8),
                _buildAttachment(message.attachment!),
              ],
              // Action buttons for the latest AI message
              if (isLatest) ...[
                const SizedBox(height: 10),
                _buildMessageActions(message),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentBlock(AIContentBlock block) {
    if (block.type == AIContentBlockType.text && block.text != null) {
      return _buildStyledText(block.text!, block.variant);
    } else if (block.type == AIContentBlockType.images &&
        block.images != null) {
      return _buildImageGallery(block.images!);
    } else if (block.type == AIContentBlockType.code && block.code != null) {
      return _buildCodeBlock(block.code!, block.language ?? 'code');
    } else if (block.type == AIContentBlockType.map &&
        block.mapCenter != null) {
      return _buildMapBlock(
        block.mapCenter!,
        block.mapMarkers,
        block.mapZoom ?? 15.0,
      );
    } else if (block.type == AIContentBlockType.barChart &&
        block.chartData != null) {
      return _buildBarChart(block.chartData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.pieChart &&
        block.chartData != null) {
      return _buildPieChart(block.chartData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.lineChart &&
        block.lineData != null) {
      return _buildLineChart(block.lineData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.radarChart &&
        block.chartData != null) {
      return _buildRadarChart(block.chartData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.progressBars &&
        block.progressItems != null) {
      return _buildProgressBars(block.progressItems!, block.chartTitle);
    } else if (block.type == AIContentBlockType.timeline &&
        block.timelineEvents != null) {
      return _buildTimeline(block.timelineEvents!);
    } else if (block.type == AIContentBlockType.quiz &&
        block.quizData != null) {
      return _buildQuiz(block.quizData!);
    } else if (block.type == AIContentBlockType.checklist &&
        block.checklistItems != null) {
      return _buildChecklist(block.checklistItems!, block.chartTitle);
    } else if (block.type == AIContentBlockType.collapsible &&
        block.collapsibleTitle != null) {
      return _buildCollapsible(
        block.collapsibleTitle!,
        block.collapsibleContent ?? '',
      );
    } else if (block.type == AIContentBlockType.dataTable &&
        block.tableData != null) {
      return _buildDataTable(block.tableData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.carousel &&
        block.carouselItems != null) {
      return _buildCarousel(block.carouselItems!);
    } else if (block.type == AIContentBlockType.audioPlayer &&
        block.mediaUrl != null) {
      return _buildAudioPlayer(
        block.mediaUrl!,
        block.mediaTitle,
        block.mediaDuration,
      );
    } else if (block.type == AIContentBlockType.videoPlayer &&
        block.mediaUrl != null) {
      return _buildVideoPlayer(
        block.mediaUrl!,
        block.mediaTitle,
        block.thumbnailUrl,
      );
    } else if (block.type == AIContentBlockType.fileAttachment &&
        block.mediaUrl != null) {
      return _buildFileAttachment(block.mediaUrl!, block.mediaTitle ?? 'File');
    } else if (block.type == AIContentBlockType.voiceMessage) {
      return _buildVoiceMessage(block.mediaDuration);
    } else if (block.type == AIContentBlockType.quickActions &&
        block.actionButtons != null) {
      return _buildQuickActions(block.actionButtons!);
    } else if (block.type == AIContentBlockType.contactCard &&
        block.contactData != null) {
      return _buildContactCard(block.contactData!);
    } else if (block.type == AIContentBlockType.calendarEvent &&
        block.eventData != null) {
      return _buildCalendarEvent(block.eventData!);
    } else if (block.type == AIContentBlockType.markdown &&
        block.markdownContent != null) {
      return _buildMarkdown(block.markdownContent!);
    } else if (block.type == AIContentBlockType.mathEquation &&
        block.mathEquation != null) {
      return _buildMathEquation(block.mathEquation!);
    } else if (block.type == AIContentBlockType.weather &&
        block.weatherData != null) {
      return _buildWeather(block.weatherData!);
    } else if (block.type == AIContentBlockType.countdown &&
        block.countdownData != null) {
      return _buildCountdown(block.countdownData!);
    } else if (block.type == AIContentBlockType.flashcards &&
        block.flashcards != null) {
      return _buildFlashcards(block.flashcards!);
    } else if (block.type == AIContentBlockType.pdfPreview &&
        block.mediaUrl != null) {
      return _buildPdfPreview(block.mediaUrl!, block.mediaTitle);
    } else if (block.type == AIContentBlockType.note && block.text != null) {
      return _buildNote(block.text!, block.variant);
    } else if (block.type == AIContentBlockType.paper && block.text != null) {
      return _buildPaper(block.text!, block.variant);
    } else if (block.type == AIContentBlockType.letter && block.text != null) {
      return _buildLetter(block.text!, block.variant);
    }
    return const SizedBox.shrink();
  }

  Widget _buildStyledText(String text, int variant) {
    // 20 Styles for Showcase
    switch (variant) {
      case 1: // Modern Minimal
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(left: BorderSide(color: Colors.grey[700]!, width: 2)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              height: 1.6,
              letterSpacing: 0.5,
            ),
          ),
        );
      case 2: // Classic Serif
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Georgia',
              color: Color(0xFFE8E8E8),
              height: 1.5,
              wordSpacing: 1.0,
            ),
          ),
        );
      case 3: // Terminal
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: Colors.greenAccent,
              height: 1.2,
            ),
          ),
        );
      case 4: // Editorial
        return Container(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Color(0xFF3B82F6), width: 4)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        );
      case 5: // Handwritten
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFE0).withOpacity(0.9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(255),
              bottomRight: Radius.circular(255),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Cursive', // Fallback will be messy but okay
              color: Colors.black87,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case 6: // Bold Headline
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF16161E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        );
      case 7: // Technical/Blue
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '// TECHNICAL_LOG',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[400],
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[100],
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      case 8: // Neon
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purpleAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
              shadows: [
                Shadow(
                  color: Colors.purpleAccent,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        );
      case 9: // Typewriter
        return Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFFF5F5F5),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Courier New',
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case 10: // Review/Quote
        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.format_quote, color: Colors.grey, size: 32),
                const SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ));
      case 11: // Warning
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF7F1D1D).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEF4444)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFFFCA5A5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      case 12: // Success
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF10B981)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF6EE7B7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      case 13: // Info
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3B82F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'INFORMATION',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(color: Color(0xFFBFDBFE)),
              ),
            ],
          ),
        );
      case 14: // Luxury
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1C1917), const Color(0xFF292524)],
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
          child: Column(
            children: [
              Text(
                '✦',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 16,
                  color: Color(0xFFE5E7EB),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '✦',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24),
              ),
            ],
          ),
        );
      case 15: // Brutalism
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      case 16: // Pastel
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF2F8), // Pink tint
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF831843),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case 17: // Accessibility
        return Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        );
        case 18: // Retro Computer
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
             color: Color(0xFF000080), // Navy Blue
             border: Border(
                top: BorderSide(color: Colors.white, width: 2),
                left: BorderSide(color: Colors.white, width: 2),
                right: BorderSide(color: Colors.grey, width: 2),
                bottom: BorderSide(color: Colors.grey, width: 2),
             ),
          ),
          child: Text(
             text,
             style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold
             ),
          ),
        );
        case 19: // Blueprint
        return Container(
           padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(
              color: Color(0xFF1E3A8A),
              image: DecorationImage(
                 image: NetworkImage("https://www.transparenttextures.com/patterns/graphy.png"), // Simulated pattern
                 fit: BoxFit.cover,
                 colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.dstATop),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.3))
           ),
           child: Text(
              text,
              style: const TextStyle(
                 fontFamily: 'monospace',
                 color: Colors.white,
                 letterSpacing: 1.0
              ),
           )
        );

      default: // Default (0)
        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF16161E),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        );
    }
  }

  Widget _buildBarChart(List<ChartDataItem> data, String? title) {
    final chartColors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
    ];

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          // Bar Chart
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      data.map((e) => e.value).reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barGroups: data.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: item.value,
                          color:
                              item.color ?? chartColors[i % chartColors.length],
                          width: 22,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[value.toInt()].label,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: const Color(0xFF27272A), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<ChartDataItem> data, String? title) {
    final chartColors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
    ];

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pie_chart_rounded,
                    size: 16,
                    color: Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          // Pie Chart and Legend
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: data.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return PieChartSectionData(
                            value: item.value,
                            color:
                                item.color ??
                                chartColors[i % chartColors.length],
                            radius: 45,
                            title: '${item.value.toInt()}%',
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: data.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color:
                                    item.color ??
                                    chartColors[i % chartColors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============== PHASE 1: DATA VISUALIZATION ==============

  Widget _buildLineChart(List<ChartDataPoint> data, String? title) {
    return _buildChartContainer(
      title,
      Icons.show_chart,
      const Color(0xFF10B981),
      SizedBox(
        height: 160,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) =>
                  FlLine(color: const Color(0xFF27272A), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, m) => Text(
                    v.toInt().toString(),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, m) => Text(
                    data[v.toInt() < data.length ? v.toInt() : 0].label ?? '',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: data.map((p) => FlSpot(p.x, p.y)).toList(),
                isCurved: true,
                color: const Color(0xFF10B981),
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF10B981).withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarChart(List<ChartDataItem> data, String? title) {
    return _buildChartContainer(
      title,
      Icons.radar,
      const Color(0xFF8B5CF6),
      SizedBox(
        height: 180,
        child: RadarChart(
          RadarChartData(
            radarShape: RadarShape.polygon,
            tickCount: 4,
            ticksTextStyle: TextStyle(color: Colors.grey[600], fontSize: 8),
            tickBorderData: const BorderSide(color: Color(0xFF27272A)),
            gridBorderData: const BorderSide(color: Color(0xFF27272A)),
            dataSets: [
              RadarDataSet(
                dataEntries: data
                    .map((d) => RadarEntry(value: d.value))
                    .toList(),
                fillColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                borderColor: const Color(0xFF8B5CF6),
                borderWidth: 2,
              ),
            ],
            getTitle: (i, a) => RadarChartTitle(text: data[i].label, angle: a),
            titleTextStyle: TextStyle(color: Colors.grey[400], fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBars(List<ProgressItem> items, String? title) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];
    return _buildChartContainer(
      title,
      Icons.trending_up,
      const Color(0xFF3B82F6),
      Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                    ),
                    Text(
                      '${item.value.toInt()}/${item.max.toInt()}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.value / item.max,
                    backgroundColor: const Color(0xFF27272A),
                    valueColor: AlwaysStoppedAnimation(
                      item.color ?? colors[i % colors.length],
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeline(List<TimelineEvent> events) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
    ];
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        children: events.asMap().entries.map((e) {
          final i = e.key;
          final ev = e.value;
          final isLast = i == events.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: ev.color ?? colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 50,
                      color: const Color(0xFF27272A),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ev.date,
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ev.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (ev.description != null)
                        Text(
                          ev.description!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ============== PHASE 2: INTERACTIVE CONTENT ==============

  Widget _buildQuiz(QuizData quiz) {
    return StatefulBuilder(
      builder: (context, setState) {
        int? selected;
        bool revealed = false;
        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF16161E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.quiz, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  const Text(
                    'Quiz',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                quiz.question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...quiz.options.asMap().entries.map((e) {
                final i = e.key;
                final opt = e.value;
                final isCorrect = i == quiz.correctIndex;
                final isSelected = selected == i;
                return GestureDetector(
                  onTap: () => setState(() {
                    selected = i;
                    revealed = true;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: revealed
                          ? (isCorrect
                                ? const Color(0xFF10B981).withOpacity(0.2)
                                : isSelected
                                ? const Color(0xFFEF4444).withOpacity(0.2)
                                : const Color(0xFF1E1E26))
                          : const Color(0xFF1E1E26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: revealed
                            ? (isCorrect
                                  ? const Color(0xFF10B981)
                                  : isSelected
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF27272A))
                            : const Color(0xFF27272A),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[600]!),
                          ),
                          child: revealed && isCorrect
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Color(0xFF10B981),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChecklist(List<ChecklistItem> items, String? title) {
    return StatefulBuilder(
      builder: (context, setState) {
        final checked = List<bool>.from(items.map((i) => i.checked));
        return _buildChartContainer(
          title ?? 'Checklist',
          Icons.checklist,
          const Color(0xFF10B981),
          Column(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              return GestureDetector(
                onTap: () => setState(() => checked[i] = !checked[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: checked[i]
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: checked[i]
                                ? const Color(0xFF10B981)
                                : Colors.grey[600]!,
                          ),
                        ),
                        child: checked[i]
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[300],
                            decoration: checked[i]
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCollapsible(String title, String content) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: Colors.grey[400],
          collapsedIconColor: Colors.grey[500],
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          children: [
            Text(
              content,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(TableData data, String? title) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.table_chart,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF1E1E26)),
              columns: data.headers
                  .map(
                    (h) => DataColumn(
                      label: Text(
                        h,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              rows: data.rows
                  .map(
                    (r) => DataRow(
                      cells: r
                          .map(
                            (c) => DataCell(
                              Text(
                                c,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(List<InfoCard> items) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      height: 140,
      child: PageView.builder(
        itemCount: items.length,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, i) {
          final item = items[i];
          final color = item.color ?? colors[i % colors.length];
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.icon != null) Icon(item.icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (item.subtitle != null)
                  Text(
                    item.subtitle!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============== PHASE 3: MEDIA ==============

  Widget _buildAudioPlayer(String url, String? title, Duration? duration) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Color(0xFF3B82F6),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'Audio',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: const LinearProgressIndicator(
                          value: 0,
                          backgroundColor: Color(0xFF27272A),
                          valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      duration != null
                          ? '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
                          : '0:00',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(String url, String? title, String? thumbnail) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E26),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF16161E),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
            ),
            child: Row(
              children: [
                const Icon(Icons.videocam, size: 16, color: Color(0xFFEF4444)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title ?? 'Video',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileAttachment(String url, String title) {
    final ext = title.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isPdf ? const Color(0xFFEF4444) : const Color(0xFF3B82F6))
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
              color: isPdf ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  ext.toUpperCase(),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Download',
              style: TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(Duration? duration) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.6,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: List.generate(
                20,
                (i) => Container(
                  width: 3,
                  height: 8 + Random().nextDouble() * 12,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            duration != null
                ? '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
                : '0:12',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ============== PHASE 4: ACTIONS ==============

  Widget _buildQuickActions(List<ActionButton> actions) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: actions.map((a) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: (a.color ?? const Color(0xFF3B82F6)).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (a.color ?? const Color(0xFF3B82F6)).withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  a.icon,
                  size: 16,
                  color: a.color ?? const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 6),
                Text(
                  a.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: a.color ?? const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard(ContactData contact) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF3B82F6).withOpacity(0.2),
            child: Text(
              contact.name[0],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (contact.role != null)
                  Text(
                    contact.role!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          if (contact.phone != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.call, size: 18, color: Color(0xFF10B981)),
            ),
          const SizedBox(width: 8),
          if (contact.email != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.email,
                size: 18,
                color: Color(0xFF3B82F6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarEvent(CalendarEventData event) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: event.color ?? const Color(0xFF3B82F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: (event.color ?? const Color(0xFF3B82F6)).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  event.date.split(' ').first,
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
                Text(
                  event.date.split(' ').length > 1
                      ? event.date.split(' ')[1]
                      : '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: event.color ?? const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (event.time != null)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.time!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                if (event.location != null)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.location!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ============== PHASE 5: RICH FORMATTING ==============

  Widget _buildMarkdown(String content) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Text(
        content.replaceAll('**', '').replaceAll('*', '').replaceAll('#', ''),
        style: TextStyle(fontSize: 13, color: Colors.grey[300], height: 1.5),
      ),
    );
  }

  Widget _buildMathEquation(String equation) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.functions, color: Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              equation,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============== PHASE 6: BONUS ==============

  Widget _buildWeather(WeatherData weather) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.6,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(weather.icon, size: 48, color: Colors.white),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature.toInt()}°C',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                weather.condition,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                weather.location,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown(CountdownData data) {
    final diff = data.targetDate.difference(DateTime.now());
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (data.color ?? const Color(0xFFEF4444)).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color ?? const Color(0xFFEF4444)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timer,
            color: data.color ?? const Color(0xFFEF4444),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _countdownUnit(days.toString(), 'Days'),
              const SizedBox(width: 16),
              _countdownUnit(hours.toString(), 'Hours'),
              const SizedBox(width: 16),
              _countdownUnit((diff.inMinutes % 60).toString(), 'Mins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countdownUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildFlashcards(List<FlashcardData> cards) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      height: 140,
      child: PageView.builder(
        itemCount: cards.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, i) {
          return StatefulBuilder(
            builder: (context, setState) {
              bool flipped = false;
              return GestureDetector(
                onTap: () => setState(() => flipped = !flipped),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: flipped
                          ? [const Color(0xFF10B981), const Color(0xFF06B6D4)]
                          : [const Color(0xFF8B5CF6), const Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          flipped ? Icons.lightbulb : Icons.help_outline,
                          color: Colors.white.withOpacity(0.5),
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          flipped ? cards[i].back : cards[i].front,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to ${flipped ? 'see question' : 'reveal answer'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPdfPreview(String url, String? title) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E26),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: Color(0xFFEF4444),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title ?? 'PDF Document',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF16161E),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pdfAction(Icons.visibility, 'View'),
                _pdfAction(Icons.download, 'Download'),
                _pdfAction(Icons.share, 'Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pdfAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF27272A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey[400]),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildNote(String text, int variant) {
    Color bgColor;
    Color pinColor;

    switch (variant) {
      case 1: // Pink
        bgColor = const Color(0xFFFBCFE8);
        pinColor = const Color(0xFFDB2777);
        break;
      case 2: // Blue
        bgColor = const Color(0xFFBAE6FD);
        pinColor = const Color(0xFF0284C7);
        break;
      case 3: // Green
        bgColor = const Color(0xFFBBF7D0);
        pinColor = const Color(0xFF16A34A);
        break;
      case 4: // Orange
        bgColor = const Color(0xFFFED7AA);
        pinColor = const Color(0xFFEA580C);
        break;
      case 0:
      default: // Yellow
        bgColor = const Color(0xFFFEF08A);
        pinColor = const Color(0xFFEF4444);
        break;
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pin visual
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: pinColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF422006), // Dark brown text
              fontFamily:
                  'Cursive', // Fallback to cursive if specific font not available
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaper(String text, int variant) {
    Color bgColor = const Color(0xFFF8FAFC);
    Color lineColor = const Color(0xFFE2E8F0); // Subtle blue-grey
    Color marginColor = const Color(0xFFFECACA).withOpacity(0.5); // Red-ish
    Color textColor = const Color(0xFF334155);
    bool showHoles = true;
    bool isBlueprint = false;

    if (variant == 1) {
      // Grid
      bgColor = Colors.white;
      lineColor = const Color(0xFFE2E8F0);
    } else if (variant == 2) {
      // Legal
      bgColor = const Color(0xFFFEF9C3); // Yellowish
      lineColor = const Color(0xFF94A3B8); // Blue lines
      marginColor = const Color(0xFFEF4444).withOpacity(0.5);
    } else if (variant == 3) {
      // Blueprint
      bgColor = const Color(0xFF1E3A8A); // Dark Blue
      lineColor = Colors.white.withOpacity(0.15);
      marginColor = Colors.transparent;
      textColor = Colors.white.withOpacity(0.9);
      showHoles = false;
      isBlueprint = true;
    } else if (variant == 4) {
      // Dot Grid
      bgColor = const Color(0xFFFAFAFA);
      // Just implies different styling, for now simple
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
        gradient: isBlueprint
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgColor, Color.lerp(bgColor, Colors.black, 0.02)!],
                stops: const [0.95, 1.0], // Slight curl effect at bottom
              ),
      ),
      child: Stack(
        children: [
          // Binding holes (if shown)
          if (showHoles)
            Positioned(
              left: -12,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF0A0A0C,
                      ), // Background color to simulate hole
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          // Vertical margin line
          if (marginColor != Colors.transparent && !isBlueprint)
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: marginColor),
            ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontFamily: isBlueprint ? 'Monospace' : null,
                  height: 1.8, // Line height to match lines
                  shadows: isBlueprint
                      ? []
                      : [
                          Shadow(
                            offset: const Offset(0, 1),
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLetter(String text, int variant) {
    Color paperColor = const Color(0xFFF5E6D3);
    Color borderColor = const Color(0xFFD4C5A2);
    IconData sealIcon = Icons.stars;
    Color sealColor = const Color(0xFFB91C1C);
    Color textColor = const Color(0xFF3F2E18);
    
    // Default font styles
    String? fontFamily = 'Serif';
    FontStyle fontStyle = FontStyle.normal;
    FontWeight fontWeight = FontWeight.normal;

    if (variant == 1) {
      // Royal
      paperColor = const Color(0xFFFFFAF0); // FloralWhite
      borderColor = const Color(0xFFFFD700); // Gold
      sealColor = const Color(0xFFDAA520);
    } else if (variant == 2) {
      // Love
      paperColor = const Color(0xFFFFF0F5); // LavenderBlush
      borderColor = const Color(0xFFFFB6C1);
      sealIcon = Icons.favorite;
      sealColor = const Color(0xFFE11D48);
    } else if (variant == 3) {
      // Ancient
      paperColor = const Color(0xFFEAD196); // Darker parchment
      borderColor = const Color(0xFF8D6E63);
      sealIcon = Icons.history_edu;
      sealColor = const Color(0xFF5D4037);
    } else if (variant == 4) {
      // Dark
      paperColor = const Color(0xFF18181B);
      borderColor = const Color(0xFF52525B);
      sealIcon = Icons.nightlight_round;
      sealColor = const Color(0xFF71717A);
      textColor = const Color(0xFFE4E4E7);
      fontFamily = null; // System font
    } else if (variant == 5) {
      // Cyber / Holographic
      paperColor = const Color(0xFF0F172A); // Slate 900
      borderColor = const Color(0xFF22D3EE); // Cyan 400
      sealIcon = Icons.security;
      sealColor = const Color(0xFF06B6D4); // Cyan 500
      textColor = const Color(0xFFE0F2FE); // Sky 100
      fontFamily = 'monospace';
    } else if (variant == 6) {
      // Formal / Diplomatic
      paperColor = const Color(0xFFFDFBF7); // Warm white
      borderColor = const Color(0xFF1E3A8A); // Blue 900
      sealIcon = Icons.account_balance;
      sealColor = const Color(0xFF1E40AF); // Blue 800
      textColor = const Color(0xFF0F172A); // Slate 900
      fontFamily = 'Serif';
      fontWeight = FontWeight.w500;
    } else if (variant == 7) {
      // Natural / Eco
      paperColor = const Color(0xFFF1F8E9); // Light Green
      borderColor = const Color(0xFF33691E); // Dark Green
      sealIcon = Icons.eco;
      sealColor = const Color(0xFF558B2F); // Light Green
      textColor = const Color(0xFF1B5E20); // Dark Green
      fontFamily = null;
    } else if (variant == 8) {
      // Urgent / Redacted
      paperColor = const Color(0xFFFFFFFF);
      borderColor = const Color(0xFFEF4444); // Red 500
      sealIcon = Icons.warning_amber_rounded;
      sealColor = const Color(0xFFDC2626); // Red 600
      textColor = const Color(0xFF000000);
      fontFamily = 'monospace';
      fontWeight = FontWeight.bold;
    } else if (variant == 9) {
      // Magic / Mystic
      paperColor = const Color(0xFF2E1065); // Violet 950
      borderColor = const Color(0xFFF59E0B); // Amber 500
      sealIcon = Icons.auto_awesome;
      sealColor = const Color(0xFFD97706); // Amber 600
      textColor = const Color(0xFFFEF3C7); // Amber 100
      fontFamily = 'Serif';
      fontStyle = FontStyle.italic;
    } else if (variant == 10) {
      // Playful Sticky
      paperColor = const Color(0xFFFEF08A); // Yellow 200
      borderColor = const Color(0xFFEAB308); // Yellow 500
      sealIcon = Icons.push_pin;
      sealColor = const Color(0xFFEF4444); // Red pin
      textColor = const Color(0xFF422006); // Brown
      fontFamily = 'Cursive';
    } else if (variant == 11) {
      // Academic Notebook
      paperColor = const Color(0xFFF1F5F9); // Slate 100
      borderColor = const Color(0xFFCBD5E1); // Slate 300
      sealIcon = Icons.book;
      sealColor = const Color(0xFF3B82F6); 
      textColor = const Color(0xFF334155); 
      fontFamily = 'Cursive';
    } else if (variant == 12) {
      // Dev Sketch
      paperColor = const Color(0xFF27272A); // Zinc 800
      borderColor = const Color(0xFF4ADE80); // Green 400
      sealIcon = Icons.code;
      sealColor = const Color(0xFF22C55E);
      textColor = const Color(0xFF4ADE80); // Terminal Green
      fontFamily = 'Cursive'; // Handwritten code look
    } else if (variant == 13) {
      // Corporate Note (Handwritten signature feel)
      paperColor = const Color(0xFFFAFAF9); // Stone 50
      borderColor = const Color(0xFFA8A29E); // Stone 400
      sealIcon = Icons.business_center;
      sealColor = const Color(0xFF57534E);
      textColor = const Color(0xFF292524);
      fontFamily = 'Cursive'; 
    } else if (variant == 14) {
      // Learner Flashcard
      paperColor = const Color(0xFFE0E7FF); // Indigo 100
      borderColor = const Color(0xFF818CF8); // Indigo 400
      sealIcon = Icons.school;
      sealColor = const Color(0xFF6366F1);
      textColor = const Color(0xFF312E81);
      fontFamily = 'Cursive';
      fontWeight = FontWeight.bold;
    } else if (variant == 15) {
      // Tech Blueprint
      paperColor = const Color(0xFF172554); // Blue 950
      borderColor = const Color(0xFF60A5FA); // Blue 400
      sealIcon = Icons.architecture;
      sealColor = const Color(0xFF93C5FD);
      textColor = const Color(0xFFDBEAFE);
      fontFamily = 'Cursive'; // Architect handwriting
    } else if (variant == 16) {
      // Journal Entry
      paperColor = const Color(0xFFFFF7ED); // Orange 50
      borderColor = const Color(0xFFFDBA74); // Orange 300
      sealIcon = Icons.edit;
      sealColor = const Color(0xFFF97316);
      textColor = const Color(0xFF7C2D12);
      fontFamily = 'Cursive';
    } else if (variant == 17) {
      // Code Review
      paperColor = const Color(0xFFFEF2F2); // Red 50
      borderColor = const Color(0xFFFCA5A5); // Red 300
      sealIcon = Icons.bug_report;
      sealColor = const Color(0xFFEF4444);
      textColor = const Color(0xFF991B1B);
      fontFamily = 'Cursive'; 
    } else if (variant == 18) {
      // Brainstorming
      paperColor = const Color(0xFFFFFFFF);
      borderColor = const Color(0xFFA3A3A3); // Neutral border
      sealIcon = Icons.lightbulb;
      sealColor = const Color(0xFFEAB308);
      textColor = const Color(0xFF000000);
      fontFamily = 'Cursive';
    } else if (variant == 19) {
       // Love Note 2
      paperColor = const Color(0xFFFCE7F3); // Pink 100
      borderColor = const Color(0xFFF472B6); // Pink 400
      sealIcon = Icons.favorite_border;
      sealColor = const Color(0xFFEC4899);
      textColor = const Color(0xFF831843);
      fontFamily = 'Cursive';
    } else if (variant >= 20 && variant <= 49) {
      // PLAYWRITE AESTHETIC COLLECTION (20-49)
      // "Two different fonts in a single card"
      // Use "Guides" variants if possible, mixed with compatible pairings.
      
      // Defaults for the collection
      fontStyle = FontStyle.normal;
      fontWeight = FontWeight.normal;
      
      // Themes cycling based on variant
      // 20-29: Short (10-20 words)
      // 30-39: Medium (20-50 words)
      // 40-49: Long (~200 words)
      
      // Determine specific style based on modulus
      int styleIndex = variant % 3; // 0, 1, 2
      
      if (styleIndex == 0) {
        // STYLE A: Institutional / England Joined
        paperColor = const Color(0xFFF5F5F4); // Stone 100
        borderColor = const Color(0xFF78716C); // Stone 500
        sealIcon = Icons.account_balance;
        sealColor = const Color(0xFF44403C); // Stone 700
        textColor = const Color(0xFF1C1917); // Stone 900
        // We will assign specific fonts in the build method logic below
      } else if (styleIndex == 1) {
        // STYLE B: Academic / India
        paperColor = const Color(0xFFECFEFF); // Cyan 50
        borderColor = const Color(0xFF06B6D4); // Cyan 500
        sealIcon = Icons.school;
        sealColor = const Color(0xFF0E7490); // Cyan 700
        textColor = const Color(0xFF164E63); // Cyan 900
      } else {
        // STYLE C: Study/Programming / Australia Tasmania
        paperColor = const Color(0xFFFFF7ED); // Orange 50
        borderColor = const Color(0xFFF97316); // Orange 500
        sealIcon = Icons.code;
        sealColor = const Color(0xFFC2410C); // Orange 700
        textColor = const Color(0xFF7C2D12); // Orange 900
      }
    }

    // Custom build for Dual-Font variants
    if (variant >= 20 && variant <= 49) {
        // Logic to split text: First line (or up to \n\n) is Header. Rest is Body.
        List<String> parts = text.split('\n\n');
        String header = parts.length > 1 ? parts[0] : text.split('\n')[0];
        String body = parts.length > 1 ? parts.sublist(1).join('\n\n') : (text.contains('\n') ? text.substring(text.indexOf('\n') + 1) : '');
        
        if (parts.length == 1 && !text.contains('\n')) {
          header = "NOTE";
          body = text;
        }

        // Font Assignment
        TextStyle headerStyle;
        TextStyle bodyStyle;
        
        int styleIndex = variant % 3;
        
        if (styleIndex == 0) {
           // England Joined Guides + Serif
           headerStyle = GoogleFonts.getFont('Playfair Display', fontWeight: FontWeight.bold, fontSize: 18, color: textColor);
           bodyStyle = GoogleFonts.getFont('Playwrite GB S', fontSize: 15, color: textColor.withOpacity(0.9), height: 1.8);
        } else if (styleIndex == 1) {
           // India + Sans
           headerStyle = GoogleFonts.getFont('Lato', fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5, color: textColor);
           bodyStyle = GoogleFonts.getFont('Playwrite IN', fontSize: 14, color: textColor, height: 1.6);
        } else {
           // Australia Tasmania + Monospace
           headerStyle = GoogleFonts.getFont('JetBrains Mono', fontWeight: FontWeight.bold, fontSize: 14, color: textColor);
           bodyStyle = GoogleFonts.getFont('Playwrite AU TAS', fontSize: 16, color: textColor, height: 2.0); // Spaced out
        }

        return Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: paperColor,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(2, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(child: Text(header, style: headerStyle)),
                   Icon(sealIcon, color: sealColor, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 1, width: 40, color: borderColor),
              const SizedBox(height: 16),
              Text(body, style: bodyStyle),
            ],
          ),
        );
    } else if (variant >= 50 && variant <= 69) {
      // CODE / IDE AESTHETIC COLLECTION (50-69)
      
      // Default Code Font
      String? codeFontFamily = 'JetBrains Mono';
      Color codeBg = const Color(0xFF1E1E1E); // Default Dark
      Color codeColor = const Color(0xFFD4D4D4); // Default Light Text
      Color accentColor = const Color(0xFF569CD6); // Blue
      IconData langIcon = Icons.code;
      
      switch (variant) {
        case 50: // VS Code Dark
          codeBg = const Color(0xFF1E1E1E);
          codeColor = const Color(0xFFD4D4D4);
          accentColor = const Color(0xFF007ACC);
          langIcon = Icons.javascript;
          break;
        case 51: // Dracula
          codeBg = const Color(0xFF282A36);
          codeColor = const Color(0xFFF8F8F2);
          accentColor = const Color(0xFFBD93F9); // Purple
          langIcon = Icons.nightlight_round;
          break;
        case 52: // Monokai
          codeBg = const Color(0xFF272822);
          codeColor = const Color(0xFFF8F8F2);
          accentColor = const Color(0xFFA6E22E); // Green
          langIcon = Icons.api;
          break;
        case 53: // Solarized Dark
          codeBg = const Color(0xFF002B36);
          codeColor = const Color(0xFF839496);
          accentColor = const Color(0xFFB58900); // Yellow
          break;
        case 54: // Solarized Light
          codeBg = const Color(0xFFFDF6E3);
          codeColor = const Color(0xFF657B83);
          accentColor = const Color(0xFFB58900);
          langIcon = Icons.wb_sunny;
          break;
        case 55: // GitHub Dark
          codeBg = const Color(0xFF0D1117);
          codeColor = const Color(0xFFC9D1D9);
          accentColor = const Color(0xFF58A6FF);
          langIcon = Icons.source;
          break;
        case 56: // GitHub Light
          codeBg = const Color(0xFFFFFFFF);
          codeColor = const Color(0xFF24292E);
          accentColor = const Color(0xFF0366D6);
          break;
        case 57: // Matrix
          codeBg = const Color(0xFF000000);
          codeColor = const Color(0xFF00FF00);
          accentColor = const Color(0xFF003300);
          langIcon = Icons.terminal;
          codeFontFamily = 'Fira Code';
          break;
        case 58: // Retro Amber
          codeBg = const Color(0xFF1B1B1B);
          codeColor = const Color(0xFFFFB000); // Amber
          accentColor = const Color(0xFF332200);
          langIcon = Icons.tv;
          codeFontFamily = 'Courier Prime';
          break;
        case 59: // PowerShell
          codeBg = const Color(0xFF012456);
          codeColor = const Color(0xFFEEE8D5);
          accentColor = const Color(0xFF00BCF2);
          langIcon = Icons.window;
          break;
        case 60: // Ubuntu
          codeBg = const Color(0xFF300A24);
          codeColor = const Color(0xFFFFFFFF);
          accentColor = const Color(0xFFE95420); // Orange
          langIcon = Icons.computer; // Replaced invalid icon
          break;
        case 61: // High Contrast
          codeBg = const Color(0xFF000000);
          codeColor = const Color(0xFFFFFFFF);
          accentColor = const Color(0xFFFFFF00); // Yellow
          break;
        case 62: // Cyberpunk
          codeBg = const Color(0xFF0a0b1e);
          codeColor = const Color(0xFF00f0ff);
          accentColor = const Color(0xFFff003c);
          langIcon = Icons.bolt;
          break;
        case 63: // Blueprint
          codeBg = const Color(0xFF154c79);
          codeColor = const Color(0xFFffffff);
          accentColor = const Color(0xFF87CEFA);
          langIcon = Icons.grid_on;
          break;
        case 64: // Sublime Molokai
          codeBg = const Color(0xFF272822);
          codeColor = const Color(0xFFFD971F); // Orange
          accentColor = const Color(0xFF66D9EF); // Blue
          break;
        case 65: // Atom One Dark
          codeBg = const Color(0xFF282C34);
          codeColor = const Color(0xFFABB2BF);
          accentColor = const Color(0xFF61AFEF);
          break;
        case 66: // Nord
          codeBg = const Color(0xFF2E3440);
          codeColor = const Color(0xFFD8DEE9);
          accentColor = const Color(0xFF88C0D0);
          langIcon = Icons.snowing;
          break;
        case 67: // Gruvbox
          codeBg = const Color(0xFF282828);
          codeColor = const Color(0xFFEBDBB2);
          accentColor = const Color(0xFFFE8019); // Orange
          break;
        case 68: // Synthwave
          codeBg = const Color(0xFF2b213a);
          codeColor = const Color(0xFF0fff95);
          accentColor = const Color(0xFFff00c1); // Magenta
          langIcon = Icons.music_note;
          break;
        case 69: // Cobalt2
          codeBg = const Color(0xFF193549);
          codeColor = const Color(0xFFFFC600); // Yellow
          accentColor = const Color(0xFF193549);
          break;
      }

      return Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0), // Full bleed
          decoration: BoxDecoration(
            color: codeBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Code Header/Title Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                ),
                child: Row(
                  children: [
                    Icon(langIcon, color: accentColor, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'main.code',
                      style: TextStyle( color: accentColor, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    const Spacer(),
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red.withOpacity(0.7), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.7), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.green.withOpacity(0.7), shape: BoxShape.circle)),
                  ],
                ),
              ),
              // Code Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  text,
                  style: GoogleFonts.getFont(codeFontFamily!, fontSize: 13, color: codeColor, height: 1.5),
                ),
              )
            ],
          ),
        );
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        // Texture removed to prevent 404 crash
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stamp/Seal (visual)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: sealColor.withOpacity(0.6), width: 2),
              ),
              child: Center(
                child: Icon(
                  sealIcon,
                  color: sealColor.withOpacity(0.6),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: fontFamily,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              height: 1.6,
              letterSpacing: 0.5,
            ),
          ),
          // Watermark removed as requested
        ],
      ),
    );
  }

  // Helper for chart containers
  Widget _buildChartContainer(
    String? title,
    IconData icon,
    Color color,
    Widget child,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildMapBlock(
    MapLocation center,
    List<MapLocation>? markers,
    double zoom,
  ) {
    final allMarkers = markers ?? [center];

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map header with location info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Color(0xFF3B82F6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    center.title ?? 'Location',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Interactive map
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(11),
            ),
            child: SizedBox(
              height: 180,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(center.latitude, center.longitude),
                  initialZoom: zoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.scheduleme.app',
                  ),
                  MarkerLayer(
                    markers: allMarkers
                        .map(
                          (loc) => Marker(
                            point: LatLng(loc.latitude, loc.longitude),
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          // Location description if available
          if (center.description != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF16161E),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(11),
                ),
              ),
              child: Text(
                center.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code, String language) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with language and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.code, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      language.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // Copy code to clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21262D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code content with horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFFC9D1D9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<AIResponseImage> images) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.75;

    // Horizontal scrollable image gallery
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _buildHorizontalGalleryImage(
            images[index],
            allImages: images,
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildHorizontalGalleryImage(
    AIResponseImage image, {
    List<AIResponseImage>? allImages,
    int index = 0,
  }) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(
        image,
        allImages: allImages,
        initialIndex: index,
      ),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF27272A)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3B82F6).withOpacity(0.25),
              const Color(0xFF8B5CF6).withOpacity(0.25),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.image_rounded,
              color: Colors.white.withOpacity(0.25),
              size: 36,
            ),
            if (image.title != null)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    image.title!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            // Image count indicator on first image
            if (index == 0 && allImages != null && allImages.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '1/${allImages.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImage(
    AIResponseImage image,
    double maxWidth, {
    List<AIResponseImage>? allImages,
    int index = 0,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          GestureDetector(
            onTap: () => _showFullScreenImage(
              image,
              allImages: allImages,
              initialIndex: index,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3B82F6).withOpacity(0.3),
                      const Color(0xFF8B5CF6).withOpacity(0.3),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.image_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 48,
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.zoom_out_map,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Title & Caption
          if (image.title != null || image.caption != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF16161E),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(11),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image.title != null)
                    Text(
                      image.title!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  if (image.caption != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      image.caption!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGalleryImage(
    AIResponseImage image,
    double height, {
    List<AIResponseImage>? allImages,
    int index = 0,
  }) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(
        image,
        allImages: allImages,
        initialIndex: index,
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF27272A)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3B82F6).withOpacity(0.25),
              const Color(0xFF8B5CF6).withOpacity(0.25),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.image_rounded,
              color: Colors.white.withOpacity(0.25),
              size: 28,
            ),
            if (image.title != null)
              Positioned(
                bottom: 6,
                left: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    image.title!,
                    style: const TextStyle(fontSize: 9, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(
    AIResponseImage image, {
    List<AIResponseImage>? allImages,
    int initialIndex = 0,
  }) {
    final images = allImages ?? [image];
    final startIndex = allImages != null ? initialIndex : 0;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) =>
          _FullScreenImageGallery(images: images, initialIndex: startIndex),
    );
  }

  Widget _buildMessageActions(ChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: () {
            // Copy message to clipboard
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.account_tree_rounded,
          label: 'Branch',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Branch created'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.refresh_rounded,
          label: 'Regenerate',
          onTap: () {
            // Remove last AI message and regenerate
            if (_messages.isNotEmpty && _messages.last.isAi) {
              setState(() {
                _messages.removeLast();
                _isTyping = true;
              });
              // Generate new response
              Future.delayed(
                Duration(milliseconds: 1000 + Random().nextInt(1000)),
                () {
                  if (mounted) {
                    setState(() {
                      _isTyping = false;
                      _messages.add(
                        ChatMessage(
                          isAi: true,
                          sender: 'Nexus AI',
                          message: _generateLoremIpsum(),
                        ),
                      );
                    });
                    _scrollToBottom();
                  }
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMessage(ChatMessage message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Message Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Pending Attachments display
              if (message.pendingAttachments != null &&
                  message.pendingAttachments!.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: message.pendingAttachments!
                        .map((att) => _buildSentAttachmentChip(att))
                        .toList(),
                  ),
                ),
              // Message text
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  message.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // User Avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF27272A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.grey, size: 18),
        ),
      ],
    );
  }

  Widget _buildSentAttachmentChip(PendingAttachment attachment) {
    IconData icon;
    Color color;
    switch (attachment.type) {
      case AttachmentType.image:
        icon = Icons.image_rounded;
        color = const Color(0xFF3B82F6);
        break;
      case AttachmentType.file:
        icon = Icons.insert_drive_file_rounded;
        color = const Color(0xFF8B5CF6);
        break;
      case AttachmentType.voice:
        icon = Icons.mic_rounded;
        color = const Color(0xFF10B981);
        break;
      case AttachmentType.camera:
        icon = Icons.camera_alt_rounded;
        color = const Color(0xFF3B82F6);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            attachment.name.length > 15
                ? '${attachment.name.substring(0, 12)}...'
                : attachment.name,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(ChatAttachment attachment) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${attachment.fileSize} • ${attachment.fileType}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Icon(Icons.download, color: Colors.grey[500], size: 20),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        const SizedBox(width: 42), // Align with messages
        Row(
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          'Thinking...',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[500],
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    // If recording, show recording UI instead
    if (_isRecording) {
      return _buildRecordingBar();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0C).withOpacity(0.95),
        border: Border(
          top: BorderSide(color: const Color(0xFF27272A), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pending Attachments Preview
          if (_pendingAttachments.isNotEmpty)
            Container(
              height: 80,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _pendingAttachments.length,
                itemBuilder: (context, index) {
                  final attachment = _pendingAttachments[index];
                  return _buildAttachmentPreview(attachment);
                },
              ),
            ),
          // Input Row
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              _pendingAttachments.isEmpty ? 12 : 8,
              16,
              24,
            ),
            child: Row(
              children: [
                // Add Button - Opens Attachment Options
                GestureDetector(
                  onTap: () => _showAttachmentSheet(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF27272A)),
                    ),
                    child: Icon(Icons.add, color: Colors.grey[400], size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                // Text Input
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161E),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF27272A)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: _pendingAttachments.isNotEmpty
                            ? 'Add a message...'
                            : 'Ask anything about your courses...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Send Button
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(PendingAttachment attachment) {
    IconData icon;
    Color color;
    switch (attachment.type) {
      case AttachmentType.image:
        icon = Icons.image_rounded;
        color = const Color(0xFF3B82F6);
        break;
      case AttachmentType.file:
        icon = Icons.insert_drive_file_rounded;
        color = const Color(0xFF8B5CF6);
        break;
      case AttachmentType.voice:
        icon = Icons.mic_rounded;
        color = const Color(0xFF10B981);
        break;
      case AttachmentType.camera:
        icon = Icons.camera_alt_rounded;
        color = const Color(0xFF3B82F6);
        break;
    }

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    attachment.name,
                    style: const TextStyle(fontSize: 9, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Remove Button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeAttachment(attachment.id),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF27272A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white70, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0C).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF10B981).withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          // Cancel Button
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white70, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          // Recording Indicator
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _recordingAnimController!,
                    builder: (context, child) {
                      return Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            const Color(0xFF10B981),
                            const Color(0xFFEF4444),
                            _recordingAnimController!.value,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recording... ${_formatDuration(_recordingDuration)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Stop & Send Button
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ========== ATTACHMENT OPTIONS BOTTOM SHEET ==========
  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAttachmentOption(
                    Icons.camera_alt_rounded,
                    'Camera',
                    const Color(0xFF3B82F6),
                    () {
                      Navigator.pop(context);
                      _addAttachment(
                        AttachmentType.camera,
                        'Photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAttachmentOption(
                    Icons.folder_rounded,
                    'File',
                    const Color(0xFF8B5CF6),
                    () {
                      Navigator.pop(context);
                      _showFilePickerSheet();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAttachmentOption(
                    Icons.mic_rounded,
                    'Voice',
                    const Color(0xFF10B981),
                    () {
                      Navigator.pop(context);
                      _startRecording();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showFilePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose File Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFileTypeOption(
                    Icons.image_rounded,
                    'Images',
                    const Color(0xFF3B82F6),
                    () {
                      Navigator.pop(context);
                      _addAttachment(
                        AttachmentType.image,
                        'image_${DateTime.now().millisecondsSinceEpoch}.png',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFileTypeOption(
                    Icons.picture_as_pdf_rounded,
                    'PDF',
                    const Color(0xFFEF4444),
                    () {
                      Navigator.pop(context);
                      _addAttachment(AttachmentType.file, 'document.pdf');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFileTypeOption(
                    Icons.insert_drive_file_rounded,
                    'Other',
                    const Color(0xFFF59E0B),
                    () {
                      Navigator.pop(context);
                      _addAttachment(
                        AttachmentType.file,
                        'file_${DateTime.now().millisecondsSinceEpoch}.txt',
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final bool isAi;
  final String sender;
  final String message;
  final ChatAttachment? attachment;
  final List<PendingAttachment>? pendingAttachments;
  final List<AIResponseImage>? images;
  final List<AIContentBlock>?
  contentBlocks; // New: multiple text/image blocks in order

  ChatMessage({
    required this.isAi,
    required this.sender,
    required this.message,
    this.attachment,
    this.pendingAttachments,
    this.images,
    this.contentBlocks,
  });
}

class ChatAttachment {
  final String fileName;
  final String fileSize;
  final String fileType;

  ChatAttachment({
    required this.fileName,
    required this.fileSize,
    required this.fileType,
  });
}

enum AttachmentType { image, file, voice, camera }

class PendingAttachment {
  final String id;
  final AttachmentType type;
  final String name;

  PendingAttachment({required this.id, required this.type, required this.name});
}

class AIResponseImage {
  final String url;
  final String? caption;
  final String? title;

  AIResponseImage({required this.url, this.caption, this.title});
}

/// Content block types for multi-part AI responses
enum AIContentBlockType {
  text,
  images,
  code,
  map,
  barChart,
  pieChart,
  // Phase 1: Data Visualization
  lineChart,
  radarChart,
  progressBars,
  timeline,
  // Phase 2: Interactive Content
  quiz,
  checklist,
  collapsible,
  dataTable,
  carousel,
  // Phase 3: Media
  audioPlayer,
  videoPlayer,
  fileAttachment,
  voiceMessage,
  // Phase 4: Actions
  quickActions,
  deepLinks,
  contactCard,
  calendarEvent,
  // Phase 5: Rich Formatting
  markdown,
  mathEquation,
  // Phase 6: Bonus
  weather,
  countdown,
  flashcards,
  pdfPreview,
  // New Styles
  note,
  paper,
  letter,
}

/// Location data for map content blocks
class MapLocation {
  final double latitude;
  final double longitude;
  final String? title;
  final String? description;

  MapLocation({
    required this.latitude,
    required this.longitude,
    this.title,
    this.description,
  });
}

/// Data item for charts
class ChartDataItem {
  final String label;
  final double value;
  final Color? color;

  ChartDataItem({required this.label, required this.value, this.color});
}

/// Data point for line charts
class ChartDataPoint {
  final double x;
  final double y;
  final String? label;

  ChartDataPoint({required this.x, required this.y, this.label});
}

/// Progress item for progress bars
class ProgressItem {
  final String label;
  final double value;
  final double max;
  final Color? color;

  ProgressItem({
    required this.label,
    required this.value,
    this.max = 100,
    this.color,
  });
}

/// Timeline event
class TimelineEvent {
  final String title;
  final String? description;
  final String date;
  final Color? color;
  final IconData? icon;

  TimelineEvent({
    required this.title,
    this.description,
    required this.date,
    this.color,
    this.icon,
  });
}

/// Quiz data
class QuizData {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizData({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

/// Checklist item
class ChecklistItem {
  final String text;
  final bool checked;

  ChecklistItem({required this.text, this.checked = false});
}

/// Table data
class TableData {
  final List<String> headers;
  final List<List<String>> rows;

  TableData({required this.headers, required this.rows});
}

/// Info card for carousel
class InfoCard {
  final String title;
  final String? subtitle;
  final String? description;
  final IconData? icon;
  final Color? color;

  InfoCard({
    required this.title,
    this.subtitle,
    this.description,
    this.icon,
    this.color,
  });
}

/// Action button
class ActionButton {
  final String label;
  final IconData icon;
  final Color? color;
  final String? action;

  ActionButton({
    required this.label,
    required this.icon,
    this.color,
    this.action,
  });
}

/// Contact data
class ContactData {
  final String name;
  final String? role;
  final String? phone;
  final String? email;
  final String? avatarUrl;

  ContactData({
    required this.name,
    this.role,
    this.phone,
    this.email,
    this.avatarUrl,
  });
}

/// Calendar event data
class CalendarEventData {
  final String title;
  final String date;
  final String? time;
  final String? location;
  final Color? color;

  CalendarEventData({
    required this.title,
    required this.date,
    this.time,
    this.location,
    this.color,
  });
}

/// Weather data
class WeatherData {
  final String location;
  final double temperature;
  final String condition;
  final IconData icon;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.icon,
  });
}

/// Countdown data
class CountdownData {
  final String title;
  final DateTime targetDate;
  final Color? color;

  CountdownData({required this.title, required this.targetDate, this.color});
}

/// Flashcard data
class FlashcardData {
  final String front;
  final String back;

  FlashcardData({required this.front, required this.back});
}

/// A single content block in an AI response
class AIContentBlock {
  final AIContentBlockType type;
  // Basic content
  final String? text;
  final List<AIResponseImage>? images;
  final String? code;
  final String? language;
  // Map
  final MapLocation? mapCenter;
  final List<MapLocation>? mapMarkers;
  final double? mapZoom;
  // Charts
  final List<ChartDataItem>? chartData;
  final List<ChartDataPoint>? lineData;
  final String? chartTitle;
  // Progress
  final List<ProgressItem>? progressItems;
  // Timeline
  final List<TimelineEvent>? timelineEvents;
  // Quiz
  final QuizData? quizData;
  // Checklist
  final List<ChecklistItem>? checklistItems;
  // Collapsible
  final String? collapsibleTitle;
  final String? collapsibleContent;
  // Table
  final TableData? tableData;
  // Carousel
  final List<InfoCard>? carouselItems;
  // Media
  final String? mediaUrl;
  final String? mediaTitle;
  final Duration? mediaDuration;
  final String? thumbnailUrl;
  // Actions
  final List<ActionButton>? actionButtons;
  // Contact
  final ContactData? contactData;
  // Calendar
  final CalendarEventData? eventData;
  // Weather
  final WeatherData? weatherData;
  // Countdown
  final CountdownData? countdownData;
  // Flashcards
  final List<FlashcardData>? flashcards;
  // Markdown/Math
  final String? markdownContent;
  final String? mathEquation;

  // Variant for different styles (default 0)
  int variant = 0;

  // Constructors for each type
  AIContentBlock.text(this.text, {this.variant = 0})
    : type = AIContentBlockType.text,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.note(this.text, {this.variant = 0})
    : type = AIContentBlockType.note,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.paper(this.text, {this.variant = 0})
    : type = AIContentBlockType.paper,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.letter(this.text, {this.variant = 0})
    : type = AIContentBlockType.letter,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.images(this.images)
    : type = AIContentBlockType.images,
      text = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.code(this.code, {this.language = 'dart'})
    : type = AIContentBlockType.code,
      text = null,
      images = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.map({
    required this.mapCenter,
    this.mapMarkers,
    this.mapZoom = 15.0,
  }) : type = AIContentBlockType.map,
       text = null,
       images = null,
       code = null,
       language = null,
       chartData = null,
       lineData = null,
       chartTitle = null,
       progressItems = null,
       timelineEvents = null,
       quizData = null,
       checklistItems = null,
       collapsibleTitle = null,
       collapsibleContent = null,
       tableData = null,
       carouselItems = null,
       mediaUrl = null,
       mediaTitle = null,
       mediaDuration = null,
       thumbnailUrl = null,
       actionButtons = null,
       contactData = null,
       eventData = null,
       weatherData = null,
       countdownData = null,
       flashcards = null,
       markdownContent = null,
       mathEquation = null;

  AIContentBlock.barChart({required this.chartData, this.chartTitle})
    : type = AIContentBlockType.barChart,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      lineData = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.pieChart({required this.chartData, this.chartTitle})
    : type = AIContentBlockType.pieChart,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      lineData = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.lineChart({required this.lineData, this.chartTitle})
    : type = AIContentBlockType.lineChart,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.radarChart({required this.chartData, this.chartTitle})
    : type = AIContentBlockType.radarChart,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      lineData = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.progressBars({required this.progressItems, this.chartTitle})
    : type = AIContentBlockType.progressBars,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.timeline({required this.timelineEvents, this.chartTitle})
    : type = AIContentBlockType.timeline,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      progressItems = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.quiz({required this.quizData})
    : type = AIContentBlockType.quiz,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.checklist({required this.checklistItems, this.chartTitle})
    : type = AIContentBlockType.checklist,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.collapsible({
    required this.collapsibleTitle,
    required this.collapsibleContent,
  }) : type = AIContentBlockType.collapsible,
       text = null,
       images = null,
       code = null,
       language = null,
       mapCenter = null,
       mapMarkers = null,
       mapZoom = null,
       chartData = null,
       lineData = null,
       chartTitle = null,
       progressItems = null,
       timelineEvents = null,
       quizData = null,
       checklistItems = null,
       tableData = null,
       carouselItems = null,
       mediaUrl = null,
       mediaTitle = null,
       mediaDuration = null,
       thumbnailUrl = null,
       actionButtons = null,
       contactData = null,
       eventData = null,
       weatherData = null,
       countdownData = null,
       flashcards = null,
       markdownContent = null,
       mathEquation = null;

  AIContentBlock.dataTable({required this.tableData, this.chartTitle})
    : type = AIContentBlockType.dataTable,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.carousel({required this.carouselItems, this.chartTitle})
    : type = AIContentBlockType.carousel,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.audioPlayer({
    required this.mediaUrl,
    this.mediaTitle,
    this.mediaDuration,
  }) : type = AIContentBlockType.audioPlayer,
       text = null,
       images = null,
       code = null,
       language = null,
       mapCenter = null,
       mapMarkers = null,
       mapZoom = null,
       chartData = null,
       lineData = null,
       chartTitle = null,
       progressItems = null,
       timelineEvents = null,
       quizData = null,
       checklistItems = null,
       collapsibleTitle = null,
       collapsibleContent = null,
       tableData = null,
       carouselItems = null,
       thumbnailUrl = null,
       actionButtons = null,
       contactData = null,
       eventData = null,
       weatherData = null,
       countdownData = null,
       flashcards = null,
       markdownContent = null,
       mathEquation = null;

  AIContentBlock.videoPlayer({
    required this.mediaUrl,
    this.mediaTitle,
    this.thumbnailUrl,
  }) : type = AIContentBlockType.videoPlayer,
       text = null,
       images = null,
       code = null,
       language = null,
       mapCenter = null,
       mapMarkers = null,
       mapZoom = null,
       chartData = null,
       lineData = null,
       chartTitle = null,
       progressItems = null,
       timelineEvents = null,
       quizData = null,
       checklistItems = null,
       collapsibleTitle = null,
       collapsibleContent = null,
       tableData = null,
       carouselItems = null,
       mediaDuration = null,
       actionButtons = null,
       contactData = null,
       eventData = null,
       weatherData = null,
       countdownData = null,
       flashcards = null,
       markdownContent = null,
       mathEquation = null;

  AIContentBlock.fileAttachment({
    required this.mediaUrl,
    required this.mediaTitle,
  }) : type = AIContentBlockType.fileAttachment,
       text = null,
       images = null,
       code = null,
       language = null,
       mapCenter = null,
       mapMarkers = null,
       mapZoom = null,
       chartData = null,
       lineData = null,
       chartTitle = null,
       progressItems = null,
       timelineEvents = null,
       quizData = null,
       checklistItems = null,
       collapsibleTitle = null,
       collapsibleContent = null,
       tableData = null,
       carouselItems = null,
       mediaDuration = null,
       thumbnailUrl = null,
       actionButtons = null,
       contactData = null,
       eventData = null,
       weatherData = null,
       countdownData = null,
       flashcards = null,
       markdownContent = null,
       mathEquation = null;

  AIContentBlock.voiceMessage({this.mediaDuration})
    : type = AIContentBlockType.voiceMessage,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.quickActions({required this.actionButtons})
    : type = AIContentBlockType.quickActions,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.contactCard({required this.contactData})
    : type = AIContentBlockType.contactCard,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.calendarEvent({required this.eventData})
    : type = AIContentBlockType.calendarEvent,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.markdown({required this.markdownContent})
    : type = AIContentBlockType.markdown,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      mathEquation = null;

  AIContentBlock.mathEquation({required this.mathEquation})
    : type = AIContentBlockType.mathEquation,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null;

  AIContentBlock.weather({required this.weatherData})
    : type = AIContentBlockType.weather,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.countdown({required this.countdownData})
    : type = AIContentBlockType.countdown,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.flashcards({required this.flashcards})
    : type = AIContentBlockType.flashcards,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaUrl = null,
      mediaTitle = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      markdownContent = null,
      mathEquation = null;

  AIContentBlock.pdfPreview({required this.mediaUrl, this.mediaTitle})
    : type = AIContentBlockType.pdfPreview,
      text = null,
      images = null,
      code = null,
      language = null,
      mapCenter = null,
      mapMarkers = null,
      mapZoom = null,
      chartData = null,
      lineData = null,
      chartTitle = null,
      progressItems = null,
      timelineEvents = null,
      quizData = null,
      checklistItems = null,
      collapsibleTitle = null,
      collapsibleContent = null,
      tableData = null,
      carouselItems = null,
      mediaDuration = null,
      thumbnailUrl = null,
      actionButtons = null,
      contactData = null,
      eventData = null,
      weatherData = null,
      countdownData = null,
      flashcards = null,
      markdownContent = null,
      mathEquation = null;
}

// Swipeable fullscreen image gallery
class _FullScreenImageGallery extends StatefulWidget {
  final List<AIResponseImage> images;
  final int initialIndex;

  const _FullScreenImageGallery({required this.images, this.initialIndex = 0});

  @override
  State<_FullScreenImageGallery> createState() =>
      _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<_FullScreenImageGallery> {
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

  @override
  Widget build(BuildContext context) {
    final currentImage = widget.images[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header with title/caption
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentImage.title ?? 'Image ${_currentIndex + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (currentImage.caption != null)
                          Text(
                            currentImage.caption!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Page indicator text
                  if (widget.images.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${widget.images.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Swipeable images
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildImagePage(widget.images[index]);
                },
              ),
            ),
            // Page indicator dots
            if (widget.images.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (index) {
                    return Container(
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            // Swipe hint for multiple images
            if (widget.images.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swipe, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Swipe to view more',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePage(AIResponseImage image) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF3B82F6).withOpacity(0.4),
                const Color(0xFF8B5CF6).withOpacity(0.4),
              ],
            ),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  image.title ?? 'Demo Image',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                if (image.caption != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    image.caption!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
