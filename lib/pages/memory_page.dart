import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui'; // For ImageFilter

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> with TickerProviderStateMixin {
  int _selectedLayout = 1;
  
  // Sample memory data for demo
  final List<MemoryItem> _memories = [
    MemoryItem(
      id: '1',
      title: 'Exam preparation tips',
      content: 'Focus on understanding concepts rather than memorization. Use active recall and spaced repetition for better retention.',
      category: MemoryCategory.aiChat,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.psychology,
    ),
    MemoryItem(
      id: '2',
      title: 'Physics formulas',
      content: 'F = ma, E = mc², v = u + at, s = ut + ½at², KE = ½mv²',
      category: MemoryCategory.notes,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.functions,
    ),
    MemoryItem(
      id: '3',
      title: 'Study schedule',
      content: 'Morning: Math (2hrs), Afternoon: Physics (2hrs), Evening: Review and practice problems',
      category: MemoryCategory.planner,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.schedule,
    ),
    MemoryItem(
      id: '4',
      title: 'Important deadlines',
      content: 'Assignment due: Feb 5, Mid-term exam: Feb 15, Project submission: Feb 20',
      category: MemoryCategory.reminder,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.alarm,
    ),
    MemoryItem(
      id: '5',
      title: 'Chemistry notes',
      content: 'Periodic table trends: Electronegativity increases left to right, Atomic radius decreases left to right',
      category: MemoryCategory.notes,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      icon: Icons.science,
    ),
    MemoryItem(
      id: '6',
      title: 'Motivation quote',
      content: 'The only way to do great work is to love what you do. - Steve Jobs',
      category: MemoryCategory.bookmark,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      icon: Icons.format_quote,
    ),
  ];

  // For expandable list (Layout 4)
  int? _expandedIndex;

  // For calendar view (Layout 5)
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _buildSelectedLayout(),
            ),
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
        border: const Border(
          bottom: BorderSide(color: Color(0xFF27272A), width: 1),
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
          const SizedBox(width: 16),
          // Title
          Text(
            'Memories',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Previous Layout Button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedLayout = _selectedLayout > 1 ? _selectedLayout - 1 : 22;
              });
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Icon(Icons.chevron_left, color: Colors.grey[400], size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // Layout Selector Button
          GestureDetector(
            onTap: _showLayoutSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dashboard_customize, color: Colors.grey[400], size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Layout $_selectedLayout',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Next Layout Button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedLayout = _selectedLayout < 22 ? _selectedLayout + 1 : 1;
              });
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ),
          ),
        ],
      ),
    );
  }


  void _showLayoutSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF16161E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.dashboard_customize, color: Color(0xFF3B82F6), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Choose Layout',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF27272A), height: 1),
            // Layout Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildLayoutOption(1, 'Card Grid', Icons.grid_view, const Color(0xFF3B82F6)),
                  _buildLayoutOption(2, 'Timeline', Icons.timeline, const Color(0xFF10B981)),
                  _buildLayoutOption(3, 'Masonry Gallery', Icons.dashboard, const Color(0xFFF59E0B)),
                  _buildLayoutOption(4, 'Expandable List', Icons.list_alt, const Color(0xFF8B5CF6)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Advanced Layouts', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  _buildLayoutOption(5, 'Kanban Board', Icons.view_kanban, const Color(0xFF06B6D4)),
                  _buildLayoutOption(6, 'Magazine', Icons.article, const Color(0xFFE11D48)),
                  _buildLayoutOption(7, 'Control Center', Icons.settings_suggest, const Color(0xFFF43F5E)),
                  _buildLayoutOption(8, 'Flow Timeline', Icons.linear_scale, const Color(0xFF0891B2)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('System Layouts', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  _buildLayoutOption(9, 'Analytics Hub', Icons.insights, const Color(0xFF3B82F6)),
                  _buildLayoutOption(10, 'Wiki Knowledge', Icons.menu_book, const Color(0xFFEC4899)),
                  _buildLayoutOption(11, 'Timeline Pro', Icons.history_edu, const Color(0xFF14B8A6)),
                  _buildLayoutOption(12, 'Focus Mode', Icons.center_focus_strong, const Color(0xFF6366F1)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Premium Layouts', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  _buildLayoutOption(13, 'Glassmorphism', Icons.blur_on, const Color(0xFFC850C0)),
                  _buildLayoutOption(14, 'Neo-Brutalism', Icons.branding_watermark, Colors.white),
                  _buildLayoutOption(15, 'Minimal Editorial', Icons.article_outlined, const Color(0xFF9E9E9E)),
                  _buildLayoutOption(16, 'Cyberpunk', Icons.terminal, const Color(0xFF00FF41)),
                  _buildLayoutOption(17, 'Polaroid', Icons.photo_camera_back, const Color(0xFF8D6E63)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Analog Variations', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  _buildLayoutOption(18, 'Cork Board', Icons.push_pin, const Color(0xFFD2B48C)),
                  _buildLayoutOption(19, 'Film Strip', Icons.movie, const Color(0xFF1F1F1F)),
                  _buildLayoutOption(20, 'Sticky Notes', Icons.note, const Color(0xFFFEF08A)),
                  _buildLayoutOption(21, 'Index Cards', Icons.style, const Color(0xFF9CA3AF)),
                  _buildLayoutOption(22, 'Passport', Icons.airplane_ticket, const Color(0xFF3B82F6)),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutOption(int layoutNumber, String title, IconData icon, Color color) {
    final isSelected = _selectedLayout == layoutNumber;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLayout = layoutNumber);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF27272A),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.white,
                    ),
                  ),
                  Text(
                    'Layout $layoutNumber',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 22),
          ],
        ),
      ),
    );
  }


  Widget _buildSelectedLayout() {
    switch (_selectedLayout) {
      case 1:
        return _buildLayout1CardGrid();
      case 2:
        return _buildLayout2Timeline();
      case 3:
        return _buildLayout3Masonry();
      case 4:
        return _buildLayout4ExpandableList();
      case 5:
        return _buildLayout5Kanban();
      case 6:
        return _buildLayout6Magazine();
      case 7:
        return _buildLayout7ControlCenter();
      case 8:
        return _buildLayout8FlowTimeline();
      case 9:
        return _buildLayout9AnalyticsHub();
      case 10:
        return _buildLayout10WikiKnowledge();
      case 11:
        return _buildLayout11TimelinePro();
      case 12:
        return _buildLayout12FocusMode();
      case 13:
        return _buildLayout13Glass();
      case 14:
        return _buildLayout14Brutalism();
      case 15:
        return _buildLayout15MinimalEditorial();
      case 16:
        return _buildLayout16Cyberpunk();
      case 17:
        return _buildLayout17Polaroid();
      case 18:
        return _buildLayout18CorkBoard();
      case 19:
        return _buildLayout19FilmStrip();
      case 20:
        return _buildLayout20StickyNotes();
      case 21:
        return _buildLayout21IndexCards();
      case 22:
        return _buildLayout22Passport();
      default:
        return _buildLayout1CardGrid();
    }
  }






  // ============================================================
  // LAYOUT 1: Memory Cards Grid
  // ============================================================
  Widget _buildLayout1CardGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.grid_view, size: 16, color: const Color(0xFF3B82F6)),
                    const SizedBox(width: 6),
                    Text(
                      'Grid View',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${_memories.length} memories',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                return _buildGridCard(memory, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(MemoryItem memory, int index) {
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      [const Color(0xFFfc466b), const Color(0xFF3f5efb)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
    ];
    final gradient = gradients[index % gradients.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(memory.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              memory.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            // Content snippet
            Expanded(
              child: Text(
                memory.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Timestamp
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(memory.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LAYOUT 2: Timeline View
  // ============================================================
  Widget _buildLayout2Timeline() {
    // Group memories by date
    final groupedMemories = <String, List<MemoryItem>>{};
    for (final memory in _memories) {
      final dateKey = _getDateLabel(memory.timestamp);
      groupedMemories.putIfAbsent(dateKey, () => []).add(memory);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timeline, size: 16, color: const Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      'Timeline',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Timeline List
          Expanded(
            child: ListView.builder(
              itemCount: groupedMemories.length,
              itemBuilder: (context, groupIndex) {
                final dateKey = groupedMemories.keys.elementAt(groupIndex);
                final memories = groupedMemories[dateKey]!;
                return _buildTimelineGroup(dateKey, memories, groupIndex == groupedMemories.length - 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineGroup(String dateLabel, List<MemoryItem> memories, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and dot
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0A0A0C), width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: memories.length * 100.0 + 20,
                color: const Color(0xFF27272A),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date label
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),
              // Memory cards for this date
              ...memories.map((memory) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTimelineCard(memory),
              )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(MemoryItem memory) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getCategoryColor(memory.category).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              memory.icon,
              size: 18,
              color: _getCategoryColor(memory.category),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  memory.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getCategoryLabel(memory.category),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getCategoryColor(memory.category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 3: Masonry/Pinterest Gallery
  // ============================================================
  Widget _buildLayout3Masonry() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard, size: 16, color: const Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    Text(
                      'Gallery',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Masonry Grid
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    children: _memories
                        .asMap()
                        .entries
                        .where((e) => e.key % 2 == 0)
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMasonryCard(e.value, e.key),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 12),
                // Right column (with offset)
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 40), // Offset for stagger effect
                      ..._memories
                          .asMap()
                          .entries
                          .where((e) => e.key % 2 == 1)
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildMasonryCard(e.value, e.key),
                              )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasonryCard(MemoryItem memory, int index) {
    // Variable heights based on content length
    final heights = [140.0, 180.0, 160.0, 200.0, 150.0, 170.0];
    final height = heights[index % heights.length];

    final colors = [
      const Color(0xFF1E1E2E),
      const Color(0xFF1A1A2E),
      const Color(0xFF16213E),
      const Color(0xFF0F3460),
      const Color(0xFF1B1B2F),
      const Color(0xFF162447),
    ];

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getCategoryColor(memory.category).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Glassmorphism effect
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getCategoryColor(memory.category).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(memory.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getCategoryLabel(memory.category),
                      style: TextStyle(
                        fontSize: 9,
                        color: _getCategoryColor(memory.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    memory.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Content
                  Expanded(
                    child: Text(
                      memory.content,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        height: 1.4,
                      ),
                    ),
                  ),
                  // Bottom row
                  Row(
                    children: [
                      Icon(memory.icon, size: 14, color: Colors.grey[600]),
                      const Spacer(),
                      Text(
                        _formatTimestamp(memory.timestamp),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LAYOUT 4: Expandable List
  // ============================================================
  Widget _buildLayout4ExpandableList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt, size: 16, color: const Color(0xFF8B5CF6)),
                    const SizedBox(width: 6),
                    Text(
                      'List View',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Expandable List
          Expanded(
            child: ListView.builder(
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                final isExpanded = _expandedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildExpandableItem(memory, index, isExpanded),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableItem(MemoryItem memory, int index, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? _getCategoryColor(memory.category).withOpacity(0.5)
              : const Color(0xFF27272A),
        ),
      ),
      child: Column(
        children: [
          // Header (always visible)
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(memory.category).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      memory.icon,
                      size: 20,
                      color: _getCategoryColor(memory.category),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memory.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatTimestamp(memory.timestamp)} • ${_getCategoryLabel(memory.category)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFF27272A)),
                  const SizedBox(height: 10),
                  Text(
                    memory.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Action buttons
                  Row(
                    children: [
                      _buildActionChip(Icons.copy, 'Copy'),
                      const SizedBox(width: 8),
                      _buildActionChip(Icons.share, 'Share'),
                      const SizedBox(width: 8),
                      _buildActionChip(Icons.delete_outline, 'Delete', isDestructive: true),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red[400]! : Colors.grey[400]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 5: Calendar Integration View
  // ============================================================


  // ============================================================
  // Helper Methods
  // ============================================================

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _getDateLabel(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (date == today) {
      return 'Today';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(timestamp.month)} ${timestamp.day}';
    }
  }

  String _getFullDateLabel(DateTime date) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return '${days[date.weekday % 7]}, ${_getMonthName(date.month)} ${date.day}';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Color _getCategoryColor(MemoryCategory category) {
    switch (category) {
      case MemoryCategory.aiChat:
        return const Color(0xFF3B82F6);
      case MemoryCategory.notes:
        return const Color(0xFF10B981);
      case MemoryCategory.planner:
        return const Color(0xFFF59E0B);
      case MemoryCategory.reminder:
        return const Color(0xFFEF4444);
      case MemoryCategory.bookmark:
        return const Color(0xFF8B5CF6);
    }
  }

  String _getCategoryLabel(MemoryCategory category) {
    switch (category) {
      case MemoryCategory.aiChat:
        return 'AI Chat';
      case MemoryCategory.notes:
        return 'Notes';
      case MemoryCategory.planner:
        return 'Planner';
      case MemoryCategory.reminder:
        return 'Reminder';
      case MemoryCategory.bookmark:
        return 'Bookmark';
    }
  }

  // ============================================================
  // LAYOUT 5: Kanban Board
  // ============================================================
  Widget _buildLayout5Kanban() {
    final columns = ['To Review', 'Important', 'Archived'];
    final columnColors = [const Color(0xFF06B6D4), const Color(0xFFF59E0B), const Color(0xFF6B7280)];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Kanban Board', Icons.view_kanban, const Color(0xFF06B6D4)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: columns.length,
              itemBuilder: (context, colIndex) {
                final colMemories = _memories.where((m) => m.id.hashCode % 3 == colIndex).toList();
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: columnColors[colIndex].withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: columnColors[colIndex], shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(columns[colIndex], style: TextStyle(color: columnColors[colIndex], fontWeight: FontWeight.w600, fontSize: 13)),
                            const Spacer(),
                            Text('${colMemories.length}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: colMemories.length,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16161E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF27272A)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(colMemories[index].title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                                const SizedBox(height: 6),
                                Text(colMemories[index].content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(colMemories[index].icon, size: 12, color: _getCategoryColor(colMemories[index].category)),
                                    const Spacer(),
                                    Text(_formatTimestamp(colMemories[index].timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 7: Mind Map
  // ============================================================


  // ============================================================
  // LAYOUT 8: Card Stack (Tinder-like)
  // ============================================================


  // ============================================================
  // LAYOUT 6: Magazine Style
  // ============================================================
  Widget _buildLayout6Magazine() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Magazine', Icons.article, const Color(0xFFE11D48)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                final isFeature = index == 0;
                if (isFeature) {
                  return Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [const Color(0xFFE11D48), const Color(0xFFBE123C)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        Text(memory.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(memory.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                      ],
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: _getCategoryColor(memory.category).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Icon(memory.icon, color: _getCategoryColor(memory.category), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(memory.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(memory.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(_formatTimestamp(memory.timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 10: Metro Tiles (Windows-style)
  // ============================================================


  Widget _buildLayoutHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const Spacer(),
        Text('${_memories.length} memories', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  // ============================================================
  // LAYOUT 11: Neural Network (AI Memory Visualization)
  // ============================================================


  // ============================================================
  // LAYOUT 12: Data Flow (Chat to Memory Pipeline)
  // ============================================================


  // ============================================================
  // LAYOUT 13: Multi-Agent Dashboard
  // ============================================================


  // ============================================================
  // LAYOUT 14: Memory Graph (Connections & Categories)
  // ============================================================


  // ============================================================
  // LAYOUT 7: Control Center
  // ============================================================
  Widget _buildLayout7ControlCenter() {
    final stats = [
      {'label': 'Total Memories', 'value': '152', 'icon': Icons.memory, 'color': const Color(0xFFF43F5E)},
      {'label': 'Storage Used', 'value': '2.4 GB', 'icon': Icons.storage, 'color': const Color(0xFF3B82F6)},
      {'label': 'Active Agents', 'value': '4', 'icon': Icons.smart_toy, 'color': const Color(0xFF22C55E)},
      {'label': 'Last Sync', 'value': '2m ago', 'icon': Icons.sync, 'color': const Color(0xFFF59E0B)},
    ];

    final actions = [
      {'label': 'Clear Cache', 'icon': Icons.cleaning_services, 'color': const Color(0xFFEF4444)},
      {'label': 'Export Data', 'icon': Icons.download, 'color': const Color(0xFF3B82F6)},
      {'label': 'Sync Now', 'icon': Icons.cloud_sync, 'color': const Color(0xFF22C55E)},
      {'label': 'Settings', 'icon': Icons.settings, 'color': const Color(0xFF6B7280)},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Control Center', Icons.settings_suggest, const Color(0xFFF43F5E)),
          const SizedBox(height: 16),
          // Stats Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF16161E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (stat['color'] as Color).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 20),
                        const Spacer(),
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: stat['color'] as Color, shape: BoxShape.circle)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stat['value'] as String, style: TextStyle(color: stat['color'] as Color, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(stat['label'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Quick Actions
          Row(
            children: actions.map((action) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: action != actions.last ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: (action['color'] as Color).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(action['icon'] as IconData, color: action['color'] as Color, size: 20),
                    const SizedBox(height: 6),
                    Text(action['label'] as String, style: TextStyle(color: action['color'] as Color, fontSize: 9, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          // Recent Activity Log
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: Color(0xFFF43F5E), size: 18),
                        const SizedBox(width: 8),
                        const Text('Activity Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('Today', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF27272A), height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _memories.length,
                      itemBuilder: (context, index) {
                        final memory = _memories[index];
                        final actions = ['Created', 'Updated', 'Synced', 'Accessed'];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(color: _getCategoryColor(memory.category), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                    children: [
                                      TextSpan(text: actions[index % actions.length], style: TextStyle(color: _getCategoryColor(memory.category), fontWeight: FontWeight.w500)),
                                      const TextSpan(text: ' memory: '),
                                      TextSpan(text: memory.title, style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                              Text(_formatTimestamp(memory.timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 16: Dashboard Pro (Inspired by 15 + 1)
  // ============================================================


  // ============================================================
  // LAYOUT 8: Flow Timeline
  // ============================================================
  Widget _buildLayout8FlowTimeline() {
    final stages = ['Input', 'Process', 'Store', 'Retrieve'];
    final stageColors = [const Color(0xFF0891B2), const Color(0xFFF59E0B), const Color(0xFF22C55E), const Color(0xFF8B5CF6)];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Flow Timeline', Icons.linear_scale, const Color(0xFF0891B2)),
          const SizedBox(height: 16),
          // Flow stages
          Container(
            height: 60,
            child: Row(
              children: List.generate(stages.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return Container(width: 30, height: 3, decoration: BoxDecoration(gradient: LinearGradient(colors: [stageColors[index ~/ 2], stageColors[index ~/ 2 + 1]])));
                }
                final i = index ~/ 2;
                return Container(
                  width: 60,
                  child: Column(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: stageColors[i].withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: stageColors[i], width: 2)),
                        child: Center(child: Text('${i + 1}', style: TextStyle(color: stageColors[i], fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(height: 4),
                      Text(stages[i], style: TextStyle(color: stageColors[i], fontSize: 9, fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Timeline with flow indicators
          Expanded(
            child: ListView.builder(
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                final stage = index % stages.length;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline
                      Column(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: stageColors[stage], shape: BoxShape.circle)),
                          if (index < _memories.length - 1) Expanded(child: Container(width: 2, color: const Color(0xFF27272A))),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Card
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16161E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: stageColors[stage].withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: stageColors[stage].withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                child: Text(stages[stage], style: TextStyle(color: stageColors[stage], fontSize: 9, fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(memory.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                    Text(_formatTimestamp(memory.timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                  ],
                                ),
                              ),
                              Icon(memory.icon, color: _getCategoryColor(memory.category), size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 18: News Feed (Inspired by 9 + 4)
  // ============================================================


  // ============================================================
  // LAYOUT 19: Workspace Board (Inspired by 6 + 3)
  // ============================================================

  // ============================================================
  // LAYOUT 9: Analytics Hub
  // ============================================================
  Widget _buildLayout9AnalyticsHub() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLayoutHeader('Analytics Hub', Icons.insights, const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          // Main Chart Area (Simulated)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.show_chart, color: Color(0xFF3B82F6), size: 18),
                      const SizedBox(width: 8),
                      const Text('Memory Access Trends', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Last 30 Days', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(14, (index) {
                        final height = 20.0 + (index * 7 % 100) + (index % 3 * 20);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 8,
                              height: height,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(index == 13 ? 1.0 : 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Stats Grid
          Expanded(
            flex: 3,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildAnalyticsCard('Total Memories', '${_memories.length}', Icons.storage, const Color(0xFFF97316)),
                _buildAnalyticsCard('Categories', '${MemoryCategory.values.length}', Icons.category, const Color(0xFF10B981)),
                _buildAnalyticsCard('Avg. Length', '142 chars', Icons.format_align_left, const Color(0xFF8B5CF6)),
                _buildAnalyticsCard('Attachments', '24', Icons.attach_file, const Color(0xFFEC4899)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 22: Project Desk (Kanban + Todo + Calendar)
  // ============================================================


  // ============================================================
  // LAYOUT 23: Code Terminal (Monospace + Log Style)
  // ============================================================


  // ============================================================
  // LAYOUT 24: Galaxy View (Radial Scatter)
  // ============================================================


  // ============================================================
  // LAYOUT 10: Wiki Knowledge
  // ============================================================
  Widget _buildLayout10WikiKnowledge() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLayoutHeader('Wiki Base', Icons.menu_book, const Color(0xFFEC4899)),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar: TOC
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Color(0xFF27272A))),
                  ),
                  child: ListView(
                    children: [
                      const Text('CONTENTS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 12),
                      ...MemoryCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_getCategoryLabel(cat), style: TextStyle(color: _getCategoryColor(cat), fontSize: 11, fontWeight: FontWeight.w500)),
                      )),
                      const Divider(color: Color(0xFF27272A)),
                      const Text('Introduction', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 8),
                      const Text('References', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 16),
                    itemCount: _memories.length,
                    itemBuilder: (context, index) {
                      final memory = _memories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(memory.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')), // Serif for wiki look
                             const Padding(
                               padding: EdgeInsets.symmetric(vertical: 8),
                               child: Divider(color: Color(0xFF27272A)),
                             ),
                             Text(memory.content, style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.6, fontFamily: 'serif')),
                             const SizedBox(height: 8),
                             Row(
                               children: [
                                 Text('[edit]', style: TextStyle(color: Colors.blue[400], fontSize: 10)),
                                 const SizedBox(width: 8),
                                 Text('Updated ${_formatTimestamp(memory.timestamp)}', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontStyle: FontStyle.italic)),
                               ],
                             ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 26: Media Studio (Grid + Preview)
  // ============================================================


  // ============================================================
  // LAYOUT 27: Priority Matrix (Eisenhower Grid)
  // ============================================================


  // ============================================================
  // LAYOUT 11: Timeline Pro
  // ============================================================
  Widget _buildLayout11TimelinePro() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLayoutHeader('Timeline Pro', Icons.history_edu, const Color(0xFF14B8A6)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                return IntrinsicHeight(
                  child: Row(
                    children: [
                      // Date side
                      Container(
                        width: 50,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(index == 0 ? 'Now' : '${index}h', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('ago', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                          ],
                        ),
                      ),
                      // Line
                      Column(
                        children: [
                          Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF16161E),
                              shape: BoxShape.circle,
                              border: Border.all(color: _getCategoryColor(memory.category), width: 2),
                            ),
                          ),
                          Expanded(
                            child: Container(width: 2, color: const Color(0xFF27272A)),
                          ),
                        ],
                      ),
                      // Content
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 0, 24),
                          padding: const EdgeInsets.all(16),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: _getCategoryColor(memory.category).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                    child: Text(_getCategoryLabel(memory.category), style: TextStyle(color: _getCategoryColor(memory.category), fontSize: 9)),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.more_horiz, color: Colors.grey, size: 16),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(memory.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(memory.content, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 29: Conversation Thread (Chat Style)
  // ============================================================


  // ============================================================
  // LAYOUT 12: Focus Mode
  // ============================================================
  Widget _buildLayout12FocusMode() {
    return Stack(
      children: [
        // Ambient Background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [const Color(0xFF6366F1).withOpacity(0.2), Colors.black],
                stops: const [0.0, 0.8],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.center_focus_strong, color: Color(0xFF6366F1), size: 32),
              const SizedBox(height: 16),
              const Text('FOCUS MODE', style: TextStyle(color: Colors.white, letterSpacing: 4, fontSize: 12)),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF16161E),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.2), blurRadius: 40, spreadRadius: 0),
                  ],
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(_memories.first.category).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_memories.first.icon, size: 40, color: _getCategoryColor(_memories.first.category)),
                    ),
                    const SizedBox(height: 24),
                    Text(_memories.first.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(_memories.first.content, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.5)),
                    const SizedBox(height: 32),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         IconButton(onPressed: (){}, icon: const Icon(Icons.close, color: Colors.grey)),
                         const SizedBox(width: 32),
                         FloatingActionButton(
                           backgroundColor: const Color(0xFF6366F1),
                           onPressed: (){},
                           child: const Icon(Icons.check, color: Colors.white),
                         ),
                       ],
                     ),
                  ],
                ),
              ),
              const Spacer(),
              Text('Swipe for next memory', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }


  // ============================================================
  // LAYOUT 13: Glassmorphism Grid
  // ============================================================
  Widget _buildLayout13Glass() {
    return Stack(
      children: [
        // Ambient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4158D0), Color(0xFFC850C0), Color(0xFFFFCC70)],
            ),
          ),
        ),
        // Glass Grid
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
               _buildLayoutHeader('Glassmorphism', Icons.blur_on, Colors.white),
               const SizedBox(height: 16),
               Expanded(
                 child: GridView.builder(
                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2,
                     crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                     childAspectRatio: 0.8,
                   ),
                   itemCount: _memories.length,
                   itemBuilder: (context, index) {
                     final memory = _memories[index];
                     return ClipRRect(
                       borderRadius: BorderRadius.circular(20),
                       child: BackdropFilter(
                         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                         child: Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.2),
                             border: Border.all(color: Colors.white.withOpacity(0.3)),
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withOpacity(0.3),
                                   shape: BoxShape.circle,
                                 ),
                                 child: Icon(memory.icon, color: Colors.white, size: 20),
                               ),
                               const Spacer(),
                               Text(
                                 memory.title,
                                 style: GoogleFonts.outfit(
                                   fontSize: 16,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.white,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 memory.content,
                                 maxLines: 3,
                                 overflow: TextOverflow.ellipsis,
                                 style: GoogleFonts.outfit(
                                   fontSize: 12,
                                   color: Colors.white.withOpacity(0.8),
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     );
                   },
                 ),
               ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LAYOUT 14: Neo-Brutalism List
  // ============================================================
  Widget _buildLayout14Brutalism() {
    final bgColors = [const Color(0xFFFEF08A), const Color(0xFFE9D5FF), const Color(0xFFBAF7D0), const Color(0xFFFECACA), const Color(0xFFBFDBFE)];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF08A),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                child: const Text('NEO-BRUTALISM', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _memories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final memory = _memories[index];
                final bgColor = bgColors[index % bgColors.length];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(memory.icon, color: Colors.black, size: 24),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                             color: Colors.black,
                             borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(_getCategoryLabel(memory.category).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                          const Spacer(),
                          Text(_formatTimestamp(memory.timestamp), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(memory.title, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(memory.content, style: const TextStyle(color: Colors.black, fontSize: 14)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 15: Minimal Editorial
  // ============================================================
  Widget _buildLayout15MinimalEditorial() {
    return Container(
      color: const Color(0xFFFAFAFA), // Light background
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'M E M O R I E S',
              style: GoogleFonts.playfairDisplay(
                color: Colors.black87,
                fontSize: 24,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: _memories.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Colors.black12, thickness: 1),
              ),
              itemBuilder: (context, index) {
                final memory = _memories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(memory.timestamp).toUpperCase(),
                          style: GoogleFonts.lato(
                            color: Colors.grey[600],
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        Icon(memory.icon, color: Colors.black54, size: 16),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      memory.title,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.black87,
                        fontSize: 22,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      memory.content,
                      style: GoogleFonts.lato(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 16: Cyberpunk Stream
  // ============================================================
  Widget _buildLayout16Cyberpunk() {
    return Container(
      color: const Color(0xFF050510),
      child: Column(
        children: [
          // Glitchy Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF00FF41), width: 1)),
            ),
            child: Text(
              'SYSTEM_MEMORIES_V4.0 // CONNECTED',
              style: GoogleFonts.shareTechMono(
                color: const Color(0xFF00FF41),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                final isPink = index % 2 == 0;
                final accentColor = isPink ? const Color(0xFFFF00FF) : const Color(0xFF00FFFF);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(2), // Border width
                  decoration: BoxDecoration(
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 1),
                    ],
                  ),
                  child: Container(
                    color: const Color(0xFF0D0D15),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.terminal, color: accentColor, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'ID: ${memory.id.padLeft(4, '0')}',
                              style: GoogleFonts.shareTechMono(color: accentColor, fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              '[ENCRYPTED]',
                              style: GoogleFonts.shareTechMono(color: Colors.grey[700], fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '> ${memory.title}',
                          style: GoogleFonts.shareTechMono(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          memory.content,
                          style: GoogleFonts.shareTechMono(
                            color: const Color(0xFFB0B0B0),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 17: Polaroid Scatter
  // ============================================================
  Widget _buildLayout17Polaroid() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF8D6E63), // Wood color equivalent
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: _memories.asMap().entries.map((entry) {
            final index = entry.key;
            final memory = entry.value;
            final rotate = (index % 5 - 2) * 0.05; // -0.1 to 0.1 radians ~ -6 to 6 degrees
            
            return Transform.rotate(
              angle: rotate,
              child: Container(
                margin: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: _getCategoryColor(memory.category).withOpacity(0.1),
                      child: Center(
                        child: Icon(memory.icon, size: 64, color: _getCategoryColor(memory.category)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                       memory.title,
                       style: GoogleFonts.caveat(
                         color: Colors.black87,
                         fontSize: 24,
                         fontWeight: FontWeight.bold,
                       ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(memory.timestamp),
                      style: GoogleFonts.caveat(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // LAYOUT 18: Cork Board
  // ============================================================
  Widget _buildLayout18CorkBoard() {
    return Container(
      color: const Color(0xFFD2B48C), // Cork color
      child: Stack(
        children: [
          // Texture simulation (simple noise points could be here, but solid color is fine for MVP)
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.85,
            ),
            itemCount: _memories.length,
            itemBuilder: (context, index) {
              final memory = _memories[index];
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                   Container(
                     padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                     decoration: const BoxDecoration(
                       color: Color(0xFFFFFBEB), // Paper color
                       boxShadow: [
                         BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
                       ],
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Icon(memory.icon, size: 16, color: Colors.brown),
                             const SizedBox(width: 4),
                             Expanded(child: Text(memory.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown))),
                           ],
                         ),
                         const Divider(color: Colors.brown, thickness: 0.5),
                         Expanded(
                           child: Text(
                             memory.content, 
                             style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.2),
                             maxLines: 5,
                             overflow: TextOverflow.fade,
                           ),
                         ),
                       ],
                     ),
                   ),
                   // Push Pin
                   Positioned(
                     top: -8,
                     child: Icon(Icons.push_pin, color: Colors.red[700], size: 24),
                   ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 19: Film Strip
  // ============================================================
  Widget _buildLayout19FilmStrip() {
    return Container(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _memories.length,
            itemBuilder: (context, index) {
              final memory = _memories[index];
              return Container(
                margin: const EdgeInsets.only(right: 2),
                width: 220,
                color: Colors.black,
                child: Column(
                  children: [
                    // Top Sprockets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) => Container(width: 12, height: 8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)))),
                    ),
                    // Frame
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1F1F),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(memory.icon, color: Colors.white70, size: 32),
                            const SizedBox(height: 12),
                            Text(
                              memory.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom Sprockets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) => Container(width: 12, height: 8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)))),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LAYOUT 20: Sticky Notes
  // ============================================================
  Widget _buildLayout20StickyNotes() {
    final colors = [const Color(0xFFFEF08A), const Color(0xFFFBCFE8), const Color(0xFFBAF7D0), const Color(0xFFBFDBFE)];
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _memories.length,
        itemBuilder: (context, index) {
          final memory = _memories[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Spacer(), Icon(memory.icon, size: 16, color: Colors.black54)]),
                Text(memory.title, style: GoogleFonts.permanentMarker(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                Expanded(child: Text(memory.content, style: GoogleFonts.kalam(fontSize: 12, color: Colors.black87))),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // LAYOUT 21: Index Cards
  // ============================================================
  Widget _buildLayout21IndexCards() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _memories.length,
        itemBuilder: (context, index) {
          final memory = _memories[index];
          return Container(
            height: 160,
            margin: EdgeInsets.only(bottom: index == _memories.length - 1 ? 0 : 0), // Normal list
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // The Card
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: index * 0.0), // No overlap logic simple list for now to avoid complexity errors
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Column(
                    children: [
                      // Red Line
                      Container(height: 1, color: Colors.red[200], margin: const EdgeInsets.only(top: 30)),
                      const SizedBox(height: 2),
                      Container(height: 1, color: Colors.red[200]),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(memory.title.toUpperCase(), style: GoogleFonts.courierPrime(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Text(_formatTimestamp(memory.timestamp), style: GoogleFonts.courierPrime(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(memory.content, style: GoogleFonts.courierPrime(fontSize: 12, height: 1.5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab
                Positioned(
                  top: 0,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    child: Text('REF-${memory.id}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // LAYOUT 22: Passport Stamps
  // ============================================================
  Widget _buildLayout22Passport() {
    return Container(
      color: const Color(0xFFF0E6D2), // Old paper
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final memory = _memories[index];
                  final color = [Colors.indigo, Colors.teal, Colors.brown, Colors.red[700]][index % 4];
                  return Transform.rotate(
                    angle: (index % 3 - 1) * 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: color!.withOpacity(0.7), width: 3),
                        borderRadius: BorderRadius.circular(index % 2 == 0 ? 50 : 12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(memory.icon, color: color.withOpacity(0.7)),
                          const SizedBox(height: 8),
                          Text(
                            'VISITED',
                            style: GoogleFonts.specialElite(color: color.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            _formatTimestamp(memory.timestamp),
                            style: GoogleFonts.specialElite(color: color.withOpacity(0.7), fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              memory.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.specialElite(color: color.withOpacity(0.9), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _memories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Data Models
// ============================================================

enum MemoryCategory {
  aiChat,
  notes,
  planner,
  reminder,
  bookmark,
}

class MemoryItem {
  final String id;
  final String title;
  final String content;
  final MemoryCategory category;
  final DateTime timestamp;
  final IconData icon;

  MemoryItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.timestamp,
    required this.icon,
  });
}
