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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: AppColors.primaryGreen),
                const SizedBox(width: 12),
                const Expanded(child: Text('Sri Lanka Agriculture Map', style: TextStyle(fontWeight: FontWeight.w700))),
                IconButton(icon: const Icon(Icons.layers), onPressed: () {}),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: AppColors.textSecondary),
                  SizedBox(height: 24),
                  Text('Interactive Map', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  SizedBox(height: 16),
                  Text(
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
