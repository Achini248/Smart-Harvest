import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: AppColors.primaryGreen),
                const SizedBox(width: 12),
                const Expanded(child: Text('Sri Lanka Agriculture Map', style: TextStyle(fontWeight: FontWeight.w700))),
                IconButton(icon: Icon(Icons.layers), onPressed: () {}),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: AppColors.textSecondary),
                  const SizedBox(height: 24),
                  const Text('Interactive Map', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  const Text(
                    'District-wise surplus/shortage\nPinch to zoom, tap for details',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
