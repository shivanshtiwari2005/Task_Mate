import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

// Model for API Todo Item
class TodoListModel {
  int? userId;
  int? id;
  String? title;
  bool? completed;

  TodoListModel({this.userId, this.id, this.title, this.completed});

  // Deserialize JSON data to model
  TodoListModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    completed = json['completed'];
  }
}

class HomeScreen extends StatefulWidget {
  final void Function(bool)? onThemeToggle;
  const HomeScreen({super.key, this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "All"; // State to control selected filter tab
  List<TodoListModel> todoListFromApi = []; // List to store API todos

  @override
  void initState() {
    super.initState();
    fetchTodos(); // Fetch API data on screen load
  }

  // Fetch todo list from JSONPlaceholder API
  Future<void> fetchTodos() async {
    final url = Uri.parse("https://jsonplaceholder.typicode.com/todos");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        // Convert response to list of TodoListModel
        todoListFromApi = data.map((json) => TodoListModel.fromJson(json)).toList();
      });
    } else {
      print("Failed to fetch todos: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
        title: const Text('My Tasks'),
        actions: [
          // Dark Mode Toggle Switch
          Switch(
            value: isDarkMode,
            onChanged: widget.onThemeToggle,
            activeColor: Colors.white,
          ),
        ],
      ),

      // Body dynamically updates based on Hive changes
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TaskModel>('tasks').listenable(),
        builder: (context, Box<TaskModel> box, _) {
          // Get all local tasks from Hive
          final allTasks = box.values.toList();
          final pending = allTasks.where((t) => !t.isCompleted).toList();
          final completed = allTasks.where((t) => t.isCompleted).toList();

          // Filter tasks based on selected tab
          List<TaskModel> filteredTasks;
          if (selectedFilter == "Pending") {
            filteredTasks = pending;
          } else if (selectedFilter == "Completed") {
            filteredTasks = completed;
          } else {
            filteredTasks = allTasks;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // Top summary cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusCard(pending.length, 'Tasks Pending', context),
                    _statusCard(completed.length, 'Tasks Completed', context),
                  ],
                ),
                const SizedBox(height: 16),

                // Filter buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ["All", "Pending", "Completed"].map((filter) {
                    final isSelected = selectedFilter == filter;
                    return ElevatedButton(
                      onPressed: () => setState(() => selectedFilter = filter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                        foregroundColor: isSelected ? Colors.white : Colors.black,
                      ),
                      child: Text(filter),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Show API todos in "All" section
                if (selectedFilter == "All" && todoListFromApi.isNotEmpty)
                  ...todoListFromApi.map((todo) => _buildApiTodoCard(todo))
                else
                  // Otherwise show local Hive tasks
                  ...filteredTasks.map((task) {
                    final isCompleted = task.isCompleted;
                    return _buildTaskCard(task, context, completed: isCompleted);
                  }),
              ],
            ),
          );
        },
      ),

      // FAB to navigate to Add Task screen
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Card to display a todo fetched from the API
  Widget _buildApiTodoCard(TodoListModel todo) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          todo.completed! ? Icons.check_circle : Icons.circle_outlined,
          color: todo.completed! ? Colors.blue : Colors.grey,
        ),
        title: Text(
          todo.title ?? '',
          style: todo.completed!
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                )
              : const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('User ID: ${todo.userId}'),
      ),
    );
  }

  // Card to display a local task stored in Hive
  Widget _buildTaskCard(TaskModel task, BuildContext context, {bool completed = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 5,
          backgroundColor: completed
              ? Colors.blue
              : (task.title.contains("Design")
                  ? Colors.red
                  : task.title.contains("Review")
                      ? Colors.orange
                      : Colors.green),
        ),
        title: Text(
          task.title,
          style: completed
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                )
              : const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${task.dateTime.day}/${task.dateTime.month}/${task.dateTime.year} '
              '${task.dateTime.hour}:${task.dateTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: Icon(
          completed ? Icons.check_circle : Icons.check_circle_outline,
          color: completed ? Colors.blue : Colors.grey,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
        ),
      ),
    );
  }

  // Card to display task status summary
  Widget _statusCard(int count, String label, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width * 0.42,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
