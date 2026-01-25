import 'package:flutter/material.dart';
import 'dart:math';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = []; // Start with empty chat
  bool _isTyping = false;

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

  String _generateLoremIpsum() {
    final random = Random();
    final sentenceCount = random.nextInt(3) + 2; // 2-4 sentences
    final sentences = <String>[];
    for (int i = 0; i < sentenceCount; i++) {
      sentences.add(_loremSentences[random.nextInt(_loremSentences.length)]);
    }
    return sentences.join(' ');
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(isAi: false, sender: 'You', message: text));
      _messageController.clear();
      _isTyping = true;
    });

    // Scroll to bottom
    _scrollToBottom();

    // Simulate AI "thinking" delay (1-2 seconds)
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0C).withOpacity(0.95),
        border: Border(
          top: BorderSide(color: const Color(0xFF27272A), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Add Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF16161E),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF27272A)),
            ),
            child: Icon(Icons.add, color: Colors.grey[400], size: 22),
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask anything about your courses...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),

                ],
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
    );
  }
}

class ChatMessage {
  final bool isAi;
  final String sender;
  final String message;
  final ChatAttachment? attachment;

  ChatMessage({
    required this.isAi,
    required this.sender,
    required this.message,
    this.attachment,
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
