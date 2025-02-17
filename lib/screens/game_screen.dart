import 'package:flutter/material.dart';
import 'dart:math';

import 'difficulty_screen.dart';

class GameScreen extends StatefulWidget {
  final bool isMultiplayer;
  final GameDifficulty? difficulty;

  const GameScreen({
    super.key,
    required this.isMultiplayer,
    this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<String> board;
  late bool isXTurn;
  late bool gameOver;
  String winner = '';
  late List<int> playerX;
  late List<int> playerO;
  int turn = 0;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    board = List.filled(9, '');
    playerX = [];
    playerO = [];
    isXTurn = true;
    gameOver = false;
    winner = '';
    turn = 0;
  }

  void _makeMove(int index) {
    if (board[index].isEmpty && !gameOver) {
      setState(() {
        if (isXTurn) {
          board[index] = 'X';
          playerX.add(index);
          turn++;
        } else {
          board[index] = 'O';
          playerO.add(index);
          turn++;
        }

        if (_checkWinner(board[index])) {
          gameOver = true;
          winner = board[index];
        } else if (!board.contains('')) {
          gameOver = true;
          winner = 'DRAW';
        } else {
          isXTurn = !isXTurn;
          if (!widget.isMultiplayer && !isXTurn) {
            _makeAIMove();
          }
        }
      });
    }
  }

  void _makeAIMove() {
    int move;
    if (widget.difficulty == GameDifficulty.hard) {
      move = _findWinningMove();
      if (move == -1) {
        move = _findBlockingMove();
        if (move == -1) {
          move = _getRandomMove();
        }
      }
    } else {
      move = widget.difficulty == GameDifficulty.medium && Random().nextBool()
          ? _getBestMove()
          : _getRandomMove();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      _makeMove(move);
    });
  }

  int _getRandomMove() {
    List<int> availableMoves = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        availableMoves.add(i);
      }
    }
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  int _getBestMove() {
    int bestScore = -1000;
    int bestMove = 0;
    
    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        board[i] = 'O';
        int score = _minimax(board, 0, false);
        board[i] = '';
        
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    
    return bestMove;
  }

  int _minimax(List<String> board, int depth, bool isMaximizing) {
    String result = _checkWinnerForMinimax();
    if (result != '') {
      return result == 'O' ? 10 : result == 'X' ? -10 : 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i].isEmpty) {
          board[i] = 'O';
          bestScore = max(bestScore, _minimax(board, depth + 1, false));
          board[i] = '';
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i].isEmpty) {
          board[i] = 'X';
          bestScore = min(bestScore, _minimax(board, depth + 1, true));
          board[i] = '';
        }
      }
      return bestScore;
    }
  }

  String _checkWinnerForMinimax() {
    // Check rows, columns and diagonals
    for (int i = 0; i < 3; i++) {
      if (board[i * 3] != '' &&
          board[i * 3] == board[i * 3 + 1] &&
          board[i * 3] == board[i * 3 + 2]) {
        return board[i * 3];
      }
      if (board[i] != '' &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) {
        return board[i];
      }
    }
    if (board[0] != '' && board[0] == board[4] && board[0] == board[8]) {
      return board[0];
    }
    if (board[2] != '' && board[2] == board[4] && board[2] == board[6]) {
      return board[2];
    }
    if (!board.contains('')) return 'DRAW';
    return '';
  }

  bool _checkWinner(String player) {
    // Check rows
    for (int i = 0; i < 9; i += 3) {
      if (board[i] == player &&
          board[i + 1] == player &&
          board[i + 2] == player) {
        return true;
      }
    }
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[i] == player &&
          board[i + 3] == player &&
          board[i + 6] == player) {
        return true;
      }
    }
    // Check diagonals
    if (board[0] == player && board[4] == player && board[8] == player) {
      return true;
    }
    if (board[2] == player && board[4] == player && board[6] == player) {
      return true;
    }
    return false;
  }

  int _findWinningMove() {
    const List<List<int>> winningPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (var pattern in winningPatterns) {
      if (pattern.where((element) => playerO.contains(element)).length == 2 &&
          pattern.any((element) => !playerX.contains(element) && !playerO.contains(element))) {
        return pattern.firstWhere((element) => !playerX.contains(element) && !playerO.contains(element));
      }
    }
    return -1;
  }

  int _findBlockingMove() {
    const List<List<int>> winningPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (var pattern in winningPatterns) {
      if (pattern.where((element) => playerX.contains(element)).length == 2 &&
          pattern.any((element) => !playerX.contains(element) && !playerO.contains(element))) {
        return pattern.firstWhere((element) => !playerX.contains(element) && !playerO.contains(element));
      }
    }
    return -1;
  }

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/tictactoe.PNG',
              height: 100,
              width: 300,
            ),
            
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('lib/assets/player-x.png', height: 100, width: 100),
                  Image.asset('lib/assets/player-o.png', height: 100, width: 100),
                ],
              ),
            ),
            
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _makeMove(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: board[index] == 'X'
                              ? Colors.purple
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            if (gameOver)
              Column(
                children: [
                  Text(
                    winner == 'DRAW'
                        ? 'DRAW!'
                        : 'WINNER: ${winner}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _initializeGame();
                      });
                    },
                    child: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    isXTurn ? 'lib/assets/x-icon.png' : 'lib/assets/o-icon.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(width: 10),
                 
                ],
              ),
          ],
        ),
      ),
    );
  }
} 