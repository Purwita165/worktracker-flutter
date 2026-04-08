// lib/services/todo_logic.dart

import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/notification_service.dart';

class TodoLogic {
  /// ===============================
  /// HITUNG SELISIH HARI KE DUE DATE
  /// ===============================
  static int getDueDiffDays(Todo todo) {
    if (todo.dueDate == null) return 999;

    return todo.dueDate!.difference(DateTime.now()).inDays;
  }

  /// ===============================
  /// WARNA DESCRIPTION (URGENCY)
  /// ===============================
  static Color getDescriptionColor(Todo todo) {
    final now = DateTime.now();

    // 🔥 PRIORITAS 1: ACTIVE tapi sudah lewat dueDate
    if (!todo.isDone && todo.dueDate != null && todo.dueDate!.isBefore(now)) {
      return Colors.red;
    }

    // 🔥 PRIORITAS 2: sudah selesai → netral
    if (todo.isDone) return Colors.grey;

    final start = todo.startDate;

    if (start == null) return Colors.black;

    final diff = start.difference(now).inDays;

    if (diff > 7) {
      return Colors.grey;
    } else if (diff > 2) {
      return Colors.green;
    } else if (diff >= 0) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }

  /// ===============================
  /// OVERDUE CHECK
  /// ===============================
  static bool isOverdue(Todo todo) {
    if (todo.dueDate == null) return false;

    return todo.dueDate!.isBefore(DateTime.now()) && !todo.isDone;
  }

// ALARM SETTING

   DateTime? _alarmAt9am(DateTime? start, {required int daysBefore}) {
  if (start == null) return null;

  final base = DateTime(start.year, start.month, start.day)
      .subtract(Duration(days: daysBefore));

  return DateTime(base.year, base.month, base.day, 9);
}

  Future<void> generateReminders(List<Todo> todos) async {
    final Map<DateTime, List<Todo>> grouped = {};

    for (var t in todos) {
      final times = [
        _alarmAt9am(t.startDate, daysBefore: 2),
        _alarmAt9am(t.startDate, daysBefore: 1),
      ];

      for (var time in times) {
        if (time != null && time.isAfter(DateTime.now())) {
          grouped.putIfAbsent(time, () => []);
          grouped[time]!.add(t);
        }
      }
    }

    await NotificationService().cancelAll();

    for (var entry in grouped.entries) {
      final time = entry.key;
      final tasks = entry.value;

      final title = tasks.length == 1
          ? "Task starting soon"
          : "${tasks.length} tasks starting soon";

      final body = tasks.length == 1
          ? tasks.first.description
          : tasks.take(3).map((t) => "• ${t.description}").join("\n");

      await NotificationService().schedule(
        id: time.millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        scheduledTime: time,
      );
    }
  }
}
