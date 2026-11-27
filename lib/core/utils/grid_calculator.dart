import 'package:flutter/material.dart';

class GridCalculator {
  GridCalculator._();

  static const int gridSize = 20; // 20×20 grid

  /// Ambil koordinat berikutnya (spiral dari pusat)
  static (int x, int y) nextPosition(List<(int, int)> occupied) {
    const center = (10, 10);
    for (int ring = 0; ring < gridSize ~/ 2; ring++) {
      for (int dx = -ring; dx <= ring; dx++) {
        for (int dy = -ring; dy <= ring; dy++) {
          if (dx.abs() != ring && dy.abs() != ring) continue;
          final pos = (center.$1 + dx, center.$2 + dy);
          final x = pos.$1;
          final y = pos.$2;
          if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) continue;
          if (!occupied.contains(pos)) return pos;
        }
      }
    }
    return (0, 0);
  }

  /// Grid (x,y) → pixel isometrik relatif terhadap pusat canvas
  static Offset toIsometric(int x, int y, double tileW, double tileH) {
    final screenX = (x - y) * tileW / 2;
    final screenY = (x + y) * tileH / 2;
    return Offset(screenX, screenY);
  }
}
