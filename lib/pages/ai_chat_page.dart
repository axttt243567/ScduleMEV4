import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = []; // Start with empty chat
  bool _isTyping = false;

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
    final sampleTitles = ['Schedule Overview', 'Class Analysis', 'Attendance Chart', 'Course Statistics'];
    final sampleCaptions = ['Your weekly schedule breakdown', 'Performance analytics for this semester', 'Monthly attendance trends', 'Subject-wise distribution'];
    
    return List.generate(imageCount, (i) => AIResponseImage(
      url: 'placeholder_${i + 1}', // Placeholder - will show demo image
      title: sampleTitles[i % sampleTitles.length],
      caption: sampleCaptions[i % sampleCaptions.length],
    ));
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

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        isAi: false,
        sender: 'You',
        message: text.isNotEmpty ? text : _getAttachmentSummary(attachmentsCopy),
        pendingAttachments: attachmentsCopy,
      ));
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
            _messages.add(ChatMessage(
              isAi: true,
              sender: 'Nexus AI',
              message: '',
              contentBlocks: _generateAllBlocksResponse(),
            ));
          } else if (useLineChart) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateLineChartResponse()));
          } else if (useRadarChart) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateRadarChartResponse()));
          } else if (useProgress) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateProgressResponse()));
          } else if (useTimeline) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateTimelineResponse()));
          } else if (useQuiz) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateQuizResponse()));
          } else if (useChecklist) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateChecklistResponse()));
          } else if (useTable) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateTableResponse()));
          } else if (useCarousel) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateCarouselResponse()));
          } else if (useAudio) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateAudioResponse()));
          } else if (useVideo) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateVideoResponse()));
          } else if (useContact) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateContactResponse()));
          } else if (useEvent) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateEventResponse()));
          } else if (useActions) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateActionsResponse()));
          } else if (useWeather) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateWeatherResponse()));
          } else if (useCountdown) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateCountdownResponse()));
          } else if (useFlash) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateFlashcardsResponse()));
          } else if (useBarChart) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateBarChartResponse()));
          } else if (usePieChart) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generatePieChartResponse()));
          } else if (useMapBlock) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateMapBlockResponse()));
          } else if (useCodeBlock) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateCodeBlockResponse()));
          } else if (useMultiBlock) {
            _messages.add(ChatMessage(isAi: true, sender: 'Nexus AI', message: '', contentBlocks: _generateMultiBlockResponse(devImageCount ?? 3)));
          } else {
            // Standard response (backward compatible)
            _messages.add(ChatMessage(
              isAi: true,
              sender: 'Nexus AI',
              message: _generateLoremIpsum(),
              images: devImageCount != null 
                  ? _generateTestImages(devImageCount) 
                  : _generateSampleImages(),
            ));
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
        description: 'A historic war memorial located in the heart of New Delhi, India.',
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
    blocks.add(AIContentBlock.map(
      mapCenter: location,
      mapMarkers: [location],
      mapZoom: 14.0,
    ));
    
    // Follow-up text
    blocks.add(AIContentBlock.text('You can zoom and pan the map to explore the area. Tap the marker for more details.'));
    
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
    blocks.add(AIContentBlock.text('Here\'s your performance analysis across subjects:'));
    
    // Bar chart
    blocks.add(AIContentBlock.barChart(
      chartData: chartData,
      chartTitle: 'Subject-wise Scores',
    ));
    
    // Analysis text
    blocks.add(AIContentBlock.text('Chemistry shows your best performance at 92%. Consider focusing more on History to improve your overall average.'));
    
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
    blocks.add(AIContentBlock.text('Here\'s how your time is distributed this week:'));
    
    // Pie chart
    blocks.add(AIContentBlock.pieChart(
      chartData: chartData,
      chartTitle: 'Weekly Time Allocation',
    ));
    
    // Analysis text
    blocks.add(AIContentBlock.text('You\'re spending 35% of your time in classes. Consider allocating more time to self-study for better exam preparation.'));
    
    return blocks;
  }

  /// Dev testing: Generate response with ALL content types (with labels)
  List<AIContentBlock> _generateAllBlocksResponse() {
    return [
      AIContentBlock.text('🎉 ALL AI Response Content Types Showcase\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━'),
      
      // Bar Chart
      AIContentBlock.text('📊 BAR CHART  →  #bar'),
      AIContentBlock.barChart(chartData: [ChartDataItem(label: 'Mon', value: 85), ChartDataItem(label: 'Tue', value: 72), ChartDataItem(label: 'Wed', value: 90), ChartDataItem(label: 'Thu', value: 68)], chartTitle: 'Weekly Progress'),
      
      // Pie Chart
      AIContentBlock.text('🥧 PIE CHART  →  #pie'),
      AIContentBlock.pieChart(chartData: [ChartDataItem(label: 'Study', value: 40), ChartDataItem(label: 'Class', value: 30), ChartDataItem(label: 'Break', value: 30)], chartTitle: 'Time Split'),
      
      // Line Chart
      AIContentBlock.text('📈 LINE CHART  →  #line'),
      AIContentBlock.lineChart(lineData: [ChartDataPoint(x: 0, y: 60, label: 'Jan'), ChartDataPoint(x: 1, y: 75, label: 'Feb'), ChartDataPoint(x: 2, y: 85, label: 'Mar'), ChartDataPoint(x: 3, y: 90, label: 'Apr')], chartTitle: 'Grade Trend'),
      
      // Radar Chart
      AIContentBlock.text('🎯 RADAR CHART  →  #radar'),
      AIContentBlock.radarChart(chartData: [ChartDataItem(label: 'Math', value: 80), ChartDataItem(label: 'Science', value: 70), ChartDataItem(label: 'English', value: 90), ChartDataItem(label: 'History', value: 65), ChartDataItem(label: 'Art', value: 85)], chartTitle: 'Skill Radar'),
      
      // Progress Bars
      AIContentBlock.text('📶 PROGRESS BARS  →  #progress'),
      AIContentBlock.progressBars(progressItems: [ProgressItem(label: 'Assignment 1', value: 80), ProgressItem(label: 'Assignment 2', value: 45), ProgressItem(label: 'Project', value: 100)], chartTitle: 'Task Progress'),
      
      // Timeline
      AIContentBlock.text('⏱️ TIMELINE  →  #timeline'),
      AIContentBlock.timeline(timelineEvents: [TimelineEvent(title: 'Class Start', date: '9:00 AM'), TimelineEvent(title: 'Lunch Break', date: '12:00 PM'), TimelineEvent(title: 'Lab Session', date: '2:00 PM')]),
      
      // Quiz
      AIContentBlock.text('❓ QUIZ  →  #quiz'),
      AIContentBlock.quiz(quizData: QuizData(question: 'What is 2 + 2?', options: ['3', '4', '5', '6'], correctIndex: 1)),
      
      // Checklist
      AIContentBlock.text('✅ CHECKLIST  →  #checklist'),
      AIContentBlock.checklist(checklistItems: [ChecklistItem(text: 'Review notes'), ChecklistItem(text: 'Complete HW', checked: true), ChecklistItem(text: 'Study for exam')], chartTitle: 'To-Do'),
      
      // Collapsible
      AIContentBlock.text('🔽 COLLAPSIBLE  →  (no keyword)'),
      AIContentBlock.collapsible(collapsibleTitle: 'Click to expand details', collapsibleContent: 'This is the hidden content that appears when you tap on the header! Great for FAQs or additional info.'),
      
      // Data Table
      AIContentBlock.text('📋 DATA TABLE  →  #table'),
      AIContentBlock.dataTable(tableData: TableData(headers: ['Subject', 'Grade', 'Credits'], rows: [['Math', 'A', '4'], ['Physics', 'B+', '3'], ['English', 'A-', '3']]), chartTitle: 'Grades'),
      
      // Carousel
      AIContentBlock.text('🎠 CARDS CAROUSEL  →  #cards'),
      AIContentBlock.carousel(carouselItems: [InfoCard(title: 'Physics 101', subtitle: 'Room 204', icon: Icons.science), InfoCard(title: 'Math 201', subtitle: 'Room 105', icon: Icons.calculate), InfoCard(title: 'English 101', subtitle: 'Room 302', icon: Icons.book)]),
      
      // Audio Player
      AIContentBlock.text('🎵 AUDIO PLAYER  →  #audio'),
      AIContentBlock.audioPlayer(mediaUrl: 'lecture.mp3', mediaTitle: 'Lecture Recording', mediaDuration: const Duration(minutes: 45)),
      
      // Video Player
      AIContentBlock.text('🎬 VIDEO PLAYER  →  #video'),
      AIContentBlock.videoPlayer(mediaUrl: 'tutorial.mp4', mediaTitle: 'Video Tutorial'),
      
      // File Attachment
      AIContentBlock.text('📎 FILE ATTACHMENT  →  (no keyword)'),
      AIContentBlock.fileAttachment(mediaUrl: 'notes.pdf', mediaTitle: 'Study_Notes.pdf'),
      
      // Voice Message
      AIContentBlock.text('🎤 VOICE MESSAGE  →  (no keyword)'),
      AIContentBlock.voiceMessage(mediaDuration: const Duration(seconds: 32)),
      
      // Quick Actions
      AIContentBlock.text('⚡ QUICK ACTIONS  →  #actions'),
      AIContentBlock.quickActions(actionButtons: [ActionButton(label: 'Calendar', icon: Icons.calendar_today, color: const Color(0xFF3B82F6)), ActionButton(label: 'Reminder', icon: Icons.alarm, color: const Color(0xFFF59E0B)), ActionButton(label: 'Share', icon: Icons.share, color: const Color(0xFF10B981))]),
      
      // Contact Card
      AIContentBlock.text('👤 CONTACT CARD  →  #contact'),
      AIContentBlock.contactCard(contactData: ContactData(name: 'Prof. Johnson', role: 'Mathematics', phone: '+1234567890', email: 'prof.j@edu.com')),
      
      // Calendar Event
      AIContentBlock.text('📅 CALENDAR EVENT  →  #event'),
      AIContentBlock.calendarEvent(eventData: CalendarEventData(title: 'Final Exam', date: 'Jan 28', time: '10:00 AM', location: 'Hall A')),
      
      // Math Equation
      AIContentBlock.text('🧮 MATH EQUATION  →  (no keyword)'),
      AIContentBlock.mathEquation(mathEquation: 'E = mc² + ∫f(x)dx'),
      
      // Weather
      AIContentBlock.text('🌤️ WEATHER WIDGET  →  #weather'),
      AIContentBlock.weather(weatherData: WeatherData(location: 'Campus', temperature: 24, condition: 'Sunny', icon: Icons.wb_sunny)),
      
      // Countdown
      AIContentBlock.text('⏳ COUNTDOWN TIMER  →  #countdown'),
      AIContentBlock.countdown(countdownData: CountdownData(title: 'Exam in...', targetDate: DateTime.now().add(const Duration(days: 5)))),
      
      // Flashcards
      AIContentBlock.text('🃏 FLASHCARDS  →  #flash'),
      AIContentBlock.flashcards(flashcards: [FlashcardData(front: 'H₂O', back: 'Water molecule'), FlashcardData(front: 'F = ma', back: 'Force = mass × acceleration')]),
      
      // PDF Preview
      AIContentBlock.text('📄 PDF PREVIEW  →  (no keyword)'),
      AIContentBlock.pdfPreview(mediaUrl: 'syllabus.pdf', mediaTitle: 'Course Syllabus'),
      
      // Map (separate keyword)
      AIContentBlock.text('🗺️ MAP  →  #map'),
      
      // Code Block (separate keyword)
      AIContentBlock.text('💻 CODE BLOCK  →  #code'),
      
      AIContentBlock.text('━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n✨ Total: 24 content types!\nUse individual #keywords to test each one.'),
    ];
  }

  List<AIContentBlock> _generateLineChartResponse() => [AIContentBlock.text('Here\'s your grade progression:'), AIContentBlock.lineChart(lineData: [ChartDataPoint(x: 0, y: 65, label: 'Week 1'), ChartDataPoint(x: 1, y: 72, label: 'Week 2'), ChartDataPoint(x: 2, y: 78, label: 'Week 3'), ChartDataPoint(x: 3, y: 85, label: 'Week 4'), ChartDataPoint(x: 4, y: 88, label: 'Week 5')], chartTitle: 'Grade Trend'), AIContentBlock.text('Great improvement! You\'ve gained 23 points over 5 weeks.')];
  
  List<AIContentBlock> _generateRadarChartResponse() => [AIContentBlock.text('Here\'s your skill assessment:'), AIContentBlock.radarChart(chartData: [ChartDataItem(label: 'Problem Solving', value: 85), ChartDataItem(label: 'Communication', value: 70), ChartDataItem(label: 'Creativity', value: 90), ChartDataItem(label: 'Leadership', value: 65), ChartDataItem(label: 'Teamwork', value: 80)], chartTitle: 'Skills Radar')];
  
  List<AIContentBlock> _generateProgressResponse() => [AIContentBlock.text('Here\'s your assignment progress:'), AIContentBlock.progressBars(progressItems: [ProgressItem(label: 'Math Homework', value: 100), ProgressItem(label: 'Science Project', value: 75), ProgressItem(label: 'Essay Draft', value: 40), ProgressItem(label: 'Lab Report', value: 60)], chartTitle: 'Assignments')];
  
  List<AIContentBlock> _generateTimelineResponse() => [AIContentBlock.text('Here\'s today\'s schedule:'), AIContentBlock.timeline(timelineEvents: [TimelineEvent(title: 'Morning Lecture', description: 'Introduction to Calculus', date: '9:00 AM'), TimelineEvent(title: 'Lab Session', description: 'Chemistry Lab B', date: '11:00 AM'), TimelineEvent(title: 'Study Group', description: 'Library Room 3', date: '2:00 PM'), TimelineEvent(title: 'Office Hours', description: 'Prof. Smith', date: '4:00 PM')])];
  
  List<AIContentBlock> _generateQuizResponse() => [AIContentBlock.text('Quick Quiz Time! 📝'), AIContentBlock.quiz(quizData: QuizData(question: 'Which planet is known as the Red Planet?', options: ['Venus', 'Mars', 'Jupiter', 'Saturn'], correctIndex: 1))];
  
  List<AIContentBlock> _generateChecklistResponse() => [AIContentBlock.text('Here\'s your study checklist:'), AIContentBlock.checklist(checklistItems: [ChecklistItem(text: 'Read Chapter 5', checked: true), ChecklistItem(text: 'Complete practice problems'), ChecklistItem(text: 'Review lecture notes'), ChecklistItem(text: 'Prepare questions for class')], chartTitle: 'Study Tasks')];
  
  List<AIContentBlock> _generateTableResponse() => [AIContentBlock.text('Here\'s your grade summary:'), AIContentBlock.dataTable(tableData: TableData(headers: ['Subject', 'Midterm', 'Final', 'Grade'], rows: [['Mathematics', '88', '92', 'A'], ['Physics', '75', '82', 'B+'], ['Chemistry', '90', '88', 'A-'], ['English', '85', '90', 'A']]), chartTitle: 'Term Grades')];
  
  List<AIContentBlock> _generateCarouselResponse() => [AIContentBlock.text('Your enrolled courses:'), AIContentBlock.carousel(carouselItems: [InfoCard(title: 'Calculus II', subtitle: 'MWF 9:00 AM', description: 'Room 201', icon: Icons.calculate, color: const Color(0xFF3B82F6)), InfoCard(title: 'Physics 101', subtitle: 'TTH 11:00 AM', description: 'Lab B', icon: Icons.science, color: const Color(0xFF8B5CF6)), InfoCard(title: 'English Lit', subtitle: 'MWF 2:00 PM', description: 'Room 305', icon: Icons.book, color: const Color(0xFF10B981))])];
  
  List<AIContentBlock> _generateAudioResponse() => [AIContentBlock.text('Here\'s the lecture recording:'), AIContentBlock.audioPlayer(mediaUrl: 'lecture.mp3', mediaTitle: 'Calculus Lecture - Week 4', mediaDuration: const Duration(minutes: 52, seconds: 30))];
  
  List<AIContentBlock> _generateVideoResponse() => [AIContentBlock.text('Watch this tutorial:'), AIContentBlock.videoPlayer(mediaUrl: 'tutorial.mp4', mediaTitle: 'Quadratic Equations Explained')];
  
  List<AIContentBlock> _generateContactResponse() => [AIContentBlock.text('Here\'s your professor\'s contact info:'), AIContentBlock.contactCard(contactData: ContactData(name: 'Dr. Sarah Miller', role: 'Professor of Mathematics', phone: '+1 (555) 123-4567', email: 'smiller@university.edu'))];
  
  List<AIContentBlock> _generateEventResponse() => [AIContentBlock.text('Upcoming event:'), AIContentBlock.calendarEvent(eventData: CalendarEventData(title: 'Midterm Exam', date: 'Feb 15', time: '10:00 AM - 12:00 PM', location: 'Examination Hall A', color: const Color(0xFFEF4444)))];
  
  List<AIContentBlock> _generateActionsResponse() => [AIContentBlock.text('Quick actions available:'), AIContentBlock.quickActions(actionButtons: [ActionButton(label: 'Add to Calendar', icon: Icons.calendar_today, color: const Color(0xFF3B82F6)), ActionButton(label: 'Set Reminder', icon: Icons.alarm, color: const Color(0xFFF59E0B)), ActionButton(label: 'Share', icon: Icons.share, color: const Color(0xFF10B981)), ActionButton(label: 'Download', icon: Icons.download, color: const Color(0xFF8B5CF6))])];
  
  List<AIContentBlock> _generateWeatherResponse() => [AIContentBlock.text('Current campus weather:'), AIContentBlock.weather(weatherData: WeatherData(location: 'University Campus', temperature: 22, condition: 'Partly Cloudy', icon: Icons.cloud))];
  
  List<AIContentBlock> _generateCountdownResponse() => [AIContentBlock.text('Exam countdown:'), AIContentBlock.countdown(countdownData: CountdownData(title: 'Final Exam - Mathematics', targetDate: DateTime.now().add(const Duration(days: 7, hours: 5)), color: const Color(0xFFEF4444)))];
  
  List<AIContentBlock> _generateFlashcardsResponse() => [AIContentBlock.text('Study flashcards:'), AIContentBlock.flashcards(flashcards: [FlashcardData(front: 'What is the derivative of x²?', back: '2x'), FlashcardData(front: '∫sin(x)dx = ?', back: '-cos(x) + C'), FlashcardData(front: 'lim(x→0) sin(x)/x = ?', back: '1')])];

  /// Dev testing: Generate response with code blocks
  List<AIContentBlock> _generateCodeBlockResponse() {
    final blocks = <AIContentBlock>[];
    final random = Random();
    
    // Intro text
    blocks.add(AIContentBlock.text('Here\'s an example of how you can implement this:'));
    
    // Sample code snippets
    final sampleCodes = [
      ('''void main() {
  print('Hello, World!');
  
  final numbers = [1, 2, 3, 4, 5];
  final doubled = numbers.map((n) => n * 2);
  print(doubled.toList());
}''', 'dart'),
      ('''def calculate_average(numbers):
    if not numbers:
        return 0
    return sum(numbers) / len(numbers)

# Example usage
scores = [85, 92, 78, 90, 88]
avg = calculate_average(scores)
print(f"Average: {avg}")''', 'python'),
      ('''async function fetchUserData(userId) {
  try {
    const response = await fetch(\`/api/users/\${userId}\`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}''', 'javascript'),
    ];
    
    // Pick a random code sample
    final codeIndex = random.nextInt(sampleCodes.length);
    final (code, lang) = sampleCodes[codeIndex];
    blocks.add(AIContentBlock.code(code, language: lang));
    
    // Explanation text
    blocks.add(AIContentBlock.text('This code demonstrates the basic pattern. You can modify it according to your specific requirements.'));
    
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
    
    final sampleTitles = ['Schedule Overview', 'Class Analysis', 'Attendance Chart', 'Course Statistics', 'Grade Report', 'Study Plan', 'Exam Timeline', 'Notes Summary'];
    final sampleCaptions = ['Your weekly schedule breakdown', 'Performance analytics for this semester', 'Monthly attendance trends', 'Subject-wise distribution', 'Term grade overview', 'Weekly study goals', 'Upcoming exam dates', 'Lecture notes compilation'];
    
    return List.generate(count, (i) => AIResponseImage(
      url: 'test_image_${i + 1}',
      title: sampleTitles[i % sampleTitles.length],
      caption: sampleCaptions[i % sampleCaptions.length],
    ));
  }

  String _getAttachmentSummary(List<PendingAttachment> attachments) {
    if (attachments.isEmpty) return '';
    final types = attachments.map((a) => a.type.name).toSet().join(', ');
    return 'Sent ${attachments.length} attachment(s): $types';
  }

  void _addAttachment(AttachmentType type, String name) {
    setState(() {
      _pendingAttachments.add(PendingAttachment(
        type: type,
        name: name,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
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
    _addAttachment(AttachmentType.voice, 'Voice (${_formatDuration(duration)})');
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
              child: ListView(
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
                    final isLatestAi = msg.isAi && 
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
            ),
            // Bottom Input Bar
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
              child: Icon(Icons.bolt_rounded, color: Colors.grey[400], size: 22),
            ),
          ),
        ],
      ),
    );
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 340,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDesignOption('Design 1', 'Minimal Cards', () { Navigator.pop(context); _showDesign1(); }),
                    _buildDesignOption('Design 2', 'Icon Grid', () { Navigator.pop(context); _showDesign2(); }),
                    _buildDesignOption('Design 3', 'Glassmorphism', () { Navigator.pop(context); _showDesign3(); }),
                    _buildDesignOption('Design 4', 'Compact List', () { Navigator.pop(context); _showDesign4(); }),
                    _buildDesignOption('Design 5', 'Gradient Cards', () { Navigator.pop(context); _showDesign5(); }),
                    _buildDesignOption('Design 6', 'Schedule Cards', () { Navigator.pop(context); _showDesign6(); }),
                    _buildDesignOption('Design 7', 'Stats Dashboard', () { Navigator.pop(context); _showDesign7(); }),
                    _buildDesignOption('Design 8', 'Progress Rings', () { Navigator.pop(context); _showDesign8(); }),
                    _buildDesignOption('Design 9', 'Active Accent', () { Navigator.pop(context); _showDesign9(); }),
                    _buildDesignOption('Design 10', 'Technical Style', () { Navigator.pop(context); _showDesign10(); }),
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
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(width: 8),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)))),
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
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.white)),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF3F3F46), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _design2Item(Icons.psychology_outlined, 'Memory', const Color(0xFF8B5CF6))),
                const SizedBox(width: 12),
                Expanded(child: _design2Item(Icons.description_outlined, 'Instructions', const Color(0xFF3B82F6))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _design2Item(Icons.history_rounded, 'History', const Color(0xFF10B981))),
                const SizedBox(width: 12),
                Expanded(child: _design2Item(Icons.tune_rounded, 'Agent', const Color(0xFFF59E0B))),
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
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
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
            colors: [const Color(0xFF1E1E2E).withOpacity(0.95), const Color(0xFF0A0A0C)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            _design3Item(Icons.psychology_outlined, 'Memory', 'Context & Memory'),
            _design3Item(Icons.description_outlined, 'Instructions', 'Custom Instructions'),
            _design3Item(Icons.history_rounded, 'Chat History', 'Past Conversations'),
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
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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
            Container(width: 32, height: 3, decoration: BoxDecoration(color: const Color(0xFF3F3F46), borderRadius: BorderRadius.circular(2))),
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
          Text(title, style: const TextStyle(fontSize: 15, color: Colors.white)),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            _design5Item(Icons.psychology_outlined, 'Memory', [const Color(0xFF8B5CF6), const Color(0xFF6366F1)]),
            _design5Item(Icons.description_outlined, 'Instructions', [const Color(0xFF3B82F6), const Color(0xFF0EA5E9)]),
            _design5Item(Icons.history_rounded, 'Chat History', [const Color(0xFF10B981), const Color(0xFF14B8A6)]),
            _design5Item(Icons.tune_rounded, 'Agent Customizations', [const Color(0xFFF59E0B), const Color(0xFFF97316)]),
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
        gradient: LinearGradient(colors: [gradientColors[0].withOpacity(0.15), gradientColors[1].withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gradientColors[0].withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            _design6Card(Icons.psychology_outlined, 'Memory', '08:30 - 10:00', 'CONTEXT_MANAGER', false),
            const SizedBox(height: 10),
            _design6Card(Icons.description_outlined, 'Instructions', '10:30 - 12:00', 'PROMPT_ACTIVE', true),
            const SizedBox(height: 10),
            _design6Card(Icons.history_rounded, 'Chat History', '14:00 - 15:30', 'CONVERSATION_LOG', false),
            const SizedBox(height: 10),
            _design6Card(Icons.tune_rounded, 'Agent', '16:00 - 17:00', 'CUSTOMIZATIONS', false),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design6Card(IconData icon, String title, String time, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF16161E) : const Color(0xFF0F0F14),
        borderRadius: BorderRadius.circular(14),
        border: isActive ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5), width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    if (isActive) Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF22D3EE), letterSpacing: 1)),
                  ],
                ),
              ),
              if (isActive) const Icon(Icons.auto_awesome, color: Color(0xFF3B82F6), size: 16),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[500], size: 14),
                const SizedBox(width: 6),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Icon(Icons.check_circle, color: Colors.white, size: 16), SizedBox(width: 6), Text('OPEN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.visibility, color: Colors.grey[400], size: 16), const SizedBox(width: 6), Text('VIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[400]))],
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _design7StatCard('MEMORY', '24', 'Items Stored', const Color(0xFF3B82F6))),
                const SizedBox(width: 12),
                Expanded(child: _design7StatCard('HISTORY', '128', 'Conversations', const Color(0xFF8B5CF6))),
              ],
            ),
            const SizedBox(height: 12),
            _design7ListItem(Icons.description_outlined, 'Instructions', 'Custom prompts'),
            const SizedBox(height: 8),
            _design7ListItem(Icons.tune_rounded, 'Agent Customizations', 'Behavior settings'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design7StatCard(String label, String value, String subtitle, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Container(height: 3, width: 40, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _design7ListItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ]),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            _design8Item(Icons.psychology_outlined, 'Memory', 85, const Color(0xFF3B82F6)),
            _design8Item(Icons.description_outlined, 'Instructions', 92, const Color(0xFF3B82F6)),
            _design8Item(Icons.history_rounded, 'Chat History', 68, const Color(0xFF8B5CF6)),
            _design8Item(Icons.tune_rounded, 'Agent Customizations', 45, const Color(0xFFEF4444)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design8Item(IconData icon, String title, int percentage, Color ringColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.grey[400], size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
          SizedBox(
            width: 40, height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 36, height: 36,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 3,
                    backgroundColor: const Color(0xFF27272A),
                    valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  ),
                ),
                Text('$percentage', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ringColor)),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            _design9Item(Icons.psychology_outlined, 'Memory', 'MEMORY_ACTIVE', true),
            _design9Item(Icons.description_outlined, 'Instructions', 'PROMPT_READY', false),
            _design9Item(Icons.history_rounded, 'Chat History', 'HISTORY_LOG', false),
            _design9Item(Icons.tune_rounded, 'Agent Customizations', 'AGENT_CONFIG', false),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _design9Item(IconData icon, String title, String status, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(14),
        border: isActive ? Border.all(color: const Color(0xFF22D3EE).withOpacity(0.4)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF22D3EE).withOpacity(0.15) : const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isActive ? const Color(0xFF22D3EE) : Colors.grey[500], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 2),
                Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isActive ? const Color(0xFF22D3EE) : Colors.grey[600], letterSpacing: 1)),
              ],
            ),
          ),
          if (isActive) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF22D3EE), shape: BoxShape.circle)),
          if (!isActive) Icon(Icons.chevron_right, color: Colors.grey[600], size: 18),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(2))),
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
                  Text('// Quick Actions', style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.grey[600])),
                  const SizedBox(height: 12),
                  _design10Item('memory', '--context'),
                  _design10Item('instructions', '--prompt'),
                  _design10Item('history', '--log'),
                  _design10Item('agent', '--config'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text('CYCLE_COMPLETE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 2))),
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
          Text('> ', style: TextStyle(fontSize: 14, fontFamily: 'monospace', color: const Color(0xFF3B82F6))),
          Text(cmd, style: const TextStyle(fontSize: 14, fontFamily: 'monospace', color: Colors.white)),
          Text(' $flag', style: TextStyle(fontSize: 14, fontFamily: 'monospace', color: Colors.grey[500])),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatCard('MEMORY', '24', 'Items Stored', const Color(0xFF3B82F6), Icons.psychology_outlined, () => Navigator.pop(context))),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('HISTORY', '128', 'Conversations', const Color(0xFF8B5CF6), Icons.history_rounded, () => Navigator.pop(context))),
              ],
            ),
            const SizedBox(height: 12),
            _buildActionListItem(Icons.description_outlined, 'Instructions', 'Custom prompts', () => Navigator.pop(context)),
            const SizedBox(height: 8),
            _buildActionListItem(Icons.tune_rounded, 'Agent Customizations', 'Behavior settings', () => Navigator.pop(context)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color accentColor, IconData icon, VoidCallback onTap) {
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
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Container(height: 3, width: 40, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildActionListItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ]),
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
        // AI Avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Color(0xFF3B82F6),
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        // Message Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  message.sender,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              // New: Render content blocks if available
              if (message.contentBlocks != null && message.contentBlocks!.isNotEmpty) ...[
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
          block.text!,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      );
    } else if (block.type == AIContentBlockType.images && block.images != null) {
      return _buildImageGallery(block.images!);
    } else if (block.type == AIContentBlockType.code && block.code != null) {
      return _buildCodeBlock(block.code!, block.language ?? 'code');
    } else if (block.type == AIContentBlockType.map && block.mapCenter != null) {
      return _buildMapBlock(block.mapCenter!, block.mapMarkers, block.mapZoom ?? 15.0);
    } else if (block.type == AIContentBlockType.barChart && block.chartData != null) {
      return _buildBarChart(block.chartData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.pieChart && block.chartData != null) {
      return _buildPieChart(block.chartData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.lineChart && block.lineData != null) {
      return _buildLineChart(block.lineData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.radarChart && block.chartData != null) {
      return _buildRadarChart(block.chartData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.progressBars && block.progressItems != null) {
      return _buildProgressBars(block.progressItems!, block.chartTitle);
    } else if (block.type == AIContentBlockType.timeline && block.timelineEvents != null) {
      return _buildTimeline(block.timelineEvents!);
    } else if (block.type == AIContentBlockType.quiz && block.quizData != null) {
      return _buildQuiz(block.quizData!);
    } else if (block.type == AIContentBlockType.checklist && block.checklistItems != null) {
      return _buildChecklist(block.checklistItems!, block.chartTitle);
    } else if (block.type == AIContentBlockType.collapsible && block.collapsibleTitle != null) {
      return _buildCollapsible(block.collapsibleTitle!, block.collapsibleContent ?? '');
    } else if (block.type == AIContentBlockType.dataTable && block.tableData != null) {
      return _buildDataTable(block.tableData!, block.chartTitle);
    } else if (block.type == AIContentBlockType.carousel && block.carouselItems != null) {
      return _buildCarousel(block.carouselItems!);
    } else if (block.type == AIContentBlockType.audioPlayer && block.mediaUrl != null) {
      return _buildAudioPlayer(block.mediaUrl!, block.mediaTitle, block.mediaDuration);
    } else if (block.type == AIContentBlockType.videoPlayer && block.mediaUrl != null) {
      return _buildVideoPlayer(block.mediaUrl!, block.mediaTitle, block.thumbnailUrl);
    } else if (block.type == AIContentBlockType.fileAttachment && block.mediaUrl != null) {
      return _buildFileAttachment(block.mediaUrl!, block.mediaTitle ?? 'File');
    } else if (block.type == AIContentBlockType.voiceMessage) {
      return _buildVoiceMessage(block.mediaDuration);
    } else if (block.type == AIContentBlockType.quickActions && block.actionButtons != null) {
      return _buildQuickActions(block.actionButtons!);
    } else if (block.type == AIContentBlockType.contactCard && block.contactData != null) {
      return _buildContactCard(block.contactData!);
    } else if (block.type == AIContentBlockType.calendarEvent && block.eventData != null) {
      return _buildCalendarEvent(block.eventData!);
    } else if (block.type == AIContentBlockType.markdown && block.markdownContent != null) {
      return _buildMarkdown(block.markdownContent!);
    } else if (block.type == AIContentBlockType.mathEquation && block.mathEquation != null) {
      return _buildMathEquation(block.mathEquation!);
    } else if (block.type == AIContentBlockType.weather && block.weatherData != null) {
      return _buildWeather(block.weatherData!);
    } else if (block.type == AIContentBlockType.countdown && block.countdownData != null) {
      return _buildCountdown(block.countdownData!);
    } else if (block.type == AIContentBlockType.flashcards && block.flashcards != null) {
      return _buildFlashcards(block.flashcards!);
    } else if (block.type == AIContentBlockType.pdfPreview && block.mediaUrl != null) {
      return _buildPdfPreview(block.mediaUrl!, block.mediaTitle);
    }
    return const SizedBox.shrink();
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
                  const Icon(Icons.bar_chart_rounded, size: 16, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
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
                  maxY: data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                  barGroups: data.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: item.value,
                          color: item.color ?? chartColors[i % chartColors.length],
                          width: 22,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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
                            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: const Color(0xFF27272A),
                      strokeWidth: 1,
                    ),
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
                  const Icon(Icons.pie_chart_rounded, size: 16, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
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
                            color: item.color ?? chartColors[i % chartColors.length],
                            radius: 45,
                            title: '${item.value.toInt()}%',
                            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
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
                                color: item.color ?? chartColors[i % chartColors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
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
    return _buildChartContainer(title, Icons.show_chart, const Color(0xFF10B981), 
      SizedBox(
        height: 160,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFF27272A), strokeWidth: 1)),
            titlesData: FlTitlesData(topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 10, color: Colors.grey[500])))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(data[v.toInt() < data.length ? v.toInt() : 0].label ?? '', style: TextStyle(fontSize: 10, color: Colors.grey[400]))))),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(spots: data.map((p) => FlSpot(p.x, p.y)).toList(), isCurved: true, color: const Color(0xFF10B981), barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: const Color(0xFF10B981).withOpacity(0.1)))],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarChart(List<ChartDataItem> data, String? title) {
    return _buildChartContainer(title, Icons.radar, const Color(0xFF8B5CF6),
      SizedBox(
        height: 180,
        child: RadarChart(
          RadarChartData(
            radarShape: RadarShape.polygon,
            tickCount: 4,
            ticksTextStyle: TextStyle(color: Colors.grey[600], fontSize: 8),
            tickBorderData: const BorderSide(color: Color(0xFF27272A)),
            gridBorderData: const BorderSide(color: Color(0xFF27272A)),
            dataSets: [RadarDataSet(dataEntries: data.map((d) => RadarEntry(value: d.value)).toList(), fillColor: const Color(0xFF8B5CF6).withOpacity(0.3), borderColor: const Color(0xFF8B5CF6), borderWidth: 2)],
            getTitle: (i, a) => RadarChartTitle(text: data[i].label, angle: a),
            titleTextStyle: TextStyle(color: Colors.grey[400], fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBars(List<ProgressItem> items, String? title) {
    final colors = [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFF8B5CF6), const Color(0xFFF59E0B), const Color(0xFFEF4444)];
    return _buildChartContainer(title, Icons.trending_up, const Color(0xFF3B82F6),
      Column(children: items.asMap().entries.map((e) {
        final i = e.key; final item = e.value;
        return Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item.label, style: TextStyle(fontSize: 12, color: Colors.grey[300])), Text('${item.value.toInt()}/${item.max.toInt()}', style: TextStyle(fontSize: 11, color: Colors.grey[500]))]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: item.value / item.max, backgroundColor: const Color(0xFF27272A), valueColor: AlwaysStoppedAnimation(item.color ?? colors[i % colors.length]), minHeight: 8)),
          ]),
        );
      }).toList()),
    );
  }

  Widget _buildTimeline(List<TimelineEvent> events) {
    final colors = [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFF8B5CF6), const Color(0xFFF59E0B)];
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Column(children: events.asMap().entries.map((e) {
        final i = e.key; final ev = e.value; final isLast = i == events.length - 1;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: ev.color ?? colors[i % colors.length], shape: BoxShape.circle)),
            if (!isLast) Container(width: 2, height: 50, color: const Color(0xFF27272A)),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Padding(padding: EdgeInsets.only(bottom: isLast ? 0 : 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ev.date, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            const SizedBox(height: 2),
            Text(ev.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            if (ev.description != null) Text(ev.description!, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ]))),
        ]);
      }).toList()),
    );
  }

  // ============== PHASE 2: INTERACTIVE CONTENT ==============

  Widget _buildQuiz(QuizData quiz) {
    return StatefulBuilder(builder: (context, setState) {
      int? selected;
      bool revealed = false;
      return Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.quiz, size: 16, color: Color(0xFFF59E0B)), const SizedBox(width: 8), const Text('Quiz', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B)))]),
          const SizedBox(height: 12),
          Text(quiz.question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 12),
          ...quiz.options.asMap().entries.map((e) {
            final i = e.key; final opt = e.value;
            final isCorrect = i == quiz.correctIndex;
            final isSelected = selected == i;
            return GestureDetector(
              onTap: () => setState(() { selected = i; revealed = true; }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: revealed ? (isCorrect ? const Color(0xFF10B981).withOpacity(0.2) : isSelected ? const Color(0xFFEF4444).withOpacity(0.2) : const Color(0xFF1E1E26)) : const Color(0xFF1E1E26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: revealed ? (isCorrect ? const Color(0xFF10B981) : isSelected ? const Color(0xFFEF4444) : const Color(0xFF27272A)) : const Color(0xFF27272A))),
                child: Row(children: [
                  Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[600]!)), child: revealed && isCorrect ? const Icon(Icons.check, size: 14, color: Color(0xFF10B981)) : null),
                  const SizedBox(width: 10), Expanded(child: Text(opt, style: TextStyle(fontSize: 13, color: Colors.grey[300]))),
                ]),
              ),
            );
          }),
        ]),
      );
    });
  }

  Widget _buildChecklist(List<ChecklistItem> items, String? title) {
    return StatefulBuilder(builder: (context, setState) {
      final checked = List<bool>.from(items.map((i) => i.checked));
      return _buildChartContainer(title ?? 'Checklist', Icons.checklist, const Color(0xFF10B981),
        Column(children: items.asMap().entries.map((e) {
          final i = e.key; final item = e.value;
          return GestureDetector(
            onTap: () => setState(() => checked[i] = !checked[i]),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Container(width: 22, height: 22, decoration: BoxDecoration(color: checked[i] ? const Color(0xFF10B981) : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: checked[i] ? const Color(0xFF10B981) : Colors.grey[600]!)),
                  child: checked[i] ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
                const SizedBox(width: 10),
                Expanded(child: Text(item.text, style: TextStyle(fontSize: 13, color: Colors.grey[300], decoration: checked[i] ? TextDecoration.lineThrough : null))),
              ]),
            ),
          );
        }).toList()),
      );
    });
  }

  Widget _buildCollapsible(String title, String content) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: Colors.grey[400], collapsedIconColor: Colors.grey[500],
          title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          children: [Text(content, style: TextStyle(fontSize: 12, color: Colors.grey[400], height: 1.5))],
        ),
      ),
    );
  }

  Widget _buildDataTable(TableData data, String? title) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Icon(Icons.table_chart, size: 16, color: Color(0xFF3B82F6)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))])),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF1E1E26)),
          columns: data.headers.map((h) => DataColumn(label: Text(h, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)))).toList(),
          rows: data.rows.map((r) => DataRow(cells: r.map((c) => DataCell(Text(c, style: TextStyle(fontSize: 11, color: Colors.grey[400])))).toList())).toList(),
        )),
      ]),
    );
  }

  Widget _buildCarousel(List<InfoCard> items) {
    final colors = [const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFF10B981), const Color(0xFFF59E0B)];
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      height: 140,
      child: PageView.builder(
        itemCount: items.length,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, i) {
          final item = items[i]; final color = item.color ?? colors[i % colors.length];
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withOpacity(0.3), color.withOpacity(0.1)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.5))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              if (item.icon != null) Icon(item.icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              if (item.subtitle != null) Text(item.subtitle!, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            ]),
          );
        },
      ),
    );
  }

  // ============== PHASE 3: MEDIA ==============

  Widget _buildAudioPlayer(String url, String? title, Duration? duration) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.play_arrow, color: Color(0xFF3B82F6), size: 28)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title ?? 'Audio', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 4),
          Row(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(2), child: const LinearProgressIndicator(value: 0, backgroundColor: Color(0xFF27272A), valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)), minHeight: 4))),
            const SizedBox(width: 8), Text(duration != null ? '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}' : '0:00', style: TextStyle(fontSize: 10, color: Colors.grey[500]))]),
        ])),
      ]),
    );
  }

  Widget _buildVideoPlayer(String url, String? title, String? thumbnail) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Column(children: [
        Container(height: 140, decoration: BoxDecoration(color: const Color(0xFF1E1E26), borderRadius: const BorderRadius.vertical(top: Radius.circular(11))),
          child: Center(child: Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: Colors.white, size: 36)))),
        Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFF16161E), borderRadius: BorderRadius.vertical(bottom: Radius.circular(11))),
          child: Row(children: [const Icon(Icons.videocam, size: 16, color: Color(0xFFEF4444)), const SizedBox(width: 8), Expanded(child: Text(title ?? 'Video', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)))])),
      ]),
    );
  }

  Widget _buildFileAttachment(String url, String title) {
    final ext = title.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: (isPdf ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file, color: isPdf ? const Color(0xFFEF4444) : const Color(0xFF3B82F6))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)), Text(ext.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey[500]))])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(6)),
          child: const Text('Download', style: TextStyle(fontSize: 11, color: Colors.white))),
      ]),
    );
  }

  Widget _buildVoiceMessage(Duration? duration) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF27272A))),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: Colors.white, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Row(children: List.generate(20, (i) => Container(width: 3, height: 8 + Random().nextDouble() * 12, margin: const EdgeInsets.only(right: 2), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.5), borderRadius: BorderRadius.circular(2)))))),
        const SizedBox(width: 8),
        Text(duration != null ? '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}' : '0:12', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ]),
    );
  }

  // ============== PHASE 4: ACTIONS ==============

  Widget _buildQuickActions(List<ActionButton> actions) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      child: Wrap(spacing: 8, runSpacing: 8, children: actions.map((a) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: (a.color ?? const Color(0xFF3B82F6)).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: (a.color ?? const Color(0xFF3B82F6)).withOpacity(0.5))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(a.icon, size: 16, color: a.color ?? const Color(0xFF3B82F6)), const SizedBox(width: 6), Text(a.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: a.color ?? const Color(0xFF3B82F6)))]),
        );
      }).toList()),
    );
  }

  Widget _buildContactCard(ContactData contact) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: const Color(0xFF3B82F6).withOpacity(0.2), child: Text(contact.name[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(contact.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          if (contact.role != null) Text(contact.role!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ])),
        if (contact.phone != null) Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.call, size: 18, color: Color(0xFF10B981))),
        const SizedBox(width: 8),
        if (contact.email != null) Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.email, size: 18, color: Color(0xFF3B82F6))),
      ]),
    );
  }

  Widget _buildCalendarEvent(CalendarEventData event) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: event.color ?? const Color(0xFF3B82F6))),
      child: Row(children: [
        Container(width: 48, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: (event.color ?? const Color(0xFF3B82F6)).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Column(children: [Text(event.date.split(' ').first, style: TextStyle(fontSize: 10, color: Colors.grey[400])), Text(event.date.split(' ').length > 1 ? event.date.split(' ')[1] : '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: event.color ?? const Color(0xFF3B82F6)))])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          if (event.time != null) Row(children: [Icon(Icons.access_time, size: 12, color: Colors.grey[500]), const SizedBox(width: 4), Text(event.time!, style: TextStyle(fontSize: 11, color: Colors.grey[500]))]),
          if (event.location != null) Row(children: [Icon(Icons.location_on, size: 12, color: Colors.grey[500]), const SizedBox(width: 4), Text(event.location!, style: TextStyle(fontSize: 11, color: Colors.grey[500]))]),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(6)),
          child: const Text('Add', style: TextStyle(fontSize: 11, color: Colors.white))),
      ]),
    );
  }

  // ============== PHASE 5: RICH FORMATTING ==============

  Widget _buildMarkdown(String content) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Text(content.replaceAll('**', '').replaceAll('*', '').replaceAll('#', ''), style: TextStyle(fontSize: 13, color: Colors.grey[300], height: 1.5)),
    );
  }

  Widget _buildMathEquation(String equation) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Row(children: [
        const Icon(Icons.functions, color: Color(0xFF8B5CF6), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(equation, style: const TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.white, fontStyle: FontStyle.italic))),
      ]),
    );
  }

  // ============== PHASE 6: BONUS ==============

  Widget _buildWeather(WeatherData weather) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)]), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(weather.icon, size: 48, color: Colors.white),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${weather.temperature.toInt()}°C', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(weather.condition, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
          Text(weather.location, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
        ]),
      ]),
    );
  }

  Widget _buildCountdown(CountdownData data) {
    final diff = data.targetDate.difference(DateTime.now());
    final days = diff.inDays; final hours = diff.inHours % 24;
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: (data.color ?? const Color(0xFFEF4444)).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: data.color ?? const Color(0xFFEF4444))),
      child: Column(children: [
        Icon(Icons.timer, color: data.color ?? const Color(0xFFEF4444), size: 28),
        const SizedBox(height: 8),
        Text(data.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _countdownUnit(days.toString(), 'Days'), const SizedBox(width: 16),
          _countdownUnit(hours.toString(), 'Hours'), const SizedBox(width: 16),
          _countdownUnit((diff.inMinutes % 60).toString(), 'Mins'),
        ]),
      ]),
    );
  }

  Widget _countdownUnit(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
    ]);
  }

  Widget _buildFlashcards(List<FlashcardData> cards) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      height: 140,
      child: PageView.builder(
        itemCount: cards.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, i) {
          return StatefulBuilder(builder: (context, setState) {
            bool flipped = false;
            return GestureDetector(
              onTap: () => setState(() => flipped = !flipped),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: LinearGradient(colors: flipped ? [const Color(0xFF10B981), const Color(0xFF06B6D4)] : [const Color(0xFF8B5CF6), const Color(0xFF3B82F6)]), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(flipped ? Icons.lightbulb : Icons.help_outline, color: Colors.white.withOpacity(0.5), size: 24),
                  const SizedBox(height: 8),
                  Text(flipped ? cards[i].back : cards[i].front, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Tap to ${flipped ? 'see question' : 'reveal answer'}', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
                ])),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildPdfPreview(String url, String? title) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.5))),
      child: Column(children: [
        Container(height: 120, decoration: BoxDecoration(color: const Color(0xFF1E1E26), borderRadius: const BorderRadius.vertical(top: Radius.circular(11))),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444), size: 40),
            const SizedBox(height: 8),
            Text(title ?? 'PDF Document', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ]))),
        Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFF16161E), borderRadius: BorderRadius.vertical(bottom: Radius.circular(11))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _pdfAction(Icons.visibility, 'View'),
            _pdfAction(Icons.download, 'Download'),
            _pdfAction(Icons.share, 'Share'),
          ])),
      ]),
    );
  }

  Widget _pdfAction(IconData icon, String label) {
    return Column(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: Colors.grey[400])),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
    ]);
  }

  // Helper for chart containers
  Widget _buildChartContainer(String? title, IconData icon, Color color, Widget child) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: const BoxDecoration(color: Color(0xFF161B22), borderRadius: BorderRadius.vertical(top: Radius.circular(11))),
          child: Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))])),
        Padding(padding: const EdgeInsets.all(16), child: child),
      ]),
    );
  }

  Widget _buildMapBlock(MapLocation center, List<MapLocation>? markers, double zoom) {
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
                const Icon(Icons.location_on, size: 16, color: Color(0xFF3B82F6)),
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
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
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
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.scheduleme.app',
                  ),
                  MarkerLayer(
                    markers: allMarkers.map((loc) => Marker(
                      point: LatLng(loc.latitude, loc.longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
                    )).toList(),
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
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21262D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(fontSize: 10, color: Colors.grey[400]),
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
          return _buildHorizontalGalleryImage(images[index], allImages: images, index: index);
        },
      ),
    );
  }

  Widget _buildHorizontalGalleryImage(AIResponseImage image, {List<AIResponseImage>? allImages, int index = 0}) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(image, allImages: allImages, initialIndex: index),
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
            Icon(Icons.image_rounded, color: Colors.white.withOpacity(0.25), size: 36),
            if (image.title != null)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    image.title!,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '1/${allImages.length}',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildSingleImage(AIResponseImage image, double maxWidth, {List<AIResponseImage>? allImages, int index = 0}) {
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
            onTap: () => _showFullScreenImage(image, allImages: allImages, initialIndex: index),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
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
                    Icon(Icons.image_rounded, color: Colors.white.withOpacity(0.3), size: 48),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.zoom_out_map, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('View', style: TextStyle(color: Colors.white, fontSize: 11)),
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
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
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

  Widget _buildGalleryImage(AIResponseImage image, double height, {List<AIResponseImage>? allImages, int index = 0}) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(image, allImages: allImages, initialIndex: index),
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
            Icon(Icons.image_rounded, color: Colors.white.withOpacity(0.25), size: 28),
            if (image.title != null)
              Positioned(
                bottom: 6,
                left: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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

  void _showFullScreenImage(AIResponseImage image, {List<AIResponseImage>? allImages, int initialIndex = 0}) {
    final images = allImages ?? [image];
    final startIndex = allImages != null ? initialIndex : 0;
    
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _FullScreenImageGallery(
        images: images,
        initialIndex: startIndex,
      ),
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
              Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(1000)), () {
                if (mounted) {
                  setState(() {
                    _isTyping = false;
                    _messages.add(ChatMessage(
                      isAi: true,
                      sender: 'Nexus AI',
                      message: _generateLoremIpsum(),
                    ));
                  });
                  _scrollToBottom();
                }
              });
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
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 4),
                child: Text(
                  message.sender,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              // Pending Attachments display
              if (message.pendingAttachments != null && message.pendingAttachments!.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: message.pendingAttachments!.map((att) => _buildSentAttachmentChip(att)).toList(),
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
          'Nexus is processing...',
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
            padding: EdgeInsets.fromLTRB(16, _pendingAttachments.isEmpty ? 12 : 8, 16, 24),
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
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
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
          top: BorderSide(color: const Color(0xFF10B981).withOpacity(0.5), width: 2),
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
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
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
                          color: Color.lerp(const Color(0xFF10B981), const Color(0xFFEF4444), _recordingAnimController!.value),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recording... ${_formatDuration(_recordingDuration)}',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.w500),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildAttachmentOption(Icons.camera_alt_rounded, 'Camera', const Color(0xFF3B82F6), () {
                  Navigator.pop(context);
                  _addAttachment(AttachmentType.camera, 'Photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildAttachmentOption(Icons.folder_rounded, 'File', const Color(0xFF8B5CF6), () {
                  Navigator.pop(context);
                  _showFilePickerSheet();
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildAttachmentOption(Icons.mic_rounded, 'Voice', const Color(0xFF10B981), () {
                  Navigator.pop(context);
                  _startRecording();
                })),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Choose File Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildFileTypeOption(Icons.image_rounded, 'Images', const Color(0xFF3B82F6), () {
                  Navigator.pop(context);
                  _addAttachment(AttachmentType.image, 'image_${DateTime.now().millisecondsSinceEpoch}.png');
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildFileTypeOption(Icons.picture_as_pdf_rounded, 'PDF', const Color(0xFFEF4444), () {
                  Navigator.pop(context);
                  _addAttachment(AttachmentType.file, 'document.pdf');
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildFileTypeOption(Icons.insert_drive_file_rounded, 'Other', const Color(0xFFF59E0B), () {
                  Navigator.pop(context);
                  _addAttachment(AttachmentType.file, 'file_${DateTime.now().millisecondsSinceEpoch}.txt');
                })),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeOption(IconData icon, String label, Color color, VoidCallback onTap) {
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
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }


  Widget _buildAttachmentOption(IconData icon, String label, Color color, VoidCallback onTap) {
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
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
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
  final List<AIContentBlock>? contentBlocks; // New: multiple text/image blocks in order

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

  PendingAttachment({
    required this.id,
    required this.type,
    required this.name,
  });
}

class AIResponseImage {
  final String url;
  final String? caption;
  final String? title;

  AIResponseImage({
    required this.url,
    this.caption,
    this.title,
  });
}

/// Content block types for multi-part AI responses
enum AIContentBlockType { 
  text, images, code, map, barChart, pieChart,
  // Phase 1: Data Visualization
  lineChart, radarChart, progressBars, timeline,
  // Phase 2: Interactive Content
  quiz, checklist, collapsible, dataTable, carousel,
  // Phase 3: Media
  audioPlayer, videoPlayer, fileAttachment, voiceMessage,
  // Phase 4: Actions
  quickActions, deepLinks, contactCard, calendarEvent,
  // Phase 5: Rich Formatting
  markdown, mathEquation,
  // Phase 6: Bonus
  weather, countdown, flashcards, pdfPreview,
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

  ProgressItem({required this.label, required this.value, this.max = 100, this.color});
}

/// Timeline event
class TimelineEvent {
  final String title;
  final String? description;
  final String date;
  final Color? color;
  final IconData? icon;

  TimelineEvent({required this.title, this.description, required this.date, this.color, this.icon});
}

/// Quiz data
class QuizData {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizData({required this.question, required this.options, required this.correctIndex});
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

  InfoCard({required this.title, this.subtitle, this.description, this.icon, this.color});
}

/// Action button
class ActionButton {
  final String label;
  final IconData icon;
  final Color? color;
  final String? action;

  ActionButton({required this.label, required this.icon, this.color, this.action});
}

/// Contact data
class ContactData {
  final String name;
  final String? role;
  final String? phone;
  final String? email;
  final String? avatarUrl;

  ContactData({required this.name, this.role, this.phone, this.email, this.avatarUrl});
}

/// Calendar event data
class CalendarEventData {
  final String title;
  final String date;
  final String? time;
  final String? location;
  final Color? color;

  CalendarEventData({required this.title, required this.date, this.time, this.location, this.color});
}

/// Weather data
class WeatherData {
  final String location;
  final double temperature;
  final String condition;
  final IconData icon;

  WeatherData({required this.location, required this.temperature, required this.condition, required this.icon});
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

  // Constructors for each type
  AIContentBlock.text(this.text) : type = AIContentBlockType.text, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.images(this.images) : type = AIContentBlockType.images, text = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.code(this.code, {this.language = 'dart'}) : type = AIContentBlockType.code, text = null, images = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.map({required this.mapCenter, this.mapMarkers, this.mapZoom = 15.0}) : type = AIContentBlockType.map, text = null, images = null, code = null, language = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.barChart({required this.chartData, this.chartTitle}) : type = AIContentBlockType.barChart, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, lineData = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.pieChart({required this.chartData, this.chartTitle}) : type = AIContentBlockType.pieChart, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, lineData = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.lineChart({required this.lineData, this.chartTitle}) : type = AIContentBlockType.lineChart, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.radarChart({required this.chartData, this.chartTitle}) : type = AIContentBlockType.radarChart, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, lineData = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.progressBars({required this.progressItems, this.chartTitle}) : type = AIContentBlockType.progressBars, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.timeline({required this.timelineEvents, this.chartTitle}) : type = AIContentBlockType.timeline, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, progressItems = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.quiz({required this.quizData}) : type = AIContentBlockType.quiz, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.checklist({required this.checklistItems, this.chartTitle}) : type = AIContentBlockType.checklist, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, progressItems = null, timelineEvents = null, quizData = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.collapsible({required this.collapsibleTitle, required this.collapsibleContent}) : type = AIContentBlockType.collapsible, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.dataTable({required this.tableData, this.chartTitle}) : type = AIContentBlockType.dataTable, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.carousel({required this.carouselItems, this.chartTitle}) : type = AIContentBlockType.carousel, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.audioPlayer({required this.mediaUrl, this.mediaTitle, this.mediaDuration}) : type = AIContentBlockType.audioPlayer, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.videoPlayer({required this.mediaUrl, this.mediaTitle, this.thumbnailUrl}) : type = AIContentBlockType.videoPlayer, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaDuration = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.fileAttachment({required this.mediaUrl, required this.mediaTitle}) : type = AIContentBlockType.fileAttachment, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.voiceMessage({this.mediaDuration}) : type = AIContentBlockType.voiceMessage, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.quickActions({required this.actionButtons}) : type = AIContentBlockType.quickActions, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.contactCard({required this.contactData}) : type = AIContentBlockType.contactCard, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.calendarEvent({required this.eventData}) : type = AIContentBlockType.calendarEvent, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.markdown({required this.markdownContent}) : type = AIContentBlockType.markdown, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, mathEquation = null;

  AIContentBlock.mathEquation({required this.mathEquation}) : type = AIContentBlockType.mathEquation, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null;

  AIContentBlock.weather({required this.weatherData}) : type = AIContentBlockType.weather, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.countdown({required this.countdownData}) : type = AIContentBlockType.countdown, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, flashcards = null, markdownContent = null, mathEquation = null;

  AIContentBlock.flashcards({required this.flashcards}) : type = AIContentBlockType.flashcards, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaUrl = null, mediaTitle = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, markdownContent = null, mathEquation = null;

  AIContentBlock.pdfPreview({required this.mediaUrl, this.mediaTitle}) : type = AIContentBlockType.pdfPreview, text = null, images = null, code = null, language = null, mapCenter = null, mapMarkers = null, mapZoom = null, chartData = null, lineData = null, chartTitle = null, progressItems = null, timelineEvents = null, quizData = null, checklistItems = null, collapsibleTitle = null, collapsibleContent = null, tableData = null, carouselItems = null, mediaDuration = null, thumbnailUrl = null, actionButtons = null, contactData = null, eventData = null, weatherData = null, countdownData = null, flashcards = null, markdownContent = null, mathEquation = null;
}

// Swipeable fullscreen image gallery
class _FullScreenImageGallery extends StatefulWidget {
  final List<AIResponseImage> images;
  final int initialIndex;

  const _FullScreenImageGallery({
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<_FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
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
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentImage.title ?? 'Image ${_currentIndex + 1}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        if (currentImage.caption != null)
                          Text(
                            currentImage.caption!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                      ],
                    ),
                  ),
                  // Page indicator text
                  if (widget.images.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${widget.images.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
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
                Icon(Icons.image_rounded, color: Colors.white.withOpacity(0.4), size: 64),
                const SizedBox(height: 16),
                Text(
                  image.title ?? 'Demo Image',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                ),
                if (image.caption != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    image.caption!,
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
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
