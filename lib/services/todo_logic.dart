// lib/services/todo_logic.dart

import 'package:flutter/material.dart';
import '../models/todo.dart';

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
}
