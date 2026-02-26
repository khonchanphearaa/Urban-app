import 'package:flutter/material.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/register_view.dart';
import '../../views/auth/forgot_password.dart';
import '../../views/auth/verify_otp_view.dart';
import '../../views/auth/reset_password.dart';
import '../../views/home/product_detail_view.dart';
import '../../models/product_model.dart';

class AppRouter {
  static const String login = '';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String productDetails = '/product-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginView());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordView());
      case verifyOtp:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VerifyOtpView(email: email),
        );
      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        final otp = args['otp'] as String;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordView(email: email, otp: otp),
        );
      case productDetails:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => ProductDetailView(product: product),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}