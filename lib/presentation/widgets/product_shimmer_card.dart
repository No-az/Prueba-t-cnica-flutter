import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductShimmerCard extends StatelessWidget {
  const ProductShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Container(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 80, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 16, width: 60, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductShimmerGrid extends StatelessWidget {
  final int count;

  const ProductShimmerGrid({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) => const ProductShimmerCard(),
        childCount: count,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
    );
  }
}
