import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:subtitle_downloader/features/authentication/bloc/authentication_bloc.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authenticationBloc = AuthenticationBloc();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: _validateEmail,
                ),
                const Gap(8),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  obscureText: true,
                  validator: _validatePassword,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      context.pushNamed('Forget Password');
                    },
                  ),
                ),
                BlocConsumer<AuthenticationBloc, AuthenticationState>(
                  bloc: _authenticationBloc,
                  listener: (context, state) {
                    if (state is SignInErrorState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                        ),
                      );
                    } else if (state is SignInSuccessfulState) {
                      DownloadedSubtitlesBox.clearAllDownloadedSubtitles();
                      context.pop();
                    }
                  },
                  builder: (context, state) {
                    if (state is SignInLoadingState) {
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
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(250, 50),
                      ),
                      child: const Text('Login'),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        context.pushReplacementNamed('Sign Up');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                const Gap(16),
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const Text(
                  'Logging in will clear your downloaded subtitles history and grab the latest from the server',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      _authenticationBloc.add(SignInInitialEvent(email, password));
    }
  }
}
