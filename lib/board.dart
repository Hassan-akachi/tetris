import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/piece.dart'; // Ensure this path is correct
import 'package:tetris/pixel.dart'; // Ensure this path is correct
import 'package:tetris/values.dart'; // Ensure this path is correct

// GAME BOARD
List<List<Tetromino?>> gameBoard = List.generate(
  colLength,
      (i) =>
      List.generate(rowLength,
              (j) => null),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: Tetromino.Z); // Initial piece, will be overridden
  int currentScore = 0;
  bool gameOver = false;
  Timer? gameTimer; // Store the timer to cancel it

  bool _isPaused = false; // State variable for pause functionality

  @override
  void initState() {
    super.initState();
    startGame();
  }

  // Dispose of the timer when the widget is removed
  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    // Clear the board for a new game
    gameBoard = List.generate(
      colLength,
          (i) => List.generate(rowLength, (j) => null),
    );
    createNewPiece(); // Create the first piece
    gameOver = false;
    currentScore = 0;
    _isPaused = false; // Ensure game starts unpaused

    Duration frameRate = const Duration(milliseconds: 400); // Start with a reasonable speed
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    gameTimer?.cancel(); // Cancel any existing timer before starting a new one

    // Only start timer if not paused and not game over
    if (!_isPaused && !gameOver) {
      gameTimer = Timer.periodic(frameRate, (timer) {
        setState(() {
          // Check for landing first
          if (checkCollision(Direction.down, currentPiece.position)) {
            // If collision detected, land the piece
            landPiece();
          } else {
            // No collision, move down
            currentPiece.movePiece(Direction.down);
          }

          // Game over check should happen after a new piece is created and if it immediately collides
          if (gameOver) {
            timer.cancel(); // Stop the timer if game is over
            showGameOverDialog();
          }
        });
      });
    }
  }

  // Pause/Resume game logic
  void togglePause({bool forcePause = false, bool forceResume = false}) {
    setState(() {
      if (forcePause) {
        _isPaused = true;
      } else if (forceResume) {
        _isPaused = false;
      } else {
        _isPaused = !_isPaused; // Toggle if not forced
      }

      Duration currentFrameRate = const Duration(milliseconds: 400); // Maintain speed
      if (_isPaused) {
        gameTimer?.cancel(); // Stop timer when paused
      } else {
        gameLoop(currentFrameRate); // Resume timer when unpaused
      }
    });
  }

  // Restart game logic
  void restartGame() {
    setState(() {
      gameTimer?.cancel(); // Ensure any active timer is stopped
      startGame(); // Call startGame to reset and begin a new game
    });
  }

  // NEW: Method to show Pause Dialog
  void _showPauseDialog() {
    togglePause(forcePause: true); // Pause the game immediately

    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Paused'),
          content: const Text('What would you like to do?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Resume'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                togglePause(forceResume: true); // Resume game
              },
            ),
            TextButton(
              child: const Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                restartGame(); // Restart game
              },
            ),
          ],
        );
      },
    );
  }

  // NEW: Method to show Restart Confirmation Dialog
  void _showRestartConfirmationDialog() {
    // Temporarily pause the game if it's not already paused before showing dialog
    bool wasRunningBeforeDialog = !_isPaused && !gameOver;
    if (wasRunningBeforeDialog) {
      togglePause(forcePause: true);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Game?'),
          content: const Text('Are you sure you want to restart? Your current score will be lost.'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // If game was running before dialog, resume it
                if (wasRunningBeforeDialog) {
                  togglePause(forceResume: true);
                }
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                restartGame(); // Restart game
              },
            ),
          ],
        );
      },
    );
  }


  bool checkCollision(Direction direction, List<int> piecePosition) {
    for (int i = 0; i < piecePosition.length; i++) {
      int row = (piecePosition[i] / rowLength).floor();
      int col = piecePosition[i] % rowLength;

      // Adjust row and col based on the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // 1. Check if piece is out of bounds (hitting walls or bottom)
      if (col < 0 || col >= rowLength || row >= colLength) {
        return true; // Collision with boundary
      }

      // 2. Check if the new position is already occupied by another landed block
      // Important: Only check if the target cell is occupied AND it's NOT part of the current piece's original position.
      if (row >= 0 && gameBoard[row][col] != null && !piecePosition.contains(row * rowLength + col)) {
        return true; // Collision with existing block
      }
    }
    return false; // No collision
  }

  void landPiece() {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;
      if (row >= 0 && col >= 0) { // Ensure within board bounds for landing
        gameBoard[row][col] = currentPiece.type;
      }
    }

    clearLines(); // Check for and clear completed lines
    createNewPiece(); // Generate a new piece

    // Check if new piece immediately collides (game over condition)
    if (checkCollision(Direction.down, currentPiece.position)) {
      gameOver = true;
      gameTimer?.cancel(); // Stop timer immediately on game over
    }
  }

  void createNewPiece() {
    Random rand = Random();
    Tetromino randType = Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randType);
    currentPiece.initializePiece(); // This should place it at the top

    // Check if the initial position of the new piece causes immediate collision
    // This is essentially the game over condition
    if (checkCollision(Direction.down, currentPiece.position)) {
      gameOver = true;
    }
  }

  // Move controls (now only active if not paused and not game over)
  void moveLeft() {
    if (_isPaused || gameOver) return;
    if (!checkCollision(Direction.left, currentPiece.position)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (_isPaused || gameOver) return;
    if (!checkCollision(Direction.right, currentPiece.position)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece() {
    if (_isPaused || gameOver) return;
    currentPiece.rotatePiece();
    if (checkCollision(Direction.left, currentPiece.position) ||
        checkCollision(Direction.right, currentPiece.position) ||
        checkCollision(Direction.down, currentPiece.position)) {
      currentPiece.rotatePiece();
      currentPiece.rotatePiece();
      currentPiece.rotatePiece();
    }
    setState(() {});
  }

  // Clear lines logic
  void clearLines() {
    for (int r = colLength - 1; r >= 0; r--) {
      bool rowIsFull = true;
      for (int c = 0; c < rowLength; c++) {
        if (gameBoard[r][c] == null) {
          rowIsFull = false;
          break;
        }
      }

      if (rowIsFull) {
        // Shift rows down
        for (int i = r; i > 0; i--) {
          for (int c = 0; c < rowLength; c++) {
            gameBoard[i][c] = gameBoard[i - 1][c];
          }
        }
        // Clear the top row
        for (int c = 0; c < rowLength; c++) {
          gameBoard[0][c] = null;
        }
        currentScore += 100; // Increase score for clearing a line
      }
    }
  }

  void showGameOverDialog() {
    // Ensure the dialog is only shown once and game is indeed over
    // if (gameOver && Navigator.of(context).canPop()) { // Check canPop to avoid showing multiple dialogs
    //   Navigator.pop(context); // Pop existing dialog if any - this might cause issues if no dialog is present
    // }

    // Use a flag or check if dialog is already open to prevent multiple dialogs
    // For simplicity, removing the pop check here and relying on barrierDismissible: false
    // and only calling it when `gameOver` is true and not already showing
    if (!gameOver) return; // Only show if game is actually over
    gameTimer?.cancel(); // Ensure timer is stopped

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $currentScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              startGame(); // Start a new game
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Using standard AppBar for actions
        backgroundColor: Colors.black,
        title: const Text(
          'Tetris',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            onPressed: gameOver ? null : _showPauseDialog, // Disable if game over
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _showRestartConfirmationDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Game Board (wrapped in Stack for pause overlay)
          Expanded(
            child: Stack(
              children: [
                GridView.builder(
                  itemCount: rowLength * colLength,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowLength,
                  ),
                  itemBuilder: (context, index) {
                    int row = (index / rowLength).floor();
                    int col = index % rowLength;

                    // Current piece pixels
                    if (currentPiece.position.contains(index)) {
                      return Pixel(
                        color: tetrominoColors[currentPiece.type],
                        child: index,
                      );
                    }
                    // Landed piece pixels
                    else if (gameBoard[row][col] != null) {
                      return Pixel(
                        color: tetrominoColors[gameBoard[row][col]],
                        child: index,
                      );
                    }
                    // Empty pixels
                    else {
                      return Pixel(
                        color: Colors.grey[900],
                        child: index,
                      );
                    }
                  },
                ),
                // NEW: Pause Overlay
                if (_isPaused && !gameOver)
                  Container(
                    color: Colors.black54, // Semi-transparent overlay
                    child: const Center(
                      child: Text(
                        'PAUSED',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Score display
          Text(
            'Score: $currentScore',
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          // Controls (without Pause/Restart buttons)
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: moveLeft,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.arrow_back_ios_new),
                ),
                FloatingActionButton(
                  onPressed: rotatePiece,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.rotate_right),
                ),
                FloatingActionButton(
                  onPressed: moveRight,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.arrow_forward_ios),
                ),
                FloatingActionButton(
                  onPressed: () {
                    if (_isPaused || gameOver) return;
                    while (!checkCollision(Direction.down, currentPiece.position)) {
                      currentPiece.movePiece(Direction.down);
                    }
                    setState(() {
                      landPiece();
                    });
                  },
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.arrow_downward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}