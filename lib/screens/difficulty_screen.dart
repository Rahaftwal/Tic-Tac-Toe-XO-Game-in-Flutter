import 'package:flutter/material.dart';
import 'game_screen.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black,
                  Colors.black,
                  Colors.black,
                  Color(0xFF5E17EB),
                  Color(0xFFFF0000),],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SELECT LEVEL',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              _buildLevelButton(context, 'EASY', GameDifficulty.easy),
              const SizedBox(height: 20),
              _buildLevelButton(context, 'MEDIUM', GameDifficulty.medium),
              const SizedBox(height: 20),
              _buildLevelButton(context, 'HARD', GameDifficulty.hard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String text, GameDifficulty difficulty) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              isMultiplayer: false,
              difficulty: difficulty,
            ),
          ),
        );
      },
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

enum GameDifficulty { easy, medium, hard } 