import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/farmer/farmer_dashboard.dart';
import '../screens/farmer/add_product_screen.dart';
import '../screens/farmer/farmer_orders_screen.dart';
import '../farmer/farmer_products_screen.dart';
import '../screens/buyer/buyer_dashboard.dart';
import '../screens/buyer/product_detail_screen.dart';
import '../screens/buyer/cart_screen.dart';
import '../screens/buyer/checkout_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/common/order_tracking_screen.dart';
import '../screens/common/chat_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/manage_listings_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/farmer-dashboard', builder: (context, state) => const FarmerDashboard()),
    GoRoute(path: '/farmer-add-product', builder: (context, state) => const AddProductScreen()),
    GoRoute(path: '/farmer-orders', builder: (context, state) => const FarmerOrdersScreen()),
    GoRoute(path: '/farmer-products', builder: (context, state) => const FarmerProductsScreen()),
    GoRoute(path: '/buyer-dashboard', builder: (context, state) => const BuyerDashboard()),
    GoRoute(path: '/product-detail/:id', builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!)),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/order-tracking/:orderId', builder: (context, state) => OrderTrackingScreen(orderId: state.pathParameters['orderId']!)),
    GoRoute(path: '/chat/:userId', builder: (context, state) => ChatScreen(userId: state.pathParameters['userId']!)),
    GoRoute(path: '/admin-dashboard', builder: (context, state) => const AdminDashboard()),
    GoRoute(path: '/admin-users', builder: (context, state) => const ManageUsersScreen()),
    GoRoute(path: '/admin-listings', builder: (context, state) => const ManageListingsScreen()),
  ],
);