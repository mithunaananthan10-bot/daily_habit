import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HabitPage extends StatefulWidget {
  final int userId;
  const HabitPage({super.key, required this.userId});

  @override
  State<HabitPage> createState() => HabitPageState();
}

class HabitPageState extends State<HabitPage> {
  List<Map<String, dynamic>> habits = [];
  final TextEditingController habitController = TextEditingController();

  final String baseUrl = "http://127.0.0.1:5000";

  @override
  void initState() {
    super.initState();
    fetchHabits();
  }

  // 🌟 AUTO EMOJI FUNCTION
  String getEmoji(String habit) {
    habit = habit.toLowerCase();

    if (habit.contains("sleep")) return "😴";
    if (habit.contains("water")) return "💧";
    if (habit.contains("drink")) return "🥤";
    if (habit.contains("exercise")) return "💪";
    if (habit.contains("workout")) return "🏋️";
    if (habit.contains("run")) return "🏃";
    if (habit.contains("walk")) return "🚶";
    if (habit.contains("study")) return "📚";
    if (habit.contains("read")) return "📖";
    if (habit.contains("meditate")) return "🧘";
    if (habit.contains("yoga")) return "🧘‍♀️";
    if (habit.contains("eat")) return "🍎";
    if (habit.contains("diet")) return "🥗";
    if (habit.contains("music")) return "🎵";
    if (habit.contains("code")) return "💻";
    if (habit.contains("pray")) return "🙏";

    return "🌟";
  }

  // ✅ FETCH HABITS
  Future<void> fetchHabits() async {
    final url = Uri.parse("$baseUrl/habits/${widget.userId}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      setState(() {
        habits = data.map<Map<String, dynamic>>((h) {
          return {
            "id": h["id"],
            "name": "${getEmoji(h["habit"])}  ${h["habit"]}",
            "done": h["done"] == 1,
          };
        }).toList();
      });
    }
  }

  // ✅ ADD HABIT
  Future<void> addHabit(String habit) async {
    final url = Uri.parse("$baseUrl/add_habit");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": widget.userId,
        "habit": habit,
      }),
    );

    habitController.clear();
    fetchHabits();
  }

  // ✅ MARK DONE
  Future<void> markDone(int habitId) async {
    final url = Uri.parse("$baseUrl/mark_done/$habitId");
    await http.post(url);
    fetchHabits();
  }

  // ✅ DELETE HABIT
  Future<void> deleteHabit(int habitId) async {
    final url = Uri.parse("$baseUrl/delete_habit/$habitId");
    await http.delete(url);
    fetchHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 216, 143, 238),
              Color(0xFF16A085),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  "My Habits 🌱",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: habits.isEmpty
                  ? const Center(
                      child: Text(
                        "No habits yet ➕\nTap + to add",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: habits[index]["done"],
                                onChanged: (value) {
                                  markDone(habits[index]["id"]);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  habits[index]["name"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: habits[index]["done"]
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  deleteHabit(habits[index]["id"]);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add New Habit 🌱"),
                content: TextField(
                  controller: habitController,
                  decoration: const InputDecoration(
                    hintText: "Enter habit (eg: Sleep early)",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel ❌"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (habitController.text.isNotEmpty) {
                        addHabit(habitController.text);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Add ✅"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
