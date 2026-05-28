import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
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
        subtitle: Text('Total: ₹${order.totalAmount} | Status: ${order.status.toString().split('.').last}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map((item) => ListTile(
                      title: Text(item.productName),
                      subtitle: Text('Qty: ${item.quantity} x ₹${item.price}'),
                      trailing: Text('₹${item.price * item.quantity}'),
                    )),
                const Divider(),
                if (showActions)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (order.status == OrderStatus.pending)
                        ElevatedButton(
                          onPressed: () async {
                            await Provider.of<OrderProvider>(context, listen: false)
                                .updateOrderStatus(order.id, 'confirmed');
                            onStatusChanged?.call();
                          },
                          child: const Text('Confirm'),
                        ),
                      const SizedBox(width: 8),
                      if (order.status == OrderStatus.confirmed)
                        ElevatedButton(
                          onPressed: () async {
                            await Provider.of<OrderProvider>(context, listen: false)
                                .updateOrderStatus(order.id, 'shipped');
                            onStatusChanged?.call();
                          },
                          child: const Text('Mark Shipped'),
                        ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/order-tracking/${order.id}'),
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