import 'package:flutter/material.dart';

enum ActivityType {
  newChild,
  newTeacher,
  newGuardian,
  newReport,
  other,
}

class ActivityItem {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final ActivityType type;
  final String? entityId; // ID of the related entity (childId, reportId, etc.)

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.type = ActivityType.other,
    this.entityId,
  });
}
