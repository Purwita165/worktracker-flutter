/*
============================================================
FILE: todo_page.dart
============================================================

UI Layer dari aplikasi HB-ExeCon.

Tugas file ini:

• menampilkan daftar pekerjaan
• menerima input user
• mengelola state UI
• memanggil DBHelper

Arsitektur:

UI
↓
Todo Model
↓
DBHelper
↓
SQLite

============================================================
*/

import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/db_helper.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final dbHelper = DBHelper.instance;

  List<Todo> todos = [];

  String filterMode = "all";

  /*
  ============================
  FORM CONTROLLERS
  ============================
  */

  final descController = TextEditingController();
  final workController = TextEditingController();
  final refController = TextEditingController();

  String? priority;
  DateTime? dueDate;
  int? progress;

  final String currentUserId = "local-user";

  /*
  ============================
  PRIORITY LABEL
  ============================
  */

  static const Map<String, String> priorityLabels = {
    "H": "High",
    "M": "Medium",
    "L": "Low",
  };

  /*
  ============================
  INIT
  ============================
  */

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  /*
  ============================
  LOAD DATA FROM DATABASE
  ============================
  */

  Future<void> loadTodos() async {
    final data = await dbHelper.getTodos();

    setState(() {
      todos = data;
    });
  }

  /*
  ============================
  ADD TODO
  ============================
  */

  Future<void> addTodo() async {

    print("ADD TODO START");

    if (descController.text.trim().isEmpty) {
      
      return;
    }

    final todo = Todo(
      userId: currentUserId,
      description: descController.text.trim(),
      workId: workController.text,
      ref: refController.text,
      priority: priority ?? "M",
      dueDate: dueDate,
      progress: progress ?? 0,
      taskDate: DateTime.now(),
      isDone: false,
    );

    await dbHelper.insertTodo(todo);

    print ("INSERT SUCCESS");

    await loadTodos();

    print("RELOAD TODOS");

    descController.clear();
    workController.clear();
    refController.clear();

    priority = null;
    dueDate = null;
    progress = 0;
  }

  /*
  ============================
  DELETE
  ============================
  */

  Future<void> deleteTodo(int id) async {
    await dbHelper.deleteTodo(id);

    await loadTodos();
  }

  /*
  ============================
  TOGGLE STATUS
  ============================
  */

  Future<void> toggleTodo(Todo todo) async {
    todo.isDone = !todo.isDone;

    await dbHelper.updateTodoStatus(todo.id!, todo.isDone ? 1 : 0);

    await loadTodos();
  }

  /*
  ============================
  FILTER
  ============================
  */

  List<Todo> getFilteredTodos() {
    if (filterMode == "active") {
      return todos.where((t) => !t.isDone).toList();
    }

    if (filterMode == "completed") {
      return todos.where((t) => t.isDone).toList();
    }

    if (filterMode == "priority") {
      final sorted = [...todos];

      sorted.sort((a, b) => b.priority.compareTo(a.priority));

      return sorted;
    }

    if (filterMode == "due") {
      final sorted = [...todos];

      sorted.sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;

        return a.dueDate!.compareTo(b.dueDate!);
      });

      return sorted;
    }

    return todos;
  }

  /*
  ============================
  DATE PICKER
  ============================
  */

  Future<void> pickDueDate(Function setStateDialog) async {
    final date = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setStateDialog(() {
        dueDate = date;
      });
    }
  }

  /*
  ============================
  UI
  ============================
  */

  @override
  Widget build(BuildContext context) {
    final filteredTodos = getFilteredTodos();

    return Scaffold(
      appBar: AppBar(title: const Text("HB-ExeCon v1")),

      body: Column(
        children: [
          /*
          FILTER BAR
          */
          Padding(
            padding: const EdgeInsets.all(8),

            child: Wrap(
              spacing: 8,

              children: [
                FilterChip(
                  label: const Text("All"),
                  selected: filterMode == "all",
                  onSelected: (_) {
                    setState(() => filterMode = "all");
                  },
                ),

                FilterChip(
                  label: const Text("Active"),
                  selected: filterMode == "active",
                  onSelected: (_) {
                    setState(() => filterMode = "active");
                  },
                ),

                FilterChip(
                  label: const Text("Completed"),
                  selected: filterMode == "completed",
                  onSelected: (_) {
                    setState(() => filterMode = "completed");
                  },
                ),

                FilterChip(
                  label: const Text("Priority"),
                  selected: filterMode == "priority",
                  onSelected: (_) {
                    setState(() => filterMode = "priority");
                  },
                ),

                FilterChip(
                  label: const Text("Due Date"),
                  selected: filterMode == "due",
                  onSelected: (_) {
                    setState(() => filterMode = "due");
                  },
                ),
              ],
            ),
          ),

          /*
          LIST
          */
          Expanded(
            child: filteredTodos.isEmpty
                ? const Center(
                    child: Text(
                      "No tasks yet",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTodos.length,

                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];

                      return ListTile(
                        leading: Checkbox(
                          value: todo.isDone,
                          onChanged: (_) => toggleTodo(todo),
                        ),

                        title: Text(
                          todo.description,
                          style: TextStyle(
                            decoration: todo.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("WorkID : ${todo.workId ?? "-"}"),
                            Text("Ref    : ${todo.ref ?? "-"}"),

                            Text("Priority : ${priorityLabels[todo.priority]}"),

                            Text("Progress : ${todo.progress ?? 0}%"),

                            if (todo.dueDate != null)
                              Text(
                                "Due : ${todo.dueDate!.toLocal().toString().split(' ')[0]}",
                              ),
                          ],
                        ),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),

                          onPressed: () {
                            deleteTodo(todo.id!);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      /*
      ADD BUTTON
      */
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // RESET FORM
          descController.clear();
          workController.clear();
          refController.clear();

          priority = "M";
          progress = 0;
          dueDate = DateTime.now();

          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  return AlertDialog(
                    title: const Text("Add Task"),

                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: "Description",
                            ),
                          ),

                          TextField(
                            controller: workController,
                            decoration: const InputDecoration(
                              labelText: "WorkID",
                            ),
                          ),

                          TextField(
                            controller: refController,
                            decoration: const InputDecoration(
                              labelText: "Reference",
                            ),
                          ),

                          DropdownButtonFormField<String>(
                            value: priority,
                            decoration: const InputDecoration(
                              labelText: "Priority",
                            ),
                            items: const [
                              DropdownMenuItem(value: "H", child: Text("High")),
                              DropdownMenuItem(
                                value: "M",
                                child: Text("Medium"),
                              ),
                              DropdownMenuItem(value: "L", child: Text("Low")),
                            ],
                            onChanged: (value) {
                              setStateDialog(() {
                                priority = value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          Text("Progress: ${progress ?? 0}%"),

                          Slider(
                            value: (progress ?? 0).toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            onChanged: (value) {
                              setStateDialog(() {
                                progress = value.toInt();
                              });
                            },
                          ),

                          SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Due: ${dueDate != null ? dueDate!.toString().split(' ')[0] : 'None'}",
                              ),

                              ElevatedButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: dueDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );

                                  if (picked != null) {
                                    setStateDialog(() {
                                      dueDate = picked;
                                    });
                                  }
                                },
                                child: const Text("Pick Due Date"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          await addTodo();

                          Navigator.pop(context);
                        },

                        child: const Text("Save"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
