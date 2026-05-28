import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/loading_indicator.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final matchingOrders = orderProvider.orders.where((o) => o.id == widget.orderId);
    final order = matchingOrders.isNotEmpty ? matchingOrders.first : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: orderProvider.isLoading
          ? const LoadingIndicator()
          : order == null
              ? const Center(child: Text('Order not found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTimeline(order.status),
                      const SizedBox(height: 30),
                      Card(
                        child: ListTile(
                          title: Text('Order #${order.id.substring(0, 8)}'),
                          subtitle: Text('Placed on ${order.orderDate.toLocal()}'),
                          trailing: Text('\u20B9${order.totalAmount}'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...order.items.map((item) => ListTile(
                            title: Text(item.productName),
                            subtitle: Text('Qty: ${item.quantity} x ₹${item.price}'),
                            trailing: Text('₹${item.price * item.quantity}'),
                          )),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTimeline(OrderStatus status) {
    final statuses = OrderStatus.values;
    final currentIndex = statuses.indexOf(status);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: statuses.asMap().entries.map((entry) {
            int idx = entry.key;
            String label = entry.value.toString().split('.').last;
            return Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: idx <= currentIndex ? Colors.green : Colors.grey,
                    child: Icon(idx <= currentIndex ? Icons.check : Icons.timelapse, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(label, style: TextStyle(fontSize: 12, color: idx <= currentIndex ? Colors.green : Colors.grey)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}