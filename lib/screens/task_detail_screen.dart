import 'package:flutter/material.dart';
import '../models/task_model.dart';

// Screen to display detailed information about a task
class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  // Constructor requires the task to be shown
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar with back button and edit icon
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Task Details",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          // Placeholder edit icon (not functional yet)
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.edit, color: Colors.black),
          ),
        ],
      ),

      // Main content
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title
            Text(
              task.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // Status badge and creation date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? Colors.green.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.isCompleted ? "Completed" : "In Progress",
                    style: TextStyle(
                      color: task.isCompleted ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Created on date
                Text(
                  "Created on ${task.dateTime.day}/${task.dateTime.month}/${task.dateTime.year}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Due Date container
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),
                  const SizedBox(width: 10),

                  // Display due date and time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Due Date",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${task.dateTime.day}/${task.dateTime.month}/${task.dateTime.year} "
                        "${task.dateTime.hour}:${task.dateTime.minute.toString().padLeft(2, '0')}",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Description section
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              task.description.isEmpty ? "No description" : task.description,
              style: const TextStyle(height: 1.4),
            ),

            const SizedBox(height: 20),

            // Priority section (currently static: High priority with red dot)
            const Text(
              "Priority",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: const [
                Icon(Icons.circle, size: 10, color: Colors.red),
                SizedBox(width: 6),
                Text("High", style: TextStyle(color: Colors.red)),
              ],
            ),

            const Spacer(), // Pushes buttons to the bottom

            // Buttons: Delete and Mark as Complete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Delete task from Hive box and go back
                OutlinedButton.icon(
                  onPressed: () async {
                    await task.delete(); // Deletes task
                    Navigator.pop(context); // Navigate back
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                ),

                // Mark task as completed and update Hive
                ElevatedButton.icon(
                  onPressed: () async {
                    task.isCompleted = true; // Update status
                    await task.save(); // Save change to Hive
                    Navigator.pop(context); // Go back
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Mark as Complete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
