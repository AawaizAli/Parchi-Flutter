import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: 10,
        separatorBuilder: (ctx, i) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: index < 3 ? Colors.amber : Colors.grey[300],
              child: Text("#${index + 1}"),
            ),
            title: Text("Student ${index + 1}"),
            trailing: Text(
              "${1000 - (index * 50)} Saved",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}