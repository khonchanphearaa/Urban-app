import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/router/app_router.dart';
import '../../utils/validators.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Forgot Password", style: TextStyle(fontWeight: FontWeight.bold),)),
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
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your email to receive an OTP code.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: AppValidators.validateEmail,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : () async {
                            if (!_formKey.currentState!.validate()) return;

                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final sent = await auth.forgotPassword(
                              emailController.text.trim(),
                            );
                            if (!mounted) return;

                            if (sent) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('OTP sent to your email'),
                                ),
                              );

                              /* push page vertify OTP page */
                              navigator.pushNamed(
                                AppRouter.verifyOtp,
                                arguments: emailController.text.trim(),
                              );
                            } else {
                              final msg = auth.lastError ?? 'Failed to send OTP';
                              messenger.showSnackBar(
                                SnackBar(content: Text(msg)),
                              );
                            }
                          },
                    child: auth.isLoading ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("SEND OTP"),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Login"),
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
