import 'package:flutter/material.dart';
import 'package:tetris/values.dart';


class Piece {

  Tetromino type;

  Piece({required this.type});

  int rotationState = 0; // 0, 1, 2, 3 for 4 possible rotations

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

  // COMPLETE THIS METHOD FOR ROTATION
  void rotatePiece() {
    // Store current position to revert if collision occurs after rotation
    List<int> originalPosition = List.from(position);

    // Calculate the new rotation state
    rotationState = (rotationState + 1) % 4; // Cycle through 0, 1, 2, 3

    // Apply rotation based on piece type and current rotation state
    switch (type) {
      case Tetromino.L:
        switch (rotationState) {
          case 0: // Original L shape
            position = [
              originalPosition[3] - rowLength * 2,
              originalPosition[3] - rowLength,
              originalPosition[3] - 1,
              originalPosition[3]
            ];
            break;
          case 1: // Rotated 90 deg clockwise
            position = [
              originalPosition[3] - rowLength,
              originalPosition[3],
              originalPosition[3] + 1,
              originalPosition[3] + rowLength + 1
            ];
            break;
          case 2: // Rotated 180 deg clockwise
            position = [
              originalPosition[3],
              originalPosition[3] + 1,
              originalPosition[3] + rowLength,
              originalPosition[3] + rowLength * 2
            ];
            break;
          case 3: // Rotated 270 deg clockwise
            position = [
              originalPosition[3] - rowLength - 1,
              originalPosition[3] - 1,
              originalPosition[3],
              originalPosition[3] + rowLength
            ];
            break;
        }
        break;

      case Tetromino.J:
        switch (rotationState) {
          case 0:
            position = [
              originalPosition[1] - rowLength * 2,
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + 1,
            ];
            break;
          case 1:
            position = [
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + 1,
              originalPosition[1] + rowLength -1,
            ];
            break;
          case 2:
            position = [
              originalPosition[1] - 1,
              originalPosition[1],
              originalPosition[1] + rowLength,
              originalPosition[1] + rowLength * 2,
            ];
            break;
          case 3:
            position = [
              originalPosition[1] - rowLength + 1,
              originalPosition[1] - 1,
              originalPosition[1],
              originalPosition[1] + rowLength,
            ];
            break;
        }
        break;

      case Tetromino.I:
      // 'I' piece usually rotates around its second or third block (center)
        switch (rotationState) {
          case 0: // Horizontal
            position = [
              originalPosition[1] - rowLength * 2,
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + rowLength,
            ];
            break;
          case 1: // Vertical
            position = [
              originalPosition[2] - 2,
              originalPosition[2] - 1,
              originalPosition[2],
              originalPosition[2] + 1,
            ];
            break;
          case 2: // Horizontal again
            position = [
              originalPosition[1] - rowLength * 2,
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + rowLength,
            ];
            break;
          case 3: // Vertical again
            position = [
              originalPosition[2] - 2,
              originalPosition[2] - 1,
              originalPosition[2],
              originalPosition[2] + 1,
            ];
            break;
        }
        break;

      case Tetromino.O:
      // O-piece does not rotate, its shape is always the same.
      // So, position remains original, and rotationState will simply cycle without visual change.
        position = List.from(originalPosition); // No actual change in position
        break;

      case Tetromino.S:
        switch (rotationState) {
          case 0:
            position = [
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + 1,
              originalPosition[1] + rowLength + 1,
            ];
            break;
          case 1:
            position = [
              originalPosition[2] - 1,
              originalPosition[2],
              originalPosition[2] + rowLength,
              originalPosition[2] + rowLength + 1,
            ];
            break;
          case 2:
            position = [
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + 1,
              originalPosition[1] + rowLength + 1,
            ];
            break;
          case 3:
            position = [
              originalPosition[2] - 1,
              originalPosition[2],
              originalPosition[2] + rowLength,
              originalPosition[2] + rowLength + 1,
            ];
            break;
        }
        break;

      case Tetromino.Z:
        switch (rotationState) {
          case 0:
            position = [
              originalPosition[1] - rowLength * 2,
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + 1,
            ];
            break;
          case 1:
            position = [
              originalPosition[2] - rowLength - 1,
              originalPosition[2],
              originalPosition[2] + 1,
              originalPosition[2] + rowLength,
            ];
            break;
          case 2:
            position = [
              originalPosition[1] - rowLength * 2,
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + 1,
            ];
            break;
          case 3:
            position = [
              originalPosition[2] - rowLength - 1,
              originalPosition[2],
              originalPosition[2] + 1,
              originalPosition[2] + rowLength,
            ];
            break;
        }
        break;

      case Tetromino.T:
        switch (rotationState) {
          case 0:
            position = [
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + 1,
              originalPosition[1] + rowLength,
            ];
            break;
          case 1:
            position = [
              originalPosition[1] - rowLength,
              originalPosition[1] - 1,
              originalPosition[1],
              originalPosition[1] + rowLength,
            ];
            break;
          case 2:
            position = [
              originalPosition[1] - 1,
              originalPosition[1],
              originalPosition[1] + 1,
              originalPosition[1] + rowLength,
            ];
            break;
          case 3:
            position = [
              originalPosition[1] - rowLength,
              originalPosition[1],
              originalPosition[1] + 1,
              originalPosition[1] + rowLength,
            ]; // Adjust for 270 degree rotation
            break;
        }
        break;
    }
  }
}
