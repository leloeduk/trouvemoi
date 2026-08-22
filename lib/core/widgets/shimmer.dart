import 'package:flutter/material.dart';

/// Effet de chargement "shimmer" léger, sans dépendance externe.
///
/// Enveloppe un squelette de widgets et fait balayer un reflet lumineux
/// dessus tant que les données ne sont pas chargées.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + t * 2, 0),
              end: Alignment(1.0 + t * 2, 0),
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF8FAFC),
                Color(0xFFE2E8F0),
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

const Color _skeletonBase = Color(0xFFE2E8F0);

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _skeletonBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Squelette d'une carte de document pendant le chargement.
class DocumentCardSkeleton extends StatelessWidget {
  const DocumentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 180, color: _skeletonBase),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 220, height: 18),
                  const SizedBox(height: 10),
                  const SkeletonBox(height: 14),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 140, height: 14),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  const SkeletonBox(width: 120, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Liste de squelettes de cartes de document.
class DocumentListSkeleton extends StatelessWidget {
  final int count;

  const DocumentListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) const DocumentCardSkeleton(),
      ],
    );
  }
}