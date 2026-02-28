// lib/features/market_prices/presentation/widgets/price_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/price.dart';

class PriceCard extends StatelessWidget {
  final Price price;
  final VoidCallback? onTap;

  const PriceCard({
    super.key,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final change = price.changePercent;
    final bool up = change > 0;
    final bool down = change < 0;

    Color badgeColor;
    if (up) {
      badgeColor = const Color(0xFFDCF5E3);
    } else if (down) {
      badgeColor = const Color(0xFFFFEAE0);
    } else {
      badgeColor = const Color(0xFFE4E4E4);
    }

    Color textColor;
    if (up) {
      textColor = const Color(0xFF2E7D32);
    } else if (down) {
      textColor = const Color(0xFFD84315);
    } else {
      textColor = Colors.grey.shade700;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6E3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_florist_outlined,
                  color: Color(0xFF7BA53D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${price.pricePerUnit.toStringAsFixed(0)} / ${price.unit}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (up)
                      const Icon(Icons.arrow_drop_up,
                          size: 18, color: Color(0xFF2E7D32)),
                    if (down)
                      const Icon(Icons.arrow_drop_down,
                          size: 18, color: Color(0xFFD84315)),
                    if (!up && !down)
                      Icon(Icons.remove,
                          size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 2),
                    Text(
                      change == 0
                          ? '0%'
                          : '${up ? '+' : ''}${change.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//
