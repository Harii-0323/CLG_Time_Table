import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 350,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("College Timetable System",
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  TextField(decoration: const InputDecoration(labelText: "Username")),
                  TextField(
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                    },
                    child: const Text("Sign In"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
