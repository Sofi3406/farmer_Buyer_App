import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
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
    final authProvider = Provider.of<AuthProvider>(context);
    final farmerId = authProvider.user?.id;

    final myOrders = orderProvider.orders.where((o) => o.farmerId == farmerId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Orders Received')),
      body: orderProvider.isLoading
          ? const LoadingIndicator()
          : myOrders.isEmpty
              ? const Center(child: Text('No orders received yet'))
              : ListView.builder(
                  itemCount: myOrders.length,
                  itemBuilder: (ctx, i) {
                    final order = myOrders[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('Order #${order.id.substring(0, 8)}'),
                        subtitle: Text(
                          'Items: ${order.items.length} • Amount: ₹${order.totalAmount.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          order.status.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
