import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final List<Map<String, dynamic>> subjects = [
    {
      'title': 'Data Structures',
      'percentage': 85.0,
      'icon': Icons.account_tree,
      'totalClasses': 40,
      'attended': 34,
      'professor': 'Dr. Sarah Chen',
      'schedule': 'Mon, Wed, Fri • 10:00 AM',
      'room': 'Room 301',
    },
    {
      'title': 'Engineering Physics',
      'percentage': 68.5,
      'icon': Icons.science,
      'totalClasses': 35,
      'attended': 24,
      'professor': 'Prof. James Miller',
      'schedule': 'Tue, Thu • 2:00 PM',
      'room': 'Lab 102',
    },
    {
      'title': 'Calculus III',
      'percentage': 45.0,
      'icon': Icons.calculate,
      'totalClasses': 40,
      'attended': 18,
      'professor': 'Dr. Emily Watson',
      'schedule': 'Mon, Wed • 8:00 AM',
      'room': 'Room 205',
    },
    {
      'title': 'Python Programming',
      'percentage': 92.0,
      'icon': Icons.code,
      'totalClasses': 25,
      'attended': 23,
      'professor': 'Prof. Alex Kumar',
      'schedule': 'Wed, Fri • 11:00 AM',
      'room': 'Computer Lab 3',
    },
    {
      'title': 'Java Fundamentals',
      'percentage': 78.0,
      'icon': Icons.coffee,
      'totalClasses': 32,
      'attended': 25,
      'professor': 'Dr. Michael Brown',
      'schedule': 'Tue, Thu • 9:00 AM',
      'room': 'Room 401',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildOverallCard(),
              const SizedBox(height: 16),
              _buildSubjectList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OVERALL ATTENDANCE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '82.04%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            _buildCircularProgress(0.82),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(double value) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 6,
              backgroundColor: const Color(0xFF27272A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF3B82F6),
              ),
            ),
          ),
          const Center(
            child: Icon(Icons.auto_graph, color: Color(0xFF3B82F6), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: List.generate(subjects.length, (index) {
          final subject = subjects[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < subjects.length - 1 ? 16 : 0,
            ),
            child: GestureDetector(
              onTap: () => _showSubjectDetails(subject),
              child: _buildSubjectCard(
                title: subject['title'],
                percentage: subject['percentage'],
                icon: subject['icon'],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showSubjectDetails(Map<String, dynamic> subject) {
    final percentage = subject['percentage'] as double;
    Color statusColor;
    String statusText;
    if (percentage >= 75) {
      statusColor = const Color(0xFF3B82F6);
      statusText = 'Good Standing';
    } else if (percentage >= 60) {
      statusColor = const Color(0xFF8B5CF6);
      statusText = 'Needs Improvement';
    } else {
      statusColor = const Color(0xFFF43F5E);
      statusText = 'Critical - Action Required';
    }

    final classesNeeded = _calculateClassesNeeded(
      subject['attended'],
      subject['totalClasses'],
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF16161E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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
            const SizedBox(height: 24),
            // Header with icon and title
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(subject['icon'], color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject['professor'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Attendance stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Attended',
                    '${subject['attended']}',
                    Icons.check_circle_outline,
                    const Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Missed',
                    '${subject['totalClasses'] - subject['attended']}',
                    Icons.cancel_outlined,
                    const Color(0xFFF43F5E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    '${subject['totalClasses']}',
                    Icons.calendar_today,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Percentage bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance Rate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: const Color(0xFF27272A),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  int _calculateClassesNeeded(int attended, int total) {
    // Calculate how many more classes needed to reach 75%
    // (attended + x) / (total + x) >= 0.75
    // attended + x >= 0.75 * total + 0.75 * x
    // 0.25 * x >= 0.75 * total - attended
    // x >= (0.75 * total - attended) / 0.25
    final currentPercentage = (attended / total) * 100;
    if (currentPercentage >= 75) return 0;

    int classesNeeded = 0;
    int futureAttended = attended;
    int futureTotal = total;
    while ((futureAttended / futureTotal) * 100 < 75 && classesNeeded < 100) {
      futureAttended++;
      futureTotal++;
      classesNeeded++;
    }
    return classesNeeded;
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildSubjectCard({
    required String title,
    required double percentage,
    required IconData icon,
  }) {
    Color statusColor;
    if (percentage >= 75) {
      statusColor = const Color(0xFF3B82F6); // Blue - good
    } else if (percentage >= 60) {
      statusColor = const Color(0xFF8B5CF6); // Purple - warning
    } else {
      statusColor = const Color(0xFFF43F5E); // Red - critical
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        children: [
          // Icon container
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
          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Circular percentage
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 4,
                    backgroundColor: const Color(0xFF27272A),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Center(
                  child: Text(
                    '${percentage.toInt()}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
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
}
