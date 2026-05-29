import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../config/route_observer.dart';
import 'dart:async';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with RouteAware {
  Timer? _pollTimer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
    // If viewing a single order, poll for status updates every 8 seconds
    if (widget.orderId != '0') {
      _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
        if (mounted) Provider.of<OrderProvider>(context, listen: false).fetchOrders();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    if (mounted) Provider.of<OrderProvider>(context, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final isHistoryView = widget.orderId == '0';
    final matchingOrders = orderProvider.orders.where((o) => o.id == widget.orderId);
    final order = matchingOrders.isNotEmpty ? matchingOrders.first : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isHistoryView ? 'Order History' : 'Order Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            final role = Provider.of<AuthProvider>(context, listen: false).user?.role ?? '';
            switch (role) {
              case 'buyer':
                context.go('/buyer-dashboard');
                break;
              case 'farmer':
                context.go('/farmer-dashboard');
                break;
              case 'admin':
                context.go('/admin-dashboard');
                break;
              default:
                context.go('/login');
            }
          },
        ),
      ),
      body: orderProvider.isLoading
          ? const LoadingIndicator()
          : isHistoryView
              ? _buildHistoryList(orderProvider.orders)
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
                              trailing: Text('ETB ${order.totalAmount}'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...order.items.map((item) => ListTile(
                                title: Text(item.productName),
                                subtitle: Text('Qty: ${item.quantity} x ETB ${item.price}'),
                                trailing: Text('ETB ${item.price * item.quantity}'),
                              )),
                        ],
                      ),
                    ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Widget _buildHistoryList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('Order #${order.id.substring(0, 8)}'),
            subtitle: Text(
              '${_itemNames(order)} • ETB ${order.totalAmount.toStringAsFixed(2)}\n${order.orderDate.toLocal()}',
            ),
            trailing: Text(order.status.name),
            onTap: () => context.push('/order-tracking/${order.id}'),
          ),
        );
      },
    );
  }

  String _itemNames(Order order) {
    final names = order.items.map((item) => item.productName).where((name) => name.trim().isNotEmpty).toList();
    if (names.isEmpty) return 'Items: -';
    return 'Items: ${names.join(', ')}';
  }

  Widget _buildTimeline(OrderStatus status) {
    const statuses = OrderStatus.values;
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