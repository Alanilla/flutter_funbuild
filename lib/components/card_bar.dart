import 'package:flutter/material.dart';

class CardBar extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onSuperLike;
  final VoidCallback onLike;

  const CardBar({
    super.key,
    required this.onPass,
    required this.onSuperLike,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: onPass,
          backgroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.close, color: Colors.red, size: 30),
        ),
        const SizedBox(width: 30),
        FloatingActionButton(
          onPressed: onSuperLike,
          backgroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.star, color: Colors.blue, size: 30),
        ),
        const SizedBox(width: 30),
        FloatingActionButton(
          onPressed: onLike,
          backgroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.favorite, color: Colors.green, size: 30),
        ),
      ],
    );
  }
}
