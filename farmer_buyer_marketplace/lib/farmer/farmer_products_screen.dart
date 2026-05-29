import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/product_card.dart';

class FarmerProductsScreen extends StatefulWidget {
	const FarmerProductsScreen({super.key});

	@override
	State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
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
		final authProvider = Provider.of<AuthProvider>(context);
		final farmerId = authProvider.user?.id;
		final myProducts = productProvider.products.where((p) => p.farmerId == farmerId).toList();

		return Scaffold(
			appBar: AppBar(
				title: const Text('My Products'),
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () {
						if (Navigator.of(context).canPop()) {
							Navigator.of(context).pop();
						} else {
							context.go('/farmer-dashboard');
						}
					},
				),
			),
			body: productProvider.isLoading
					? const LoadingIndicator()
					: myProducts.isEmpty
							? const Center(child: Text('You have not added any products yet'))
							: ListView.builder(
									itemCount: myProducts.length,
									itemBuilder: (ctx, i) => ProductCard(
										product: myProducts[i],
										showFarmer: false,
										onDelete: () async {
											await productProvider.deleteProduct(myProducts[i].id);
										},
									),
								),
			floatingActionButton: FloatingActionButton(
				onPressed: () => context.push('/farmer-add-product'),
				child: const Icon(Icons.add),
			),
		);
	}
}
