import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/schedule_model.dart';
// Note: Intentionally avoiding external calendar packages to keep it lightweight custom implementation

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  final TextEditingController _searchController = TextEditingController();
  
  // Filters
  String _selectedTypeFilter = 'All'; // 'All', 'Recurring', 'Flexible', 'Events'
  String? _selectedTagFilter; // Specific tag or null

  // Demo Data (100+ items capability simulation)
  // We will generate some more data to test scrolling
  // Data Storage
  List<ScheduleItem> _allSchedules = [];
  List<ScheduleItem> _filteredSchedules = [];

  @override
  void initState() {
    super.initState();
    _generateStudyPlan();
    _filterSchedules();
    _searchController.addListener(_filterSchedules);
  }

  void _generateStudyPlan() {
    _allSchedules.clear();
    
    // Algorithm: Start from upcoming Sunday (or today if Sunday)
    final now = DateTime.now();
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday < 0) daysUntilSunday += 7;
    
    // Base Start Date (Sunday at 00:00)
    final startDate = DateUtils.dateOnly(now.add(Duration(days: daysUntilSunday)));

    for (int i = 0; i < 10; i++) {
        final int chapter = i + 1;
        final weekStart = startDate.add(Duration(days: i * 7));

        // 1. Reading Session (Sunday 10:00 - 12:00)
        _allSchedules.add(ScheduleItem(
            id: 'read_ch$chapter',
            title: 'Read Chapter $chapter',
            groupTag: '#DeepLearning',
            tags: ['#Ch$chapter', '#Reading'],
            type: ScheduleType.classSession,
            repeatType: ScheduleRepeatType.oneTime,
            validFrom: weekStart,
            specificStart: weekStart.add(const Duration(hours: 10)),
            specificEnd: weekStart.add(const Duration(hours: 12)),
        ));

        // 2. Exam 1 (Tuesday 18:00 - 18:30)
        final exam1Date = weekStart.add(const Duration(days: 2));
        _allSchedules.add(ScheduleItem(
            id: 'exam1_ch$chapter',
            title: 'Exam 1 - Chapter $chapter',
            groupTag: '#DeepLearning',
            tags: ['#Ch$chapter', '#Exam'],
            type: ScheduleType.workshop,
            repeatType: ScheduleRepeatType.oneTime,
            validFrom: exam1Date,
            specificStart: exam1Date.add(const Duration(hours: 18)),
            specificEnd: exam1Date.add(const Duration(hours: 18, minutes: 30)),
        ));
        
        // 3. Exam 2 (Thursday 18:00 - 18:30)
        final exam2Date = weekStart.add(const Duration(days: 4));
        _allSchedules.add(ScheduleItem(
            id: 'exam2_ch$chapter',
            title: 'Exam 2 - Chapter $chapter',
            groupTag: '#DeepLearning',
            tags: ['#Ch$chapter', '#Exam'],
            type: ScheduleType.workshop,
            repeatType: ScheduleRepeatType.oneTime,
            validFrom: exam2Date,
            specificStart: exam2Date.add(const Duration(hours: 18)),
            specificEnd: exam2Date.add(const Duration(hours: 18, minutes: 30)),
        ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSchedules() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSchedules = _allSchedules.where((item) {
        // 1. Search Query
        final matchesQuery = item.title.toLowerCase().contains(query) || 
                             item.tags.any((t) => t.toLowerCase().contains(query)) ||
                             (item.groupTag?.toLowerCase().contains(query) ?? false);

        // 2. Type Filter
        bool matchesType = true;
        if (_selectedTypeFilter == 'Recurring') {
          matchesType = item.repeatType == ScheduleRepeatType.fixedDays;
        } else if (_selectedTypeFilter == 'Flexible') {
          matchesType = item.repeatType == ScheduleRepeatType.flexible;
        } else if (_selectedTypeFilter == 'Events') {
          matchesType = item.repeatType == ScheduleRepeatType.oneTime;
        }

        // 3. Tag Filter
        bool matchesTag = true;
        if (_selectedTagFilter != null) {
          matchesTag = item.tags.contains(_selectedTagFilter) || item.groupTag == _selectedTagFilter;
        }

        return matchesQuery && matchesType && matchesTag;
      }).toList();
    });
  }

  void _addSchedule(ScheduleItem item) {
    setState(() {
      _allSchedules.add(item);
      _allSchedules.sort((a, b) => a.validFrom.compareTo(b.validFrom));
      _filterSchedules();
    });
  }

  void _editSchedule(ScheduleItem item) {
    setState(() {
      final index = _allSchedules.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _allSchedules[index] = item;
        _filterSchedules();
      }
    });
  }

  void _deleteSchedule(String id) {
    setState(() {
      _allSchedules.removeWhere((element) => element.id == id);
      _filterSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Collect unique tags for filter row 2
    final Set<String> allTags = {};
    for (var s in _allSchedules) {
      if(s.groupTag != null) allTags.add(s.groupTag!);
      allTags.addAll(s.tags);
    }
    final List<String> sortedTags = allTags.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
           onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Schedules', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), // Reduced
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search schedules...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                filled: true, fillColor: const Color(0xFF16161E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Types (Recurring, Flexible, Events)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Recurring', 'Flexible', 'Events'].map((type) {
                final isSelected = _selectedTypeFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                         _selectedTypeFilter = type; // Radio behavior
                         _filterSchedules();
                      });
                    },
                    backgroundColor: const Color(0xFF16161E),
                    selectedColor: const Color(0xFF3B82F6),
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // Row 2: Tags
          if(sortedTags.isNotEmpty)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: sortedTags.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tag = sortedTags[index];
                  final isSelected = _selectedTagFilter == tag;
                  return ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedTagFilter = selected ? tag : null; // Toggle
                        _filterSchedules();
                      });
                    },
                    backgroundColor: const Color(0xFF16161E),
                    selectedColor: const Color(0xFF3B82F6).withOpacity(0.2),
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[400],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.white.withOpacity(0.05))),
                    side: BorderSide.none,
                  );
                },
              ),
            ),

          // Schedule List
          Expanded(
            child: _filteredSchedules.isEmpty 
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredSchedules.length,
                itemBuilder: (context, index) {
                  return _buildCompactScheduleCard(_filteredSchedules[index]);
                },
              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Removed _buildOverviewTab as it's merged into body

  Widget _buildCompactScheduleCard(ScheduleItem item) {
    return Dismissible(
       key: Key(item.id),
       background: Container(
         alignment: Alignment.centerRight,
         padding: const EdgeInsets.only(right: 20),
         margin: const EdgeInsets.only(bottom: 8),
         decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
         child: const Icon(Icons.delete, color: Colors.white, size: 20),
       ),
       direction: DismissDirection.endToStart,
       confirmDismiss: (direction) async {
         return await showDialog(
           context: context,
           builder: (ctx) => AlertDialog(
             backgroundColor: const Color(0xFF1E1E1E),
             title: Text("Delete?", style: GoogleFonts.outfit(color: Colors.white)),
             content: Text("Delete '${item.title}'?", style: GoogleFonts.outfit(color: Colors.white70)),
             actions: [
               TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
               TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
             ],
           )
         );
       },
       onDismissed: (_) => _deleteSchedule(item.id),
       child: GestureDetector(
        onTap: () => _showScheduleDialog(existingItem: item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8), // Reduced margin
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
          decoration: BoxDecoration(
            color: const Color(0xFF16161E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
               // Type Indicator Strip
               Container(
                 width: 3,
                 height: 40,
                 decoration: BoxDecoration(
                   color: _getTypeColor(item.type),
                   borderRadius: BorderRadius.circular(2),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       children: [
                         if(item.groupTag != null)
                           Container(
                             margin: const EdgeInsets.only(right: 6),
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(
                               color: _getTypeColor(item.type).withOpacity(0.2),
                               borderRadius: BorderRadius.circular(4),
                             ),
                             child: Text(
                               item.groupTag!,
                               style: GoogleFonts.outfit(color: _getTypeColor(item.type), fontSize: 10, fontWeight: FontWeight.bold),
                             ),
                           ),
                         Expanded(
                           child: Text(
                             item.title,
                             style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            _getScheduleTimeDescription(item),
                            style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          if(item.tags.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
                              child: Text(item.tags.first, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                            ),
                            if(item.tags.length > 1)
                               Padding(padding: const EdgeInsets.only(left: 4), child: Text('+${item.tags.length - 1}', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 10))),
                        ],
                      ),
                   ],
                 ),
               ),
               const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
            ],
          ),
        ),
       ),
    );
  }

  // Removed _buildCalendarTab

  // --- Helpers ---

  String _getScheduleTimeDescription(ScheduleItem item) {
    if (item.repeatType == ScheduleRepeatType.oneTime) {
      if (item.specificStart == null) return "No Date";
      return "${DateFormat('MMM d').format(item.specificStart!)} • ${item.timeRange}";
    } else if (item.repeatType == ScheduleRepeatType.fixedDays) {
      if (item.weekDays == null || item.weekDays!.isEmpty) return "No Days";
      // Abbreviated days for compact view
      final days = item.weekDays!.map((d) => ['M','T','W','T','F','S','S'][d-1]).join("");
      return "$days • ${item.timeRange}";
    } else {
      return "${item.targetOccurrences}x / week";
    }
  }

  Color _getTypeColor(ScheduleType type) {
    switch (type) {
      case ScheduleType.classSession: return Colors.blueAccent;
      case ScheduleType.workshop: return Colors.purpleAccent;
      case ScheduleType.event: return Colors.orangeAccent;
      case ScheduleType.personal: return Colors.greenAccent;
    }
  }
  
  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            'No Schedules Found',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog({ScheduleItem? existingItem}) {
    // Reusing the same dialog logic, refined for Group Tags
    final titleController = TextEditingController(text: existingItem?.title ?? '');
    final tagController = TextEditingController(); // For sub-tags
    
    // Group Tag State
    String? selectedGroupTag = existingItem?.groupTag;
    final TextEditingController groupController = TextEditingController(text: existingItem?.groupTag ?? '');

    // State initialization
    ScheduleType selectedType = existingItem?.type ?? ScheduleType.classSession;
    ScheduleRepeatType selectedRepeatType = existingItem?.repeatType ?? ScheduleRepeatType.fixedDays;
    List<String> currentTags = existingItem?.tags != null ? List.from(existingItem!.tags) : [];
    
    // One-Time
    DateTime selectedDate = existingItem?.specificStart ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(existingItem?.specificStart ?? DateTime.now());
    
    // Fixed Days
    List<int> selectedWeekDays = existingItem?.weekDays != null ? List.from(existingItem!.weekDays!) : [];
    TimeOfDay fixedStartTime = existingItem?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    int durationMinutes = existingItem?.duration?.inMinutes ?? 60;

    // Flexible
    int occurrences = existingItem?.targetOccurrences ?? 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                       Text(existingItem == null ? 'New Schedule' : 'Edit Schedule', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                       IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context))
                  ]),
                  const SizedBox(height: 24),
                  
                  // Title
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: GoogleFonts.outfit(color: Colors.grey),
                      filled: true, fillColor: Colors.black38,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.title, color: Colors.grey, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // --- GROUP TAG INPUT (HIERARCHY) ---
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: groupController,
                          style: GoogleFonts.outfit(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Main Group (e.g. #Health)',
                            labelStyle: GoogleFonts.outfit(color: Colors.blueAccent),
                            hintText: '#Health',
                            hintStyle: GoogleFonts.outfit(color: Colors.white24),
                            filled: true,
                            fillColor: Colors.blueAccent.withOpacity(0.1),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.3))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.3))),
                            prefixIcon: const Icon(Icons.folder, color: Colors.blueAccent, size: 20),
                          ),
                          onChanged: (val) {
                             selectedGroupTag = val.trim();
                             if(selectedGroupTag!.isNotEmpty && !selectedGroupTag!.startsWith('#')) {
                               selectedGroupTag = '#$selectedGroupTag';
                             }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                       Text('Sub-Tags (e.g. #Yoga)', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                       const SizedBox(height: 6),
                       Wrap(spacing: 8, runSpacing: 8, children: currentTags.map((tag) => Chip(
                           label: Text(tag, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11)),
                           backgroundColor: const Color(0xFF3B82F6).withOpacity(0.2), // Matching Brand
                           deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
                           onDeleted: () => setState(() => currentTags.remove(tag)),
                           side: BorderSide.none,
                       )).toList()),
                       if(currentTags.isNotEmpty) const SizedBox(height: 8),
                       TextField(
                        controller: tagController,
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add sub-tag...',
                          filled: true, fillColor: Colors.black38,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFF3B82F6)),
                            onPressed: () {
                              if(tagController.text.isNotEmpty) {
                                String t = tagController.text.trim().replaceAll('#', '');
                                String prefix = '';
                                if (selectedGroupTag != null && selectedGroupTag!.isNotEmpty) {
                                  prefix = selectedGroupTag!.replaceAll('#', '') + '_';
                                }
                                String finalTag = '#$prefix$t'; // e.g., #Health_Yoga
                                setState(() {
                                  if (!currentTags.contains(finalTag)) currentTags.add(finalTag);
                                  tagController.clear();
                                });
                              }
                            },
                          )
                        ),
                        onSubmitted: (value) {
                           if(value.isNotEmpty) {
                                String t = value.trim().replaceAll('#', '');
                                String prefix = '';
                                if (selectedGroupTag != null && selectedGroupTag!.isNotEmpty) {
                                  prefix = selectedGroupTag!.replaceAll('#', '') + '_';
                                }
                                String finalTag = '#$prefix$t';
                                setState(() { 
                                  if (!currentTags.contains(finalTag)) currentTags.add(finalTag); 
                                  tagController.clear(); 
                                });
                            }
                        },
                      ),
                  ]),
                  
                  const SizedBox(height: 20),
                  // Type & Format
                  Row(children: [
                      Expanded(child: DropdownButtonFormField<ScheduleType>(
                          value: selectedType,
                          dropdownColor: const Color(0xFF2C2C2E),
                          decoration: InputDecoration(labelText: 'Category', labelStyle: GoogleFonts.outfit(color: Colors.grey), filled: true, fillColor: Colors.black38, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                          items: ScheduleType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white)))).toList(),
                          onChanged: (v) => setState(() => selectedType = v!),
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: DropdownButtonFormField<ScheduleRepeatType>(
                          value: selectedRepeatType,
                          dropdownColor: const Color(0xFF2C2C2E),
                          decoration: InputDecoration(labelText: 'Format', labelStyle: GoogleFonts.outfit(color: Colors.grey), filled: true, fillColor: Colors.black38, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                          items: ScheduleRepeatType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.replaceFirst(RegExp(r'ScheduleRepeatType\.'), '').toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)))).toList(),
                          onChanged: (v) => setState(() => selectedRepeatType = v!),
                      )),
                  ]),
                  const SizedBox(height: 24),

                  // Conditional Inputs (Simplified for brevity as logic is same as before)
                  if (selectedRepeatType == ScheduleRepeatType.oneTime) ...[
                      // Date/Time Pickers
                       Row(children: [
                          Expanded(child: InkWell(onTap: () async { final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365))); if (d != null) setState(() => selectedDate = d); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(DateFormat('MMM d, y').format(selectedDate), style: GoogleFonts.outfit(color: Colors.white)))))),
                          const SizedBox(width: 8),
                          Expanded(child: InkWell(onTap: () async { final t = await showTimePicker(context: context, initialTime: selectedTime); if (t != null) setState(() => selectedTime = t); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(selectedTime.format(context), style: GoogleFonts.outfit(color: Colors.white)))))),
                       ]),
                  ] else if (selectedRepeatType == ScheduleRepeatType.fixedDays) ...[
                      // Weekdays
                      Wrap(spacing: 8, children: List.generate(7, (index) {
                          final dayNum = index + 1;
                          final isSelected = selectedWeekDays.contains(dayNum);
                          return FilterChip(
                              label: Text(_getDayName(dayNum), style: GoogleFonts.outfit(color: isSelected ? Colors.white : Colors.grey)),
                              selected: isSelected,
                              onSelected: (s) => setState(() { if(s) selectedWeekDays.add(dayNum); else selectedWeekDays.remove(dayNum); selectedWeekDays.sort(); }),
                              backgroundColor: Colors.white10, selectedColor: const Color(0xFF3B82F6), checkmarkColor: Colors.white, side: BorderSide.none,
                          );
                      })),
                      const SizedBox(height: 12),
                      Row(children: [
                          Expanded(child: InkWell(onTap: () async { final t = await showTimePicker(context: context, initialTime: fixedStartTime); if (t != null) setState(() => fixedStartTime = t); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(fixedStartTime.format(context), style: GoogleFonts.outfit(color: Colors.white)))))),
                          const SizedBox(width: 8),
                          Expanded(child: DropdownButtonFormField<int>(value: durationMinutes, dropdownColor: const Color(0xFF2C2C2E), items: [30, 45, 60, 90, 120, 180].map((m) => DropdownMenuItem(value: m, child: Text('$m mins', style: GoogleFonts.outfit(color: Colors.white)))).toList(), onChanged: (v) => setState(() => durationMinutes = v!))),
                      ]),
                  ] else if (selectedRepeatType == ScheduleRepeatType.flexible) ...[
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          IconButton(icon: const Icon(Icons.remove, color: Colors.white), onPressed: () => setState(() { if(occurrences > 1) occurrences--; })),
                          Text('$occurrences / week', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18)),
                          IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () => setState(() => occurrences++)),
                      ]),
                  ],

                  const SizedBox(height: 30),
                  SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          ScheduleItem newItem = ScheduleItem(
                            id: existingItem?.id ?? DateTime.now().toString(),
                            title: titleController.text,
                            tags: currentTags,
                            groupTag: selectedGroupTag,
                            type: selectedType,
                            repeatType: selectedRepeatType,
                            validFrom: existingItem?.validFrom ?? DateTime.now(),
                          );
                          // Apply specific fields
                          if (selectedRepeatType == ScheduleRepeatType.oneTime) {
                             newItem = newItem.copyWith(specificStart: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute), specificEnd: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour + 1, selectedTime.minute));
                          } else if (selectedRepeatType == ScheduleRepeatType.fixedDays) {
                            newItem = newItem.copyWith(weekDays: selectedWeekDays, startTime: fixedStartTime, duration: Duration(minutes: durationMinutes));
                          } else if (selectedRepeatType == ScheduleRepeatType.flexible) {
                            newItem = newItem.copyWith(targetOccurrences: occurrences, period: const Duration(days: 7));
                          }

                          if (existingItem == null) _addSchedule(newItem); else _editSchedule(newItem);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text(existingItem == null ? 'Create Schedule' : 'Save Changes', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  )),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
