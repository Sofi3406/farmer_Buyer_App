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
			final authProvider = Provider.of<AuthProvider>(context, listen: false);
			final farmerId = authProvider.user?.id;
			if (farmerId != null && farmerId.isNotEmpty) {
				Provider.of<ProductProvider>(context, listen: false).fetchProducts(farmerId: farmerId);
			}
		});
	}

	@override
	Widget build(BuildContext context) {
		final productProvider = Provider.of<ProductProvider>(context);

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
					: productProvider.products.isEmpty
							? const Center(child: Text('You have not added any products yet'))
							: ListView.builder(
									itemCount: productProvider.products.length,
									itemBuilder: (ctx, i) => ProductCard(
										product: productProvider.products[i],
										showFarmer: false,
										onDelete: () async {
											await productProvider.deleteProduct(productProvider.products[i].id);
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
