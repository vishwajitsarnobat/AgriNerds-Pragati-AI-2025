import 'package:flutter/material.dart';
import '../models/crop.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback onTap;

  const CropCard({
    super.key,
    required this.crop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                      crop.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                crop.description,
                style: Theme.of(context).textTheme.bodyMedium,
                        ),
              const SizedBox(height: 8),
                        Text(
                'Created: ${crop.createdAt.toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 