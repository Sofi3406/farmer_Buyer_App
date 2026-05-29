import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool showActions;
  final VoidCallback? onStatusChanged;

  const OrderCard({
    super.key,
    required this.order,
    this.showActions = false,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text('Order #${order.id.substring(0, 8)}'),
        subtitle: Text(
          'Total: ETB ${order.totalAmount} | Status: ${order.status.toString().split('.').last}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map(
                  (item) => ListTile(
                    title: Text(item.productName),
                    subtitle: Text(
                      'Qty: ${item.quantity}kg x ETB ${item.price}',
                    ),
                    trailing: Text('ETB ${item.price * item.quantity}'),
                  ),
                ),
                if (order.receiptUrl != null &&
                    order.receiptUrl!.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 4),
                  Text(
                    'Buyer Receipt',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      order.receiptUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          alignment: Alignment.center,
                          color: Colors.grey.shade200,
                          child: const Text('Receipt image unavailable'),
                        );
                      },
                    ),
                  ),
                ],
                const Divider(),
                if (showActions)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (order.status == OrderStatus.pending)
                        ElevatedButton(
                          onPressed: () async {
                            await Provider.of<OrderProvider>(
                              context,
                              listen: false,
                            ).updateOrderStatus(order.id, 'confirmed');
                            onStatusChanged?.call();
                          },
                          child: const Text('Confirm'),
                        ),
                      const SizedBox(width: 8),
                      if (order.status == OrderStatus.confirmed)
                        ElevatedButton(
                          onPressed: () async {
                            await Provider.of<OrderProvider>(
                              context,
                              listen: false,
                            ).updateOrderStatus(order.id, 'shipped');
                            onStatusChanged?.call();
                          },
                          child: const Text('Mark Shipped'),
                        ),
                      // If order has been shipped, allow buyer to confirm delivery
                      if (order.status == OrderStatus.shipped)
                        Builder(
                          builder: (ctx) {
                            final role =
                                Provider.of<AuthProvider>(
                                  ctx,
                                  listen: false,
                                ).user?.role ??
                                '';
                            if (role == 'buyer') {
                              return ElevatedButton(
                                onPressed: () async {
                                  await Provider.of<OrderProvider>(
                                    context,
                                    listen: false,
                                  ).updateOrderStatus(order.id, 'delivered');
                                  onStatusChanged?.call();
                                },
                                child: const Text('Confirm Delivery'),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/order-tracking/${order.id}',
                    ),
                    child: const Text('Track Order'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
