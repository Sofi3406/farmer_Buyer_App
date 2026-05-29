import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  bool _refreshing = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        Provider.of<OrderProvider>(context, listen: false).fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshOrders() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final farmerId = authProvider.user?.id;

    final myOrders = orderProvider.orders.where((o) => o.farmerId == farmerId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Received'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // fallback to dashboard if there's no back stack
              Navigator.of(context).pushReplacementNamed('/farmer-dashboard');
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: orderProvider.isLoading && !_refreshing
            ? const LoadingIndicator()
            : myOrders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 220),
                      Center(child: Text('No orders received yet')),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: myOrders.length,
                    itemBuilder: (ctx, i) {
                      final order = myOrders[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text('Order #${order.id.substring(0, 8)}'),
                          subtitle: Text(
                            'Items: ${order.items.length} • Amount: ETB ${order.totalAmount.toStringAsFixed(2)}',
                          ),
                          trailing: Text(
                            order.status.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
