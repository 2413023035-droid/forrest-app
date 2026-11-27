import 'package:flutter/material.dart';

/// Widget pohon yang digambar 100% via CustomPainter
/// Tidak memerlukan file gambar eksternal
class TreeWidget extends StatelessWidget {
  final String treeTypeId;      // 'oak', 'cherry', 'pine', 'bamboo', 'cactus'
  final double growthProgress;  // 0.0 → 1.0
  final bool isDead;
  final double size;

  const TreeWidget({
    super.key,
    required this.treeTypeId,
    this.growthProgress = 1.0,
    this.isDead = false,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TreePainter(
          treeType: treeTypeId,
          progress: growthProgress.clamp(0.0, 1.0),
          isDead: isDead,
        ),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final String treeType;
  final double progress;
  final bool isDead;

  _TreePainter({
    required this.treeType,
    required this.progress,
    required this.isDead,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.05) return;

    final trunkPaint = Paint()
      ..color = isDead ? const Color(0xFF6D4C41) : const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;

    final leafPaint = Paint()
      ..color = isDead ? const Color(0xFF8D6E63) : _leafColor()
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final trunkH = size.height * 0.35 * progress;
    final trunkW = size.width * 0.1;

    // --- Batang ---
    if (progress > 0.1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, size.height - trunkH / 2),
            width: trunkW,
            height: trunkH,
          ),
          const Radius.circular(4),
        ),
        trunkPaint,
      );
    }

    if (progress < 0.2) return;

    // --- Daun (tergantung jenis) ---
    final leafR = size.width * 0.38 * progress;
    final leafY = size.height - trunkH - leafR * 0.7;

    switch (treeType) {
      case 'pine':
        _drawPine(canvas, cx, leafY, leafR, leafPaint);
      case 'bamboo':
        _drawBamboo(canvas, size, leafPaint, trunkPaint);
      case 'cactus':
        _drawCactus(canvas, size, cx, leafPaint);
      case 'cherry':
        _drawCherry(canvas, cx, leafY, leafR, leafPaint);
      default: // oak
        _drawOak(canvas, cx, leafY, leafR, leafPaint);
    }
  }

  void _drawOak(Canvas c, double cx, double leafY, double r, Paint p) {
    c.drawCircle(Offset(cx, leafY), r, p);
    // Variasi kecil agar terlihat lebih organik
    c.drawCircle(Offset(cx - r * 0.4, leafY + r * 0.3), r * 0.6, p);
    c.drawCircle(Offset(cx + r * 0.4, leafY + r * 0.3), r * 0.6, p);
  }

  void _drawCherry(Canvas c, double cx, double leafY, double r, Paint p) {
    c.drawCircle(Offset(cx, leafY), r * 0.75, p);
    c.drawCircle(Offset(cx - r * 0.5, leafY + r * 0.25), r * 0.55, p);
    c.drawCircle(Offset(cx + r * 0.5, leafY + r * 0.25), r * 0.55, p);
    // Bunga kecil (putih)
    final blossom = Paint()..color = Colors.white.withOpacity(0.4);
    c.drawCircle(Offset(cx - r * 0.1, leafY - r * 0.2), r * 0.15, blossom);
    c.drawCircle(Offset(cx + r * 0.3, leafY + r * 0.1), r * 0.12, blossom);
  }

  void _drawPine(Canvas c, double cx, double leafY, double r, Paint p) {
    for (int i = 0; i < 3; i++) {
      final factor = 1.0 - i * 0.22;
      final yOff   = i * r * 0.35;
      final path   = Path()
        ..moveTo(cx, leafY - r * factor + yOff)
        ..lineTo(cx - r * factor, leafY + r * 0.25 + yOff)
        ..lineTo(cx + r * factor, leafY + r * 0.25 + yOff)
        ..close();
      c.drawPath(path, p);
    }
  }

  void _drawBamboo(Canvas c, Size size, Paint leafP, Paint trunkP) {
    final cx = size.width / 2;
    final segH = size.height * 0.18 * progress;
    // Batang bambu tersegmen
    for (int i = 0; i < 4; i++) {
      final y = size.height - i * segH - segH / 2;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, y),
            width: size.width * 0.1,
            height: segH * 0.9,
          ),
          const Radius.circular(2),
        ),
        trunkP,
      );
      // Simpul
      c.drawRect(
        Rect.fromCenter(
          center: Offset(cx, y - segH / 2),
          width: size.width * 0.14,
          height: 3,
        ),
        Paint()..color = const Color(0xFF4E342E),
      );
    }
    // Daun di puncak
    c.drawOval(
      Rect.fromCenter(
        center: Offset(cx + size.width * 0.2, size.height - 4 * segH),
        width: size.width * 0.35 * progress,
        height: size.height * 0.12 * progress,
      ),
      leafP,
    );
    c.drawOval(
      Rect.fromCenter(
        center: Offset(cx - size.width * 0.2, size.height - 4 * segH),
        width: size.width * 0.35 * progress,
        height: size.height * 0.12 * progress,
      ),
      leafP,
    );
  }

  void _drawCactus(Canvas c, Size size, double cx, Paint p) {
    final h = size.height * 0.6 * progress;
    final w = size.width * 0.15;
    // Batang utama
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, size.height - h / 2),
          width: w,
          height: h,
        ),
        const Radius.circular(6),
      ),
      p,
    );
    if (progress > 0.5) {
      // Lengan kiri
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx - size.width * 0.2, size.height - h * 0.5),
            width: w * 0.8,
            height: h * 0.4,
          ),
          const Radius.circular(6),
        ),
        p,
      );
      // Lengan kanan
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + size.width * 0.2, size.height - h * 0.6),
            width: w * 0.8,
            height: h * 0.35,
          ),
          const Radius.circular(6),
        ),
        p,
      );
    }
  }

  Color _leafColor() => switch (treeType) {
    'cherry'  => const Color(0xFFE91E63),
    'pine'    => const Color(0xFF1B5E20),
    'bamboo'  => const Color(0xFF558B2F),
    'cactus'  => const Color(0xFF33691E),
    _         => const Color(0xFF388E3C),
  };

  @override
  bool shouldRepaint(_TreePainter old) =>
      old.progress != progress || old.isDead != isDead || old.treeType != treeType;
}
