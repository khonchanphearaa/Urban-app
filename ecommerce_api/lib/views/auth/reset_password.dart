import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/validators.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordView({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Reset Password", style: TextStyle(fontWeight: FontWeight.bold),)),
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
                  Text(
                    'Create a new password for ${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: newPassController,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: AppValidators.validatePassword,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: confirmPassController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (value) => AppValidators.validateConfirmPassword(value, newPassController.text),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);

                              final success = await auth.resetPassword(
                                widget.email,
                                widget.otp,
                                newPassController.text,
                                confirmPassController.text,
                              );
                              if (!mounted) return;

                              if (success) {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Password reset successful')),
                                );
                                navigator.popUntil((route) => route.isFirst);
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(auth.lastError ?? 'Password reset failed')),
                                );
                              }
                            }
                          },
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("RESET PASSWORD"),
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