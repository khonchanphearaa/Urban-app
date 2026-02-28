import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'controllers/updateProfile_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/payment_controller.dart';
import 'controllers/address_controller.dart';
import 'controllers/ai_chat_controller.dart';
import 'controllers/admin/admin_product_controller.dart';
import 'controllers/admin/admin_category_controller.dart';
import 'controllers/admin/admin_order_controller.dart';
import 'controllers/admin/admin_user_controller.dart';
import 'utils/theme/app_theme.dart';
import 'utils/router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => WishlistController()),
        ChangeNotifierProvider(create: (_) => UpdateProfileController()),
        ChangeNotifierProvider(create: (_) => CategoryController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => PaymentController()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(create: (_) => AiChatController()),
        ChangeNotifierProvider(create: (_) => AdminProductController()),
        ChangeNotifierProvider(create: (_) => AdminCategoryController()),
        ChangeNotifierProvider(create: (_) => AdminOrderController()),
        ChangeNotifierProvider(create: (_) => AdminUserController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Urban Store',
        theme: AppTheme.lightTheme,

        /* Router configuration */
        initialRoute: AppRouter.home,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
