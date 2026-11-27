import 'package:flutter/material.dart';
import '../../data/models/tag_model.dart';

class TagChip extends StatelessWidget {
  final TagModel tag;
  final bool isSelected;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(tag.colorHex);
    return FilterChip(
      avatar: Text(tag.icon, style: const TextStyle(fontSize: 14)),
      label: Text(tag.nameId),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      side: isSelected ? BorderSide(color: color, width: 1.5) : null,
    );
  }

  static Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
