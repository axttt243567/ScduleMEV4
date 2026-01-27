import 'package:flutter/material.dart';
import '../../settings/screens/settings_page.dart';
import '../../calendar/screens/calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedDay = 0; // Will be set to current day in initState
  int selectedHeatmapFilter = 0; // 0 = All, 1 = This Month, 2 = Last 30 Days
  final List<String> heatmapFilters = ['All', 'This Month', 'Last 30 Days'];

  // ScrollController for day selector
  final ScrollController _dayScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Find and select current day
    _selectCurrentDay();
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  void _selectCurrentDay() {
    final now = DateTime.now();
    final currentDate = now.day.toString();

    // Find matching date in days list
    int currentDayIndex = -1;
    for (int i = 0; i < days.length; i++) {
      if (days[i]['date'] == currentDate) {
        currentDayIndex = i;
        break;
      }
    }

    // If found, select it and scroll to it after build
    if (currentDayIndex != -1) {
      setState(() {
        selectedDay = currentDayIndex;
      });

      // Scroll to current day with animation after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDay(currentDayIndex);
      });
    } else {
      // Default to first day if current date not found
      setState(() {
        selectedDay = 0;
      });
    }
  }

  void _scrollToSelectedDay(int index) {
    // Calculate approximate scroll position (each day card is ~60px wide including padding)
    const double itemWidth = 60.0;
    final double scrollPosition = (index * itemWidth) - 100; // Center it a bit

    if (_dayScrollController.hasClients) {
      _dayScrollController.animateTo(
        scrollPosition.clamp(0, _dayScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // Holidays - indices of holiday dates (sample holidays spread across the year)
  final Set<int> holidays = {
    9,
    25,
    59,
    85,
    95,
    140,
    175,
    210,
    245,
    280,
    315,
    350,
  };

  // Heatmap data - 365 days for full year (7 rows × 53 columns, last column partial)
  // 0 to 4 intensity levels
  final List<int> heatmapData = [
    // Week 1-10 (days 1-70)
    4, 3, 4, 2, 4, 4, 3, 4, 4, 0, 4, 4, 3, 2, 4, 1, 4, 4, 4, 3,
    4, 4, 3, 4, 0, 4, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 2, 4, 3, 4,
    3, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    // Week 11-20 (days 71-140)
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 2, 4, 1, 4, 4, 4, 3,
    4, 4, 3, 4, 0, 4, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 2, 4, 3, 4,
    3, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    // Week 21-30 (days 141-210)
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 2, 4, 1, 4, 4, 4, 3,
    4, 4, 3, 4, 0, 4, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 2, 4, 3, 4,
    3, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    // Week 31-40 (days 211-280)
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 2, 4, 1, 4, 4, 4, 3,
    4, 4, 3, 4, 0, 4, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 2, 4, 3, 4,
    3, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    // Week 41-52 + Day 365 (days 281-365)
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 2, 4, 1, 4, 4, 4, 3,
    4, 4, 3, 4, 0, 4, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 2, 4, 3, 4,
    3, 4, 4, 2, 4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, // 85 days = 365 total
  ];

  final List<Map<String, dynamic>> days = [
    {'day': 'Mon', 'date': '12'},
    {'day': 'Tue', 'date': '13'},
    {'day': 'Wed', 'date': '14'},
    {'day': 'Thu', 'date': '15'},
    {'day': 'Fri', 'date': '16'},
    {'day': 'Sat', 'date': '17'},
    {'day': 'Sun', 'date': '18'},
    {'day': 'Mon', 'date': '19'},
    {'day': 'Tue', 'date': '20'},
    {'day': 'Wed', 'date': '21'},
    {'day': 'Thu', 'date': '22'},
    {'day': 'Fri', 'date': '23'},
    {'day': 'Sat', 'date': '24'},
    {'day': 'Sun', 'date': '25'},
  ];

  // Demo schedule data for different days
  final Map<int, List<Map<String, dynamic>>> scheduleData = {
    0: [
      // Monday 12
      {
        'time': '08:00',
        'title': 'Data Structures',
        'timeRange': '08:00 - 09:30',
        'location': 'ROOM_A-101',
        'icon': Icons.code,
        'isActive': false,
        'isBreak': false,
      },
      {
        'time': '10:00',
        'title': 'Linear Algebra',
        'timeRange': '10:00 - 11:30',
        'location': 'ROOM_B-205',
        'icon': Icons.calculate,
        'isActive': true,
        'isBreak': false,
      },
      {
        'time': '12:00',
        'title': 'SYSTEM IDLE',
        'timeRange': '12:00 - 13:00',
        'location': 'Cafeteria',
        'icon': Icons.coffee,
        'isActive': false,
        'isBreak': true,
      },
      {
        'time': '14:00',
        'title': 'Computer Networks',
        'timeRange': '14:00 - 15:30',
        'location': 'LAB_C-302',
        'icon': Icons.wifi,
        'isActive': false,
        'isBreak': false,
      },
    ],
    1: [
      // Tuesday 13
      {
        'time': '09:00',
        'title': 'Machine Learning',
        'timeRange': '09:00 - 10:30',
        'location': 'AI_LAB_01',
        'icon': Icons.psychology,
        'isActive': false,
        'isBreak': false,
      },
      {
        'time': '11:00',
        'title': 'Statistics',
        'timeRange': '11:00 - 12:30',
        'location': 'ROOM_D-110',
        'icon': Icons.bar_chart,
        'isActive': true,
        'isBreak': false,
      },
      {
        'time': '13:00',
        'title': 'SYSTEM IDLE',
        'timeRange': '13:00 - 14:00',
        'location': 'Refueling Zone',
        'icon': Icons.coffee,
        'isActive': false,
        'isBreak': true,
      },
      {
        'time': '15:00',
        'title': 'Web Development',
        'timeRange': '15:00 - 16:30',
        'location': 'COMP_LAB_02',
        'icon': Icons.web,
        'isActive': false,
        'isBreak': false,
      },
    ],
    2: [
      // Wednesday 14 (Current default)
      {
        'time': '09:00',
        'title': 'Advanced Calculus',
        'timeRange': '09:00 - 10:30',
        'location': 'ROOM_B-304',
        'icon': Icons.functions,
        'isActive': false,
        'isBreak': false,
      },
      {
        'time': '11:00',
        'title': 'Quantum Physics',
        'timeRange': '11:00 - 12:30',
        'location': 'LAB ALPHA // WING E',
        'icon': Icons.science,
        'isActive': true,
        'isBreak': false,
        'professor': 'DR. VALENTINE',
      },
      {
        'time': '13:00',
        'title': 'SYSTEM IDLE',
        'timeRange': '13:00 - 14:00',
        'location': 'Refueling Zone',
        'icon': Icons.coffee,
        'isActive': false,
        'isBreak': true,
      },
      {
        'time': '14:30',
        'title': 'Systems Architecture',
        'timeRange': '14:30 - 16:00',
        'location': 'CORE HALL B',
        'icon': Icons.business,
        'isActive': false,
        'isBreak': false,
      },
      {
        'time': '16:30',
        'title': 'UI/UX Interface',
        'timeRange': '16:30 - 18:00',
        'location': 'DESIGN_STUDIO_01',
        'icon': Icons.palette,
        'isActive': false,
        'isBreak': false,
      },
    ],
    3: [
      // Thursday 15
      {
        'time': '08:30',
        'title': 'Database Systems',
        'timeRange': '08:30 - 10:00',
        'location': 'ROOM_E-201',
        'icon': Icons.storage,
        'isActive': false,
        'isBreak': false,
      },
      {
        'time': '10:30',
        'title': 'Cloud Computing',
        'timeRange': '10:30 - 12:00',
        'location': 'SERVER_LAB',
        'icon': Icons.cloud,
        'isActive': true,
        'isBreak': false,
      },
      {
        'time': '12:30',
        'title': 'SYSTEM IDLE',
        'timeRange': '12:30 - 13:30',
        'location': 'Food Court',
        'icon': Icons.coffee,
        'isActive': false,
        'isBreak': true,
      },
      {
        'time': '14:00',
        'title': 'Cybersecurity',
        'timeRange': '14:00 - 15:30',
        'location': 'SECURE_LAB_01',
        'icon': Icons.security,
        'isActive': false,
        'isBreak': false,
      },
    ],
    4: [
      // Friday 16
      {
        'time': '09:00',
        'title': 'Software Engineering',
        'timeRange': '09:00 - 10:30',
        'location': 'ROOM_F-105',
        'icon': Icons.engineering,
        'isActive': false,
        'isBreak': false,
      },
      {
        'time': '11:00',
        'title': 'Project Workshop',
        'timeRange': '11:00 - 13:00',
        'location': 'WORKSHOP_HALL',
        'icon': Icons.build,
        'isActive': true,
        'isBreak': false,
      },
      {
        'time': '13:30',
        'title': 'SYSTEM IDLE',
        'timeRange': '13:30 - 14:30',
        'location': 'Refueling Zone',
        'icon': Icons.coffee,
        'isActive': false,
        'isBreak': true,
      },
    ],
    5: [
      // Saturday 17 (Weekend - light schedule)
      {
        'time': '10:00',
        'title': 'Study Group',
        'timeRange': '10:00 - 12:00',
        'location': 'LIBRARY_ZONE_A',
        'icon': Icons.groups,
        'isActive': true,
        'isBreak': false,
      },
    ],
    6: [
      // Sunday 18 (Weekend - no classes)
    ],
    7: [
      // Monday 19
      {
        'time': '08:00',
        'title': 'Data Structures',
        'timeRange': '08:00 - 09:30',
        'location': 'ROOM_A-101',
        'icon': Icons.code,
        'isActive': false,
        'isBreak': false,
      },
      {
        'time': '10:00',
        'title': 'Linear Algebra',
        'timeRange': '10:00 - 11:30',
        'location': 'ROOM_B-205',
        'icon': Icons.calculate,
        'isActive': true,
        'isBreak': false,
      },
      {
        'time': '12:00',
        'title': 'SYSTEM IDLE',
        'timeRange': '12:00 - 13:00',
        'location': 'Cafeteria',
        'icon': Icons.coffee,
        'isActive': false,
        'isBreak': true,
      },
      {
        'time': '14:00',
        'title': 'Computer Networks',
        'timeRange': '14:00 - 15:30',
        'location': 'LAB_C-302',
        'icon': Icons.wifi,
        'isActive': false,
        'isBreak': false,
      },
    ],
    8: [
      // Tuesday 20
      {
        'time': '09:00',
        'title': 'Machine Learning',
        'timeRange': '09:00 - 10:30',
        'location': 'AI_LAB_01',
        'icon': Icons.psychology,
        'isActive': true,
        'isBreak': false,
      },
      {
        'time': '11:00',
        'title': 'Statistics',
        'timeRange': '11:00 - 12:30',
        'location': 'ROOM_D-110',
        'icon': Icons.bar_chart,
        'isActive': false,
        'isBreak': false,
      },
    ],
    9: [
      // Wednesday 21
      {
        'time': '09:00',
        'title': 'Algorithms',
        'timeRange': '09:00 - 10:30',
        'location': 'ROOM_G-201',
        'icon': Icons.account_tree,
        'isActive': false,
        'isBreak': false,
      },
      {
        'time': '11:00',
        'title': 'Operating Systems',
        'timeRange': '11:00 - 12:30',
        'location': 'SYS_LAB_02',
        'icon': Icons.computer,
        'isActive': true,
        'isBreak': false,
      },
      {
        'time': '13:00',
        'title': 'SYSTEM IDLE',
        'timeRange': '13:00 - 14:00',
        'location': 'Refueling Zone',
        'icon': Icons.coffee,
        'isActive': false,
        'isBreak': true,
      },
      {
        'time': '14:30',
        'title': 'Compiler Design',
        'timeRange': '14:30 - 16:00',
        'location': 'ROOM_H-301',
        'icon': Icons.terminal,
        'isActive': false,
        'isBreak': false,
      },
    ],
    10: [
      // Thursday 22
      {
        'time': '08:30',
        'title': 'Discrete Math',
        'timeRange': '08:30 - 10:00',
        'location': 'ROOM_I-102',
        'icon': Icons.grid_on,
        'isActive': false,
        'isBreak': false,
      },
      {
        'time': '10:30',
        'title': 'Digital Logic',
        'timeRange': '10:30 - 12:00',
        'location': 'ELECTRONICS_LAB',
        'icon': Icons.memory,
        'isActive': true,
        'isBreak': false,
      },
    ],
    11: [
      // Friday 23
      {
        'time': '09:00',
        'title': 'Presentation Day',
        'timeRange': '09:00 - 12:00',
        'location': 'AUDITORIUM',
        'icon': Icons.slideshow,
        'isActive': true,
        'isBreak': false,
      },
      {
        'time': '12:30',
        'title': 'SYSTEM IDLE',
        'timeRange': '12:30 - 13:30',
        'location': 'Celebration Zone',
        'icon': Icons.coffee,
        'isActive': false,
        'isBreak': true,
      },
    ],
    12: [
      // Saturday 24
      {
        'time': '10:00',
        'title': 'Hackathon Prep',
        'timeRange': '10:00 - 14:00',
        'location': 'INNOVATION_HUB',
        'icon': Icons.rocket_launch,
        'isActive': true,
        'isBreak': false,
      },
    ],
    13: [
      // Sunday 25 (Weekend - no classes)
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header
            _buildHeader(),
            // Day Selector
            _buildDaySelector(),
            const SizedBox(height: 24),
            // Main Content
            Expanded(child: _buildMainContent()),
          ],
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
        color: isHighlighted ? const Color(0xFF3B82F6) : Colors.grey[500],
        size: 20,
      ),
    );
  }

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      controller: _dayScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(days.length, (index) {
          final isSelected = index == selectedDay;
          return Padding(
            padding: EdgeInsets.only(right: index < days.length - 1 ? 16 : 0),
            child: GestureDetector(
              onTap: () {
                if (selectedDay == index) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarPage(),
                    ),
                  );
                } else {
                  setState(() => selectedDay = index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 12 : 16,
                  vertical: isSelected ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? 1.0 : 0.4,
                  child: Column(
                    children: [
                      Text(
                        days[index]['day']!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days[index]['date']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _onRefresh() async {
    // Simulate a network request delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Re-select current day and scroll to it
    _selectCurrentDay();

    // You can add additional refresh logic here
    // For example: fetch new schedule data from API
    setState(() {
      // Trigger rebuild with fresh data
    });
  }

  Widget _buildMainContent() {
    final selectedDayData = days[selectedDay];
    final dayName = selectedDayData['day'];
    final date = selectedDayData['date'];

    // Check if selected day is today
    final now = DateTime.now();
    final isToday = days[selectedDay]['date'] == now.day.toString();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF3B82F6),
      backgroundColor: const Color(0xFF16161E),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Text(
              isToday ? "Today's Schedule" : "$dayName $date Schedule",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Timeline
            _buildTimeline(),
            // Cycle Complete
            const SizedBox(height: 48),
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Column(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CYCLE_COMPLETE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        letterSpacing: 3,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Heatmap Section
            _buildHeatmapSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final schedule = scheduleData[selectedDay] ?? [];

    if (schedule.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(Icons.event_available, size: 48, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                'No classes scheduled',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enjoy your day off!',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Timeline Line
        Positioned(
          left: 59,
          top: 0,
          bottom: 0,
          child: Container(width: 1, color: const Color(0xFF27272A)),
        ),
        // Timeline Items
        Column(
          children: schedule.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == schedule.length - 1;

            Widget timelineWidget;

            if (item['isBreak'] == true) {
              timelineWidget = _buildBreakItem(
                time: item['time'],
                timeRange: item['timeRange'],
                location: item['location'],
              );
            } else if (item['isActive'] == true) {
              timelineWidget = _buildActiveTimelineItem(
                time: item['time'],
                title: item['title'],
                timeRange: item['timeRange'],
                location: item['location'],
                icon: item['icon'] ?? Icons.school,
                professor: item['professor'],
              );
            } else {
              timelineWidget = _buildTimelineItem(
                time: item['time'],
                title: item['title'],
                isActive: false,
                timeRange: item['timeRange'],
                location: item['location'],
                icon: item['icon'] ?? Icons.school,
              );
            }

            return Column(
              children: [
                timelineWidget,
                if (!isLast) const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required bool isActive,
    required String timeRange,
    required String location,
    bool hasVerified = false,
    bool hasWaitState = false,
    IconData icon = Icons.room,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time
        SizedBox(
          width: 56,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, right: 16),
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
        // Dot
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF3F3F46),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF27272A)),
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF27272A)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27272A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: Colors.grey[500], size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$timeRange • $location',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTimelineItem({
    required String time,
    required String title,
    required String timeRange,
    required String location,
    IconData icon = Icons.school,
    String? professor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time
        SizedBox(
          width: 56,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, right: 16),
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ),
        // Dot with ring
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 31),
        // Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16161E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.bolt, color: const Color(0xFF3B82F6), size: 14),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'PROCESS_ACTIVE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    letterSpacing: 2,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.schedule, timeRange, isActive: true),
                const SizedBox(height: 8),
                _buildInfoRow(icon, location, isActive: true),
                if (professor != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person, professor, isActive: true),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Mark attendance logic
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text(
                          'MARK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to attendance page
                        },
                        icon: Icon(
                          Icons.fact_check_outlined,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        label: Text(
                          'VIEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.grey[400],
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF27272A)),
                          backgroundColor: const Color(0xFF27272A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakItem({
    String time = '13:00',
    String timeRange = '13:00 - 14:00',
    String location = 'Refueling Zone',
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time
        SizedBox(
          width: 56,
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
        // Dot
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF3F3F46),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF27272A)),
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF27272A),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27272A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.coffee, color: Colors.grey[500], size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYSTEM IDLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$timeRange • $location',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isActive = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: isActive ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: isActive ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Stats
        Row(
          children: [
            Expanded(
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
                    Text(
                      'CONSISTENCY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '94.2%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.94,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                    Text(
                      'TOTAL CLASSES',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '128',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '12 Missed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Heatmap Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF16161E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Frequency',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yearly heatmap',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Simple Color Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'LESS',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 6),
                      ...List.generate(5, (index) {
                        return Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: _getHeatColor(index),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                      Text(
                        'MORE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  _buildHolidayLegend(),
                ],
              ),
              const SizedBox(height: 16),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: heatmapFilters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final filter = entry.value;
                    final isSelected = selectedHeatmapFilter == index;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < heatmapFilters.length - 1 ? 8 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedHeatmapFilter = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF0A0A0C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF27272A),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Heatmap Grid with Month Labels - Horizontally Scrollable together
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heatmap Grid
                    Row(
                      children: List.generate((heatmapData.length / 7).ceil(), (
                        colIndex,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Column(
                            children: List.generate(7, (rowIndex) {
                              final index = colIndex * 7 + rowIndex;
                              if (index >= heatmapData.length) {
                                return const SizedBox(width: 16, height: 16);
                              }
                              final value = heatmapData[index];
                              final isToday = index == 85;
                              final isHoliday = holidays.contains(index);

                              return Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: isHoliday
                                      ? const Color(0xFF27272A)
                                      : (value == -1
                                            ? const Color(
                                                0xFF27272A,
                                              ).withOpacity(0.3)
                                            : _getHeatColor(value)),
                                  borderRadius: BorderRadius.circular(3),
                                  border: isToday
                                      ? Border.all(
                                          color: const Color(0xFF3B82F6),
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: isHoliday
                                    ? Center(
                                        child: Icon(
                                          Icons.close,
                                          size: 8,
                                          color: Colors.grey[600],
                                        ),
                                      )
                                    : null,
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    // Month Labels
                    Row(
                      children:
                          [
                                'JAN',
                                'FEB',
                                'MAR',
                                'APR',
                                'MAY',
                                'JUN',
                                'JUL',
                                'AUG',
                                'SEP',
                                'OCT',
                                'NOV',
                                'DEC',
                              ]
                              .map(
                                (month) => Padding(
                                  padding: const EdgeInsets.only(right: 68),
                                  child: Text(
                                    month,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Streak Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Color(0xFFFCD34D),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ACTIVE STREAK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '15 Day Streak!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep it up! Log tomorrow to hit 16.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHolidayLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF27272A),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Icon(Icons.close, size: 6, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Holiday',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Color _getHeatColor(int level) {
    switch (level) {
      case 0:
        return const Color(0xFF27272A);
      case 1:
        return const Color(0xFF1E3A5F);
      case 2:
        return const Color(0xFF2563EB).withOpacity(0.5);
      case 3:
        return const Color(0xFF3B82F6).withOpacity(0.75);
      case 4:
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF27272A);
    }
  }
}
