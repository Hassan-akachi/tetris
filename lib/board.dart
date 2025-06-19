// import 'dart:async';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:tetris/piece.dart';
// import 'package:tetris/pixel.dart';
// import 'package:tetris/values.dart';
//
// List<List<Tetromino?>> gameBoard = List.generate(
//   colLength,
//       (i) =>
//       List.generate(rowLength,
//               (j) => null),
// );
//
// class GameBoard extends StatefulWidget {
//   const GameBoard({super.key});
//
//   @override
//   State<GameBoard> createState() => _GameBoardState();
// }
//
// class _GameBoardState extends State<GameBoard> {
//   Piece currentPiece = Piece(type: Tetromino.Z);
//
//   void startGame() {
//     currentPiece.initializePiece();
//
//     Duration frameRate = const Duration(milliseconds: 800);
//     gameLoop(frameRate);
//   }
//
//   void gameLoop(Duration frameRate) {
//     Timer.periodic(frameRate, (timer) {
//       setState(() {
//         checkLanding();
//
//         currentPiece.movePiece(Direction.down);
//       });
//     });
//   }
//
//   bool checkCollision(Direction direction) {
//     for (int i = 0; i < currentPiece.position.length; i++) {
//       int row = (currentPiece.position[i] / rowLength).floor();
//       int col = currentPiece.position[i] % rowLength;
//
//       if (direction == Direction.left) {
//         col -= 1;
//       } else if (direction == Direction.right) {
//         col += 1;
//       } else if (direction == Direction.down) {
//         row += 1;
//       }
//
//       // Out of bounds
//       if (row >= colLength || col < 0 || col >= rowLength || row < 0) {
//         return true;
//       }
//
//       // Check if the space is already occupied
//       // if (gameBoard[row][col] != null) {
//       //   return true;
//       // }
//     }
//
//     return false;
//   }
//
//   void checkLanding() {
//     if (checkCollision(Direction.down)) {
//       for (int i = 0; i < currentPiece.position.length; i++) {
//         int row = (currentPiece.position[i] / rowLength).floor();
//         int col = currentPiece.position[i] % rowLength;
//         if (row >= 0 && col >= 0) {
//           gameBoard[row][col] = currentPiece.type;
//         }
//       }
//       createNewPiece();
//     }
//   }
//
//   void createNewPiece() {
//     Random rand = Random();
//
//     Tetromino randType = Tetromino.values[rand.nextInt(
//         Tetromino.values.length)];
//     currentPiece = Piece(type: randType);
//     currentPiece.initializePiece();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     startGame();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GridView.builder(
//         itemCount: rowLength * colLength,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: rowLength,
//         ),
//         itemBuilder: (context, index) {
//           int row = (index / rowLength).floor();
//           int col = index % rowLength;
//
//           if (currentPiece.position.contains(index)) {
//             return Pixel(
//               color: Colors.yellow,
//               child: index
//             );
//           }
//            if (gameBoard[row][col] != null) {
//             return Pixel(color: Colors.pink, child: ''
//             );
//           }
//
//
//           else {
//             return Pixel(
//               color: Colors.grey[900],
//               child: index
//             );
//           }
//         },
//       ),
//     );
//   }
// }


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

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    createNewPiece(); // Create the first piece
    gameOver = false;
    currentScore = 0;

    Duration frameRate = const Duration(milliseconds: 400); // Start with a reasonable speed
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    gameTimer?.cancel(); // Cancel any existing timer before starting a new one
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
          timer.cancel();
          showGameOverDialog();
        }
      });
    });
  }

  // Check collision function
  // Returns true if collision, false if no collision
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

  // Move controls
  void moveLeft() {
    if (!checkCollision(Direction.left, currentPiece.position)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right, currentPiece.position)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece() {
    currentPiece.rotatePiece(); // Rotate the piece's position
    // After rotating, check for collision. If it collides, undo the rotation
    if (checkCollision(Direction.left, currentPiece.position) ||
        checkCollision(Direction.right, currentPiece.position) ||
        checkCollision(Direction.down, currentPiece.position)) {
      currentPiece.rotatePiece(); // Rotate back if collision (assuming 2 rotations for current piece types)
      currentPiece.rotatePiece();
      currentPiece.rotatePiece(); // Rotate 3 times to get back if more than 2 states
    }
    setState(() {}); // Rebuild UI after rotation attempt
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $currentScore'),
        actions: [
          TextButton(
            onPressed: () {
              // Reset board
              gameBoard = List.generate(
                colLength,
                    (i) => List.generate(rowLength, (j) => null),
              );
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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
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
                    color: tetrominoColors[currentPiece.type], // Use actual color
                    child: index, // Child should be a Widget, not an index
                  );
                }
                // Landed piece pixels
                else if (gameBoard[row][col] != null) {
                  return Pixel(
                    color: tetrominoColors[gameBoard[row][col]], // Use actual color
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
          ),
          Text(
            'Score: $currentScore',
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
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
                    // Instantly drop the piece
                    while (!checkCollision(Direction.down, currentPiece.position)) {
                      currentPiece.movePiece(Direction.down);
                    }
                    setState(() {
                      landPiece(); // Land it after dropping
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

