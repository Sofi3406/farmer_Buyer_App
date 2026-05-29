import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../config/route_observer.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_indicator.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLocation;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
        Provider.of<OrderProvider>(context, listen: false).fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Refresh when returning to this screen
    if (mounted) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      drawer: _buildDrawer(context, orderProvider.totalCount),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 180,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'lib/asset/images/buyer.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x33000000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Welcome, Buyer!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => productProvider.searchProducts(value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(),
                ),
              ],
            ),
          ),
          Expanded(
            child: productProvider.isLoading
                ? const LoadingIndicator()
                : productProvider.filteredProducts.isEmpty
                    ? const Center(child: Text('No products found'))
                    : ListView.builder(
                        itemCount: productProvider.filteredProducts.length,
                        itemBuilder: (ctx, i) => ProductCard(
                          product: productProvider.filteredProducts[i],
                          showFarmer: true,
                          onTap: () => context.go('/product-detail/${productProvider.filteredProducts[i].id}'),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter by Location'),
        content: TextField(
          onChanged: (value) => _selectedLocation = value,
          decoration: const InputDecoration(hintText: 'Enter city or area'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false).fetchProducts(location: _selectedLocation);
              Navigator.pop(ctx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, int orderCount) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'lib/asset/images/buyer.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.28),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'FarmConnect',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'lib/asset/images/product.jpg',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            title: const Text('Browse Products'),
            onTap: () => context.go('/buyer-dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('My Cart'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/cart');
            },
          ),
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'lib/asset/images/recieved.jpg',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            title: const Text('Order History'),
            trailing: orderCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      orderCount > 99 ? '99+' : '$orderCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.of(context).pop();
              context.push('/order-tracking/0'); // pass any id, screen will fetch all
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => context.go('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}