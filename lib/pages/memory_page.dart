import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

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
                _selectedLayout = _selectedLayout > 1 ? _selectedLayout - 1 : 15;
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
                _selectedLayout = _selectedLayout < 15 ? _selectedLayout + 1 : 1;
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
                  _buildLayoutOption(5, 'Calendar View', Icons.calendar_month, const Color(0xFFEC4899)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('More Layouts', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  _buildLayoutOption(6, 'Kanban Board', Icons.view_kanban, const Color(0xFF06B6D4)),
                  _buildLayoutOption(7, 'Mind Map', Icons.hub, const Color(0xFFF97316)),
                  _buildLayoutOption(8, 'Card Stack', Icons.layers, const Color(0xFF14B8A6)),
                  _buildLayoutOption(9, 'Magazine', Icons.article, const Color(0xFFE11D48)),
                  _buildLayoutOption(10, 'Metro Tiles', Icons.apps, const Color(0xFF6366F1)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('AI Memory Management', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  _buildLayoutOption(11, 'Neural Network', Icons.blur_on, const Color(0xFF9333EA)),
                  _buildLayoutOption(12, 'Data Flow', Icons.account_tree, const Color(0xFF0EA5E9)),
                  _buildLayoutOption(13, 'Agent Dashboard', Icons.smart_toy, const Color(0xFFD946EF)),
                  _buildLayoutOption(14, 'Memory Graph', Icons.scatter_plot, const Color(0xFF22C55E)),
                  _buildLayoutOption(15, 'Control Center', Icons.settings_suggest, const Color(0xFFF43F5E)),

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
        return _buildLayout5Calendar();
      case 6:
        return _buildLayout6Kanban();
      case 7:
        return _buildLayout7MindMap();
      case 8:
        return _buildLayout8CardStack();
      case 9:
        return _buildLayout9Magazine();
      case 10:
        return _buildLayout10MetroTiles();
      case 11:
        return _buildLayout11NeuralNetwork();
      case 12:
        return _buildLayout12DataFlow();
      case 13:
        return _buildLayout13AgentDashboard();
      case 14:
        return _buildLayout14MemoryGraph();
      case 15:
        return _buildLayout15ControlCenter();
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
  Widget _buildLayout5Calendar() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    // Get memories for selected date
    final selectedMemories = _memories.where((m) {
      return m.timestamp.year == _selectedDate.year &&
          m.timestamp.month == _selectedDate.month &&
          m.timestamp.day == _selectedDate.day;
    }).toList();

    // Get dates that have memories
    final memoryDates = _memories.map((m) => DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day)).toSet();

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
                  color: const Color(0xFFEC4899).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month, size: 16, color: const Color(0xFFEC4899)),
                    const SizedBox(width: 6),
                    Text(
                      'Calendar',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFEC4899),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mini Calendar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16161E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF27272A)),
            ),
            child: Column(
              children: [
                // Month header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chevron_left, color: Colors.grey[400]),
                    const SizedBox(width: 16),
                    Text(
                      _getMonthName(now.month) + ' ${now.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 16),
                // Day labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                      .map((d) => SizedBox(
                            width: 32,
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Calendar grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final dayNumber = index - firstWeekday + 1;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox();
                    }
                    final date = DateTime(now.year, now.month, dayNumber);
                    final isSelected = date.day == _selectedDate.day &&
                        date.month == _selectedDate.month &&
                        date.year == _selectedDate.year;
                    final isToday = date.day == now.day &&
                        date.month == now.month &&
                        date.year == now.year;
                    final hasMemory = memoryDates.contains(date);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : isToday
                                  ? const Color(0xFF3B82F6).withOpacity(0.2)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? const Color(0xFF3B82F6)
                                        : Colors.grey[300],
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (hasMemory && !isSelected)
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEC4899),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Selected date label
          Text(
            _getFullDateLabel(_selectedDate),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          // Memories for selected date
          Expanded(
            child: selectedMemories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey[700]),
                        const SizedBox(height: 12),
                        Text(
                          'No memories for this date',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedMemories.length,
                    itemBuilder: (context, index) {
                      final memory = selectedMemories[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildCalendarMemoryCard(memory),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarMemoryCard(MemoryItem memory) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
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
                  _formatTime(memory.timestamp),
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
  // LAYOUT 6: Kanban Board
  // ============================================================
  Widget _buildLayout6Kanban() {
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
  Widget _buildLayout7MindMap() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Mind Map', Icons.hub, const Color(0xFFF97316)),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Central node
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFFF97316).withOpacity(0.4), blurRadius: 20)],
                      ),
                      child: const Icon(Icons.memory, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 20),
                    // Branch nodes
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _memories.map((memory) {
                        return Container(
                          width: 150,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16161E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getCategoryColor(memory.category).withOpacity(0.5)),
                          ),
                          child: Column(
                            children: [
                              Icon(memory.icon, color: _getCategoryColor(memory.category), size: 24),
                              const SizedBox(height: 8),
                              Text(memory.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(_getCategoryLabel(memory.category), style: TextStyle(color: _getCategoryColor(memory.category), fontSize: 10)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 8: Card Stack (Tinder-like)
  // ============================================================
  Widget _buildLayout8CardStack() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Card Stack', Icons.layers, const Color(0xFF14B8A6)),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: List.generate(min(_memories.length, 4), (index) {
                  final reverseIndex = min(_memories.length, 4) - 1 - index;
                  final memory = _memories[reverseIndex];
                  final scale = 1.0 - (index * 0.05);
                  final offset = index * 8.0;
                  return Transform.translate(
                    offset: Offset(0, offset),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 300,
                        height: 400,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_getCategoryColor(memory.category), _getCategoryColor(memory.category).withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                              child: Icon(memory.icon, color: Colors.white, size: 28),
                            ),
                            const SizedBox(height: 20),
                            Text(memory.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Expanded(child: Text(memory.content, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5))),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                  child: Text(_getCategoryLabel(memory.category), style: const TextStyle(color: Colors.white, fontSize: 11)),
                                ),
                                const Spacer(),
                                Text(_formatTimestamp(memory.timestamp), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 9: Magazine Style
  // ============================================================
  Widget _buildLayout9Magazine() {
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
  Widget _buildLayout10MetroTiles() {
    final tileColors = [
      const Color(0xFF0078D4), const Color(0xFF107C10), const Color(0xFFFFB900),
      const Color(0xFFE81123), const Color(0xFF5C2D91), const Color(0xFF00B294),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Metro Tiles', Icons.apps, const Color(0xFF6366F1)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                final color = tileColors[index % tileColors.length];
                final isLarge = index % 3 == 0;
                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(memory.icon, color: Colors.white, size: isLarge ? 32 : 28),
                      const Spacer(),
                      Text(memory.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isLarge ? 16 : 13)),
                      const SizedBox(height: 4),
                      Text(_formatTimestamp(memory.timestamp), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
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
  Widget _buildLayout11NeuralNetwork() {
    final memoryTypes = [
      {'name': 'Short-term', 'count': 12, 'color': const Color(0xFF9333EA), 'icon': Icons.flash_on},
      {'name': 'Long-term', 'count': 45, 'color': const Color(0xFF6366F1), 'icon': Icons.storage},
      {'name': 'Episodic', 'count': 28, 'color': const Color(0xFF0EA5E9), 'icon': Icons.event},
      {'name': 'Semantic', 'count': 67, 'color': const Color(0xFF22C55E), 'icon': Icons.category},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Neural Network', Icons.blur_on, const Color(0xFF9333EA)),
          const SizedBox(height: 16),
          // Memory Type Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF9333EA).withOpacity(0.15), const Color(0xFF6366F1).withOpacity(0.15)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.memory, color: Color(0xFF9333EA), size: 20),
                    const SizedBox(width: 8),
                    Text('Memory Types', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: memoryTypes.map((type) => Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: (type['color'] as Color).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(type['icon'] as IconData, color: type['color'] as Color, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text('${type['count']}', style: TextStyle(color: type['color'] as Color, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(type['name'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Neural connections visualization
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Stack(
                children: [
                  // Grid pattern background
                  CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: _NeuralGridPainter(),
                  ),
                  // Memory nodes
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _memories.length,
                    itemBuilder: (context, index) {
                      final memory = _memories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getCategoryColor(memory.category).withOpacity(0.5)),
                          boxShadow: [BoxShadow(color: _getCategoryColor(memory.category).withOpacity(0.1), blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(colors: [_getCategoryColor(memory.category), _getCategoryColor(memory.category).withOpacity(0.3)]),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(memory.icon, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(memory.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: _getCategoryColor(memory.category).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                        child: Text(_getCategoryLabel(memory.category), style: TextStyle(color: _getCategoryColor(memory.category), fontSize: 9)),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.link, size: 10, color: Colors.grey[600]),
                                      Text(' 3 connections', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                              child: const Text('Active', style: TextStyle(color: Color(0xFF22C55E), fontSize: 10)),
                            ),
                          ],
                        ),
                      );
                    },
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
  // LAYOUT 12: Data Flow (Chat to Memory Pipeline)
  // ============================================================
  Widget _buildLayout12DataFlow() {
    final pipeline = [
      {'stage': 'User Input', 'icon': Icons.chat_bubble, 'color': const Color(0xFF0EA5E9), 'desc': 'Chats & Activities'},
      {'stage': 'Processing', 'icon': Icons.settings, 'color': const Color(0xFFF59E0B), 'desc': 'AI Analysis'},
      {'stage': 'Extraction', 'icon': Icons.filter_alt, 'color': const Color(0xFF8B5CF6), 'desc': 'Key Information'},
      {'stage': 'Storage', 'icon': Icons.save, 'color': const Color(0xFF22C55E), 'desc': 'Memory Bank'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Data Flow', Icons.account_tree, const Color(0xFF0EA5E9)),
          const SizedBox(height: 16),
          // Pipeline visualization
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16161E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF27272A)),
            ),
            child: Row(
              children: List.generate(pipeline.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return Expanded(child: Container(height: 2, color: const Color(0xFF27272A)));
                }
                final stage = pipeline[index ~/ 2];
                return Column(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: (stage['color'] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: stage['color'] as Color),
                      ),
                      child: Icon(stage['icon'] as IconData, color: stage['color'] as Color, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(stage['stage'] as String, style: TextStyle(color: stage['color'] as Color, fontSize: 10, fontWeight: FontWeight.w600)),
                    Text(stage['desc'] as String, style: TextStyle(color: Colors.grey[600], fontSize: 8)),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Activity to Memory conversion
          Expanded(
            child: ListView.builder(
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: Row(
                    children: [
                      // Source (Chat/Activity)
                      Container(
                        width: 100,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withOpacity(0.1),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.chat, color: const Color(0xFF0EA5E9), size: 20),
                            const SizedBox(height: 4),
                            Text('Chat', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                            Text(_formatTimestamp(memory.timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 8)),
                          ],
                        ),
                      ),
                      // Arrow
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward, color: Colors.grey[700], size: 16),
                      ),
                      // Resulting Memory
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(memory.icon, color: _getCategoryColor(memory.category), size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(memory.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(memory.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Stored', style: TextStyle(color: Color(0xFF22C55E), fontSize: 9)),
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
  // LAYOUT 13: Multi-Agent Dashboard
  // ============================================================
  Widget _buildLayout13AgentDashboard() {
    final agents = [
      {'name': 'Planner Agent', 'status': 'Active', 'memories': 23, 'color': const Color(0xFF3B82F6), 'icon': Icons.event_note},
      {'name': 'Research Agent', 'status': 'Idle', 'memories': 45, 'color': const Color(0xFF22C55E), 'icon': Icons.search},
      {'name': 'Memory Agent', 'status': 'Active', 'memories': 89, 'color': const Color(0xFFD946EF), 'icon': Icons.psychology},
      {'name': 'Task Agent', 'status': 'Processing', 'memories': 12, 'color': const Color(0xFFF59E0B), 'icon': Icons.task_alt},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Agent Dashboard', Icons.smart_toy, const Color(0xFFD946EF)),
          const SizedBox(height: 16),
          // Agents Grid
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: agents.length,
              itemBuilder: (context, index) {
                final agent = agents[index];
                final isActive = agent['status'] == 'Active';
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [(agent['color'] as Color).withOpacity(0.15), const Color(0xFF16161E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: (agent['color'] as Color).withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: (agent['color'] as Color).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: Icon(agent['icon'] as IconData, color: agent['color'] as Color, size: 18),
                          ),
                          const Spacer(),
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF22C55E) : Colors.grey,
                              shape: BoxShape.circle,
                              boxShadow: isActive ? [BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.5), blurRadius: 6)] : null,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(agent['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${agent['memories']} memories', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                      Text(agent['status'] as String, style: TextStyle(color: agent['color'] as Color, fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Shared Memory Pool
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.share, color: Color(0xFFD946EF), size: 18),
                        const SizedBox(width: 8),
                        const Text('Shared Memory Pool', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFD946EF).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text('${_memories.length} items', style: const TextStyle(color: Color(0xFFD946EF), fontSize: 10)),
                        ),
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
                        final agentIndex = index % agents.length;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(color: (agents[agentIndex]['color'] as Color).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                child: Icon(agents[agentIndex]['icon'] as IconData, color: agents[agentIndex]['color'] as Color, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(memory.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                    Text('From ${agents[agentIndex]['name']}', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                  ],
                                ),
                              ),
                              Icon(Icons.sync, color: Colors.grey[600], size: 14),
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
  // LAYOUT 14: Memory Graph (Connections & Categories)
  // ============================================================
  Widget _buildLayout14MemoryGraph() {
    final categories = MemoryCategory.values;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayoutHeader('Memory Graph', Icons.scatter_plot, const Color(0xFF22C55E)),
          const SizedBox(height: 16),
          // Category filters
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final count = _memories.where((m) => m.category == cat).length;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(cat).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getCategoryColor(cat).withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: _getCategoryColor(cat), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(_getCategoryLabel(cat), style: TextStyle(color: _getCategoryColor(cat), fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      Text('($count)', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Graph visualization
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Stack(
                children: [
                  // Connection lines (simulated)
                  CustomPaint(size: const Size(double.infinity, double.infinity), painter: _ConnectionsPainter()),
                  // Memory nodes as floating bubbles
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _memories.map((memory) {
                        return Container(
                          width: 110,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_getCategoryColor(memory.category).withOpacity(0.2), const Color(0xFF1E1E2E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getCategoryColor(memory.category).withOpacity(0.5)),
                            boxShadow: [BoxShadow(color: _getCategoryColor(memory.category).withOpacity(0.2), blurRadius: 8)],
                          ),
                          child: Column(
                            children: [
                              Icon(memory.icon, color: _getCategoryColor(memory.category), size: 22),
                              const SizedBox(height: 6),
                              Text(memory.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.link, size: 10, color: Colors.grey[600]),
                                  Text(' ${(memory.id.hashCode % 5) + 1}', style: TextStyle(color: Colors.grey[600], fontSize: 9)),
                                ],
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
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT 15: Control Center (System Memory Management)
  // ============================================================
  Widget _buildLayout15ControlCenter() {
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
}

// Custom painters for neural network visualization
class _NeuralGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF27272A).withOpacity(0.3)
      ..strokeWidth = 0.5;
    const spacing = 30.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConnectionsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E).withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final points = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.7),
    ];
    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        canvas.drawLine(points[i], points[j], paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
