import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int selectedDay = 9; // Currently selected day
  int currentMonth = 1; // January (1-12)
  int currentYear = 2026;

  final List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> weekDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  // Monthly events: month (1-12) -> list of events
  final Map<int, List<Map<String, dynamic>>> monthlyEvents = {
    1: [
      // January
      {
        'title': 'New Year Holiday',
        'date': 'Jan 1',
        'day': 1,
        'type': 'holiday',
        'icon': Icons.celebration,
      },
      {
        'title': 'Semester Begins',
        'date': 'Jan 6',
        'day': 6,
        'type': 'event',
        'icon': Icons.school,
      },
      {
        'title': 'Republic Day',
        'date': 'Jan 26',
        'day': 26,
        'type': 'holiday',
        'icon': Icons.flag,
      },
      {
        'title': 'Assignment Deadline',
        'date': 'Jan 30',
        'day': 30,
        'type': 'deadline',
        'icon': Icons.assignment_late,
      },
    ],
    2: [
      // February
      {
        'title': 'Mid-Term Exams Begin',
        'date': 'Feb 10 - Feb 20',
        'day': 10,
        'type': 'exam',
        'icon': Icons.edit_note,
      },
      {
        'title': 'Valentine\'s Day Event',
        'date': 'Feb 14',
        'day': 14,
        'type': 'event',
        'icon': Icons.favorite,
      },
    ],
    3: [
      // March
      {
        'title': 'Holi Holiday',
        'date': 'Mar 14',
        'day': 14,
        'type': 'holiday',
        'icon': Icons.celebration,
      },
      {
        'title': 'Project Submission',
        'date': 'Mar 25',
        'day': 25,
        'type': 'deadline',
        'icon': Icons.folder_open,
      },
    ],
    4: [
      // April
      {
        'title': 'Good Friday',
        'date': 'Apr 18',
        'day': 18,
        'type': 'holiday',
        'icon': Icons.church,
      },
      {
        'title': 'End Semester Exams',
        'date': 'Apr 20 - Apr 30',
        'day': 20,
        'type': 'exam',
        'icon': Icons.edit_note,
      },
    ],
    5: [
      // May
      {
        'title': 'Summer Break Begins',
        'date': 'May 1',
        'day': 1,
        'type': 'holiday',
        'icon': Icons.wb_sunny,
      },
    ],
    6: [
      // June
      {
        'title': 'Summer Break',
        'date': 'Full Month',
        'day': 1,
        'type': 'holiday',
        'icon': Icons.beach_access,
      },
    ],
    7: [
      // July
      {
        'title': 'New Academic Year',
        'date': 'Jul 1',
        'day': 1,
        'type': 'event',
        'icon': Icons.school,
      },
      {
        'title': 'Orientation Week',
        'date': 'Jul 1 - Jul 7',
        'day': 1,
        'type': 'event',
        'icon': Icons.groups,
      },
    ],
    8: [
      // August
      {
        'title': 'Independence Day',
        'date': 'Aug 15',
        'day': 15,
        'type': 'holiday',
        'icon': Icons.flag,
      },
      {
        'title': 'Quiz Week',
        'date': 'Aug 20 - Aug 25',
        'day': 20,
        'type': 'exam',
        'icon': Icons.quiz,
      },
    ],
    9: [
      // September
      {
        'title': 'Teachers Day',
        'date': 'Sep 5',
        'day': 5,
        'type': 'event',
        'icon': Icons.person,
      },
      {
        'title': 'Mid-Semester Break',
        'date': 'Sep 15 - Sep 20',
        'day': 15,
        'type': 'holiday',
        'icon': Icons.weekend,
      },
    ],
    10: [
      // October
      {
        'title': 'Gandhi Jayanti',
        'date': 'Oct 2',
        'day': 2,
        'type': 'holiday',
        'icon': Icons.emoji_people,
      },
      {
        'title': 'Dussehra',
        'date': 'Oct 12',
        'day': 12,
        'type': 'holiday',
        'icon': Icons.celebration,
      },
      {
        'title': 'Diwali Break',
        'date': 'Oct 31 - Nov 3',
        'day': 31,
        'type': 'holiday',
        'icon': Icons.celebration,
      },
    ],
    11: [
      // November
      {
        'title': 'Diwali Break Continues',
        'date': 'Nov 1 - Nov 3',
        'day': 1,
        'type': 'holiday',
        'icon': Icons.celebration,
      },
      {
        'title': 'Mid-Term Exams',
        'date': 'Nov 15 - Nov 22',
        'day': 15,
        'type': 'exam',
        'icon': Icons.edit_note,
      },
      {
        'title': 'Project Submission',
        'date': 'Nov 25',
        'day': 25,
        'type': 'deadline',
        'icon': Icons.folder_open,
      },
    ],
    12: [
      // December
      {
        'title': 'End Semester Exams',
        'date': 'Dec 1 - Dec 15',
        'day': 1,
        'type': 'exam',
        'icon': Icons.edit_note,
      },
      {
        'title': 'Christmas Holiday',
        'date': 'Dec 25',
        'day': 25,
        'type': 'holiday',
        'icon': Icons.ac_unit,
      },
      {
        'title': 'Winter Break',
        'date': 'Dec 26 - Dec 31',
        'day': 26,
        'type': 'holiday',
        'icon': Icons.weekend,
      },
    ],
  };

  void _goToPreviousMonth() {
    setState(() {
      if (currentMonth == 1) {
        currentMonth = 12;
        currentYear--;
      } else {
        currentMonth--;
      }
      selectedDay = 1; // Reset selected day
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (currentMonth == 12) {
        currentMonth = 1;
        currentYear++;
      } else {
        currentMonth++;
      }
      selectedDay = 1; // Reset selected day
    });
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstDayOfWeek(int year, int month) {
    return DateTime(year, month, 1).weekday % 7; // 0 = Sunday
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildMonthHeader(),
              const SizedBox(height: 16),
              _buildCalendarGrid(),
              const SizedBox(height: 24),
              _buildMonthlyOverviewSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goToPreviousMonth,
            child: _buildNavButton(Icons.chevron_left),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _goToNextMonth,
            child: _buildNavButton(Icons.chevron_right),
          ),
          const SizedBox(width: 16),
          Text(
            '${monthNames[currentMonth - 1]} $currentYear',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Icon(icon, color: Colors.grey[500], size: 20),
    );
  }

  Widget _buildCalendarGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Column(
          children: [
            // Weekday headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((day) {
                return SizedBox(
                  width: 36,
                  child: Text(
                    day.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 0.5,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Calendar days
            _buildCalendarDays(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDays() {
    final daysInMonth = _getDaysInMonth(currentYear, currentMonth);
    final firstDayOfWeek = _getFirstDayOfWeek(currentYear, currentMonth);
    final daysInPrevMonth = _getDaysInMonth(
      currentMonth == 1 ? currentYear - 1 : currentYear,
      currentMonth == 1 ? 12 : currentMonth - 1,
    );

    List<Widget> rows = [];
    List<int> weekDays = [];
    List<bool> isCurrentMonth = [];

    // Add previous month days
    for (int i = firstDayOfWeek - 1; i >= 0; i--) {
      weekDays.add(daysInPrevMonth - i);
      isCurrentMonth.add(false);
    }

    // Add current month days
    for (int day = 1; day <= daysInMonth; day++) {
      weekDays.add(day);
      isCurrentMonth.add(true);

      if (weekDays.length == 7) {
        rows.add(_buildWeekRow(List.from(weekDays), List.from(isCurrentMonth)));
        rows.add(const SizedBox(height: 8));
        weekDays.clear();
        isCurrentMonth.clear();
      }
    }

    // Add next month days to complete the last row
    if (weekDays.isNotEmpty) {
      int nextDay = 1;
      while (weekDays.length < 7) {
        weekDays.add(nextDay++);
        isCurrentMonth.add(false);
      }
      rows.add(_buildWeekRow(List.from(weekDays), List.from(isCurrentMonth)));
    }

    return Column(children: rows);
  }

  Widget _buildWeekRow(List<int> days, List<bool> isCurrentMonth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final day = days[index];
        final isCurrent = isCurrentMonth[index];
        final isSelected = isCurrent && day == selectedDay;

        return GestureDetector(
          onTap: isCurrent ? () => setState(() => selectedDay = day) : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: !isCurrent
                      ? Colors.grey[800]
                      : isSelected
                      ? Colors.white
                      : Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMonthlyOverviewSection() {
    final events = monthlyEvents[currentMonth] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${monthNames[currentMonth - 1]} Overview',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              Text(
                '${events.length} EVENTS',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  letterSpacing: 1,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 40,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No events this month',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ...events.map((event) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEventCard(
                  title: event['title'],
                  date: event['date'],
                  type: event['type'],
                  icon: event['icon'],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required String type,
    required IconData icon,
  }) {
    Color accentColor;
    switch (type) {
      case 'holiday':
        accentColor = const Color(0xFFF43F5E); // Pink/Red
        break;
      case 'exam':
        accentColor = const Color(0xFFF59E0B); // Orange
        break;
      case 'deadline':
        accentColor = const Color(0xFFEF4444); // Red
        break;
      default:
        accentColor = const Color(0xFF3B82F6); // Blue
    }

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
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(icon, color: accentColor, size: 20),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
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
}
