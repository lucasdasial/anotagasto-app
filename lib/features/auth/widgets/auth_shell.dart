import 'dart:math';

import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AuthHeader(),
                      const SizedBox(height: 40),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Background
// ---------------------------------------------------------------------------

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TriangleBackgroundPainter(color: AppColors.secondary),
    );
  }
}

class _TriangleBackgroundPainter extends CustomPainter {
  const _TriangleBackgroundPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Triângulo grande — canto superior direito
    paint.color = color.withValues(alpha: 0.3);
    canvas.drawPath(
      _roundedTriangle(
        center: Offset(size.width * 0.88, size.height * 0.12),
        circumradius: size.width * 0.42,
        rotation: -0.4,
        cornerRadius: 28,
      ),
      paint,
    );

    // Triângulo médio — canto inferior esquerdo
    paint.color = color.withValues(alpha: 0.22);
    canvas.drawPath(
      _roundedTriangle(
        center: Offset(size.width * 0.08, size.height * 0.82),
        circumradius: size.width * 0.32,
        rotation: 1.1,
        cornerRadius: 22,
      ),
      paint,
    );

    // Triângulo pequeno — centro inferior
    paint.color = color.withValues(alpha: 0.36);
    canvas.drawPath(
      _roundedTriangle(
        center: Offset(size.width * 0.62, size.height * 0.90),
        circumradius: size.width * 0.22,
        rotation: 0.7,
        cornerRadius: 16,
      ),
      paint,
    );
  }

  /// Gera um Path de triângulo equilátero com cantos arredondados.
  Path _roundedTriangle({
    required Offset center,
    required double circumradius,
    required double rotation,
    required double cornerRadius,
  }) {
    const sides = 3;
    final angle = 2 * pi / sides;

    final vertices = List.generate(sides, (i) {
      final a = rotation + i * angle;
      return Offset(
        center.dx + circumradius * cos(a),
        center.dy + circumradius * sin(a),
      );
    });

    return _buildRoundedPolygon(vertices, cornerRadius);
  }

  Path _buildRoundedPolygon(List<Offset> vertices, double cornerRadius) {
    final path = Path();
    final n = vertices.length;

    for (int i = 0; i < n; i++) {
      final prev = vertices[(i - 1 + n) % n];
      final curr = vertices[i];
      final next = vertices[(i + 1) % n];

      final toPrev = prev - curr;
      final toNext = next - curr;
      final lenPrev = toPrev.distance;
      final lenNext = toNext.distance;

      final r = cornerRadius.clamp(0.0, min(lenPrev, lenNext) / 2);
      final p1 =
          curr + Offset(toPrev.dx / lenPrev * r, toPrev.dy / lenPrev * r);
      final p2 =
          curr + Offset(toNext.dx / lenNext * r, toNext.dy / lenNext * r);

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, p2.dx, p2.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _TriangleBackgroundPainter old) =>
      old.color != color;
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.edit_note,
            color: AppColors.onAccent,
            size: 28,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AnotaGasto', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 4),
            const Text(
              'Controle seus gastos com simplicidade',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
