import 'package:flutter/material.dart';

enum ScheduleType { classSession, event, workshop, personal }
enum ScheduleRepeatType { oneTime, fixedDays, flexible }

class ScheduleItem {
  final String id;
  String title;
  ScheduleType type;
  
  // Tagging
  List<String> tags; 
  String? groupTag; // Main Category (e.g. #Health)
  
  String? notes;

  // --- Recurrence & Timing Configuration ---
  final ScheduleRepeatType repeatType;

  // Validity Range
  final DateTime validFrom;
  final DateTime? validUntil;

  // 1. One-Time Data (if repeatType == oneTime)
  final DateTime? specificStart;
  final DateTime? specificEnd;

  // 2. Fixed Schedule Data (if repeatType == fixedDays)
  // Which days of the week? (1=Mon, 7=Sun)
  final List<int>? weekDays;
  final TimeOfDay? startTime;
  final Duration? duration;

  // 3. Flexible Schedule Data (if repeatType == flexible)
  final int? targetOccurrences; // e.g., 3 times
  final Duration? period; // e.g., per 7 days (default)

  ScheduleItem({
    required this.id,
    required this.title,
    this.type = ScheduleType.personal,
    this.tags = const [], 
    this.groupTag,
    this.notes,
    this.repeatType = ScheduleRepeatType.oneTime,
    required this.validFrom,
    this.validUntil,
    this.specificStart,
    this.specificEnd,
    this.weekDays,
    this.startTime,
    this.duration,
    this.targetOccurrences,
    this.period,
  });

  // Helper: Get formatted time range string (logic depends on type)
  String get timeRange {
    if (repeatType == ScheduleRepeatType.oneTime && specificStart != null && specificEnd != null) {
      return "${_formatTime(specificStart!)} - ${_formatTime(specificEnd!)}";
    } else if (repeatType == ScheduleRepeatType.fixedDays && startTime != null && duration != null) {
        // Calculate end time based on start + duration
        final start = DateTime(2022, 1, 1, startTime!.hour, startTime!.minute);
        final end = start.add(duration!);
        return "${_formatTime(start)} - ${_formatTime(end)}";
    } else if (repeatType == ScheduleRepeatType.flexible) {
      return "Flexible • ${targetOccurrences ?? 1}x / ${period?.inDays ?? 7} days";
    }
    return "TBD";
  }
  
  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  // Copy with method
  ScheduleItem copyWith({
    String? title,
    ScheduleType? type,
    List<String>? tags,
    String? groupTag,
    String? notes,
    ScheduleRepeatType? repeatType,
    DateTime? validFrom,
    DateTime? validUntil,
    DateTime? specificStart,
    DateTime? specificEnd,
    List<int>? weekDays,
    TimeOfDay? startTime,
    Duration? duration,
    int? targetOccurrences,
    Duration? period,
  }) {
    return ScheduleItem(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      groupTag: groupTag ?? this.groupTag,
      notes: notes ?? this.notes,
      repeatType: repeatType ?? this.repeatType,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      specificStart: specificStart ?? this.specificStart,
      specificEnd: specificEnd ?? this.specificEnd,
      weekDays: weekDays ?? this.weekDays,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      targetOccurrences: targetOccurrences ?? this.targetOccurrences,
      period: period ?? this.period,
    );
  }
}
