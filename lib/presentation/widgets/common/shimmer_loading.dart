import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerLoading.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
  }) : shapeBorder = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        );

  const ShimmerLoading.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[400]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class ShimmerProfileSkeleton extends StatelessWidget {
  const ShimmerProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShimmerLoading.circular(width: 100, height: 100),
        const SizedBox(height: 24),
        const ShimmerLoading.rectangular(height: 24, width: 200),
        const SizedBox(height: 8),
        const ShimmerLoading.rectangular(height: 16, width: 120),
        const SizedBox(height: 32),
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: const ShimmerLoading.rectangular(height: 64),
        )),
      ],
    );
  }
}

class ShimmerStatsSkeleton extends StatelessWidget {
  const ShimmerStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: const ShimmerLoading.rectangular(height: 100)),
        const SizedBox(width: 16),
        Expanded(child: const ShimmerLoading.rectangular(height: 100)),
      ],
    );
  }
}
