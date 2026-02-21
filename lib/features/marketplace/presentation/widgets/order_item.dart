import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order.dart';

class OrderItem extends StatelessWidget {
  final OrderEntity order;
  final bool isSeller;
  final void Function(String status)? onStatusUpdate;

  const OrderItem({
    super.key,
    required this.order,
    this.isSeller = false,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final status = OrderStatusExtension.fromString(order.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 8),

            // ── Details ───────────────────────────────────────────────
            _Row(
              label: isSeller ? 'Buyer' : 'Seller',
              value: isSeller ? order.buyerName : order.sellerName,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 4),
            _Row(
              label: 'Quantity',
              value: '${order.quantity} ${order.unit}',
              icon: Icons.straighten,
            ),
            const SizedBox(height: 4),
            _Row(
              label: 'Total',
              value: 'Rs. ${order.totalPrice.toStringAsFixed(2)}',
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 4),
            _Row(
              label: 'Location',
              value: order.location,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 4),
            _Row(
              label: 'Date',
              value:
                  DateFormat('dd MMM yyyy').format(order.createdAt),
              icon: Icons.calendar_today_outlined,
            ),

            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _Row(
                label: 'Notes',
                value: order.notes!,
                icon: Icons.notes_outlined,
              ),
            ],

            // ── Seller actions ────────────────────────────────────────
            if (isSeller && onStatusUpdate != null) ...[
              const SizedBox(height: 12),
              _SellerActions(status: status, onUpdate: onStatusUpdate!),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.pending:   return Colors.orange;
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.shipped:   return Colors.purple;
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Row(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SellerActions extends StatelessWidget {
  final OrderStatus status;
  final void Function(String) onUpdate;

  const _SellerActions({required this.status, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    String? nextStatus;
    String? nextLabel;

    switch (status) {
      case OrderStatus.pending:
        nextStatus = 'confirmed';
        nextLabel = 'Confirm Order';
        break;
      case OrderStatus.confirmed:
        nextStatus = 'shipped';
        nextLabel = 'Mark Shipped';
        break;
      case OrderStatus.shipped:
        nextStatus = 'delivered';
        nextLabel = 'Mark Delivered';
        break;
      default:
        break;
    }

    if (nextStatus == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (status == OrderStatus.pending)
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: () => onUpdate('cancelled'),
              child: const Text('Cancel',
                  style: TextStyle(fontSize: 13)),
            ),
          ),
        if (status == OrderStatus.pending) const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              elevation: 0,
            ),
            onPressed: () => onUpdate(nextStatus!),
            child: Text(
              nextLabel!,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
