import 'package:flutter/material.dart';
import 'package:tetris/values.dart';


class Piece {

  Tetromino type;

  Piece({required this.type});


  List<int> position = [];


  void  initializePiece() {
    switch (type) {
      case Tetromino.L :
        position =[
          -26,-16,-6,-5
        ];
        break;
      case Tetromino.J :
        position =[
          -25,-15,-5,-6
        ];
        break;
      case Tetromino.I :
        position =[
          -4,-5,-6,-7
        ];
        break;
      case Tetromino.O :
        position =[
          -15,-16,
          -5,-6
        ];
        break;
      case Tetromino.S :
        position =[
          -15,-14,-6,-5
        ];
        break;
      case Tetromino.T :
        position =[
          -26,-16,-6,-15
        ];
        break;
      case Tetromino.Z :
        position =[
          -17,-16,-6,-5
        ];
        break;
      // default:
    }
  }


  void movePiece(Direction direction){
    switch (direction) {
      case Direction.down:
        for(int i =0; i< position.length; i++) {
          position[i] += rowLength;
        } break;
      case Direction.left:
        for(int i =0; i< position.length; i++) {
          position[i] -= 1;
        } break;
      case Direction.right:
        for(int i =0; i< position.length; i++) {
          position[i] += 1;
        } break;

    }
  }

  void rotatePiece() {
    // This is a complex part of Tetris. You'd need rotation logic
    // specific to each piece type and its center of rotation.
    // For simplicity, a basic example (might not be perfect for all pieces)
    // You would typically have rotation matrices or predefined rotation states.
    // Example: For a simple piece like 'O', rotation does nothing.
    // For 'I' it alternates horizontal/vertical.
    // For 'L', 'J', 'T', 'S', 'Z' it's more complex.
  }
}
