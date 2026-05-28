import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_indicator.dart';

class ManageListingsScreen extends StatefulWidget {
  const ManageListingsScreen({super.key});

  @override
  State<ManageListingsScreen> createState() => _ManageListingsScreenState();
}

class _ManageListingsScreenState extends State<ManageListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Listings')),
      body: productProvider.isLoading
          ? const LoadingIndicator()
          : ListView.builder(
              itemCount: productProvider.products.length,
              itemBuilder: (ctx, i) => ProductCard(
                product: productProvider.products[i],
                showFarmer: true,
                onDelete: () async {
                  await productProvider.deleteProduct(productProvider.products[i].id);
                },
              ),
            ),
    );
  }
}