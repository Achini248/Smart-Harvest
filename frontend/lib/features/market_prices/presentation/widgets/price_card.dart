// lib/features/market_prices/presentation/widgets/price_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/price.dart';

class PriceCard extends StatelessWidget {
  final PriceEntity price;
  final VoidCallback? onTap;

  const PriceCard({super.key, required this.price, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Crop icon avatar
                  Container(
                    width: 46, height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6E3), shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _cropEmoji(price.cropName),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.cropName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${price.marketName} · ${price.district}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF757575)),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  _StatusBadge(price: price),
                ],
              ),
              const SizedBox(height: 12),
              // Price row
              Row(
                children: [
                  Expanded(
                    child: _PriceStat(
                      label: 'Avg Price',
                      value: price.formattedAvgPrice,
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _PriceStat(
                      label: 'Min',
                      value: 'Rs. ${price.minPrice.toStringAsFixed(0)}',
                    ),
                  ),
                  Expanded(
                    child: _PriceStat(
                      label: 'Max',
                      value: 'Rs. ${price.maxPrice.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
              if (price.predictedPrice != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: price.isTrendingUp
                        ? const Color(0xFFDCF5E3)
                        : const Color(0xFFFFEAE0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        price.isTrendingUp
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: price.isTrendingUp
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFD84315),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI Forecast: ${price.formattedPredictedPrice}  ${price.trendLabel}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: price.isTrendingUp
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFD84315),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _cropEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('tomato'))  return '🍅';
    if (n.contains('carrot'))  return '🥕';
    if (n.contains('onion'))   return '🧅';
    if (n.contains('corn'))    return '🌽';
    if (n.contains('banana'))  return '🍌';
    if (n.contains('mango'))   return '🥭';
    if (n.contains('potato'))  return '🥔';
    if (n.contains('rice'))    return '🌾';
    if (n.contains('pepper'))  return '🌶️';
    return '🌿';
  }
}

class _StatusBadge extends StatelessWidget {
  final PriceEntity price;
  const _StatusBadge({required this.price});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    if (price.isSurplus) {
      bg = const Color(0xFFDCF5E3); fg = const Color(0xFF2E7D32);
    } else if (price.isShortage) {
      bg = const Color(0xFFFFEAE0); fg = const Color(0xFFD84315);
    } else {
      bg = const Color(0xFFE3F2FD); fg = const Color(0xFF1565C0);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        price.statusLabel,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _PriceStat extends StatelessWidget {
  final String label, value;
  final TextStyle? valueStyle;
  const _PriceStat({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF757575))),
        const SizedBox(height: 2),
        Text(value,
            style: valueStyle ??
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
