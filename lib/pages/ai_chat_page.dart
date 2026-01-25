import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

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
          
          if (useMultiBlock) {
            // Multi-block response with alternating text and images
            _messages.add(ChatMessage(
              isAi: true,
              sender: 'Nexus AI',
              message: '', // Not used when contentBlocks is provided
              contentBlocks: _generateMultiBlockResponse(devImageCount ?? 3),
            ));
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
    }
    return const SizedBox.shrink();
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
enum AIContentBlockType { text, images }

/// A single content block in an AI response (either text or images)
class AIContentBlock {
  final AIContentBlockType type;
  final String? text;
  final List<AIResponseImage>? images;

  AIContentBlock.text(this.text)
      : type = AIContentBlockType.text,
        images = null;

  AIContentBlock.images(this.images)
      : type = AIContentBlockType.images,
        text = null;
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
