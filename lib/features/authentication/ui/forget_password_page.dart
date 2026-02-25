import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../bloc/authentication_bloc.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _authenticationBloc = AuthenticationBloc();

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter your email to reset your password'),
            const Gap(20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
            ),
            const Gap(20),
            BlocConsumer<AuthenticationBloc, AuthenticationState>(
              bloc: _authenticationBloc,
              listener: (context, state) {
                if (state is PasswordResetErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                    ),
                  );
                } else if (state is PasswordResetSuccessfulState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent'),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is PasswordResetLoadingState) {
                  return ElevatedButton.icon(
                    onPressed: null,
                    label: const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(250, 50),
                    ),
                  );
                }

                return ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 50),
                  ),
                  child: const Text('Reset Password'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _resetPassword() {
    _authenticationBloc
        .add(PasswordResetInitialEvent(_emailController.text.trim()));
  }
}
