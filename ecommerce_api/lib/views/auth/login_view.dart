import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/validators.dart';
import '../../utils/router/app_router.dart'; 
import '../home/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* Listen to the AuthController for loading state changes */
    final auth = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/image/Urban.jpg',
                      width: 160,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Text(
                    "Login to find your style",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  /* Email Field */
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: AppValidators.validateEmail,
                  ),
                  const SizedBox(height: 20),

                  /* Password Field */
                  TextFormField(
                    controller: passController,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: AppValidators.validatePassword,
                  ),

                  /**
                   * @Forgot password link 
                   * @description: for push to forgot password view
                   */
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRouter.forgotPassword,
                      ),
                      child: const Text("Forgot Password?"),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /* Login Button */
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              bool success = await auth.login(
                                emailController.text.trim(),
                                passController.text.trim(),
                              );

                              if (success && context.mounted) {
                                // Navigate to Home on successful login
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeView(),
                                  ),
                                );
                              } else if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid email or password failed"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },

                    /* This style ternary operatore: sytax condition ? valueIfTrue : valueIfFalse; */
                    child: auth.isLoading ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("LOGIN"),
                  ),

                  const SizedBox(height: 20),

                  /* Register Link */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRouter.register),
                        child: const Text("Register Now"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
