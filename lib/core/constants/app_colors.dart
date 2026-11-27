import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color seedColor    = Color(0xFF2E7D32); // Forest Green
  static const Color coinColor    = Color(0xFFFFC107); // Amber
  static const Color deadTree     = Color(0xFF795548); // Brown
  static const Color streakOrange = Color(0xFFFF6D00); // Streak fire

  // Tag warna
  static const Map<String, Color> tagColors = {
    'belajar':   Color(0xFF1565C0),
    'tugas':     Color(0xFF6A1B9A),
    'membaca':   Color(0xFF00695C),
    'olahraga':  Color(0xFFE65100),
    'freelance': Color(0xFF37474F),
    'lainnya':   Color(0xFF757575),
  };

  // Tree leaf colors
  static const Map<String, Color> treeLeafColors = {
    'oak':     Color(0xFF388E3C),
    'cherry':  Color(0xFFE91E63),
    'pine':    Color(0xFF1B5E20),
    'bamboo':  Color(0xFF558B2F),
    'cactus':  Color(0xFF33691E),
  };

  // Theme background gradients
  static const Map<String, List<Color>> themeGradients = {
    'default':  [Color(0xFFE8F5E9), Color(0xFFA5D6A7)],
    'desert':   [Color(0xFFFFF8E1), Color(0xFFFFCC80)],
    'snow':     [Color(0xFFE3F2FD), Color(0xFFB3E5FC)],
    'tropical': [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
  };
}
