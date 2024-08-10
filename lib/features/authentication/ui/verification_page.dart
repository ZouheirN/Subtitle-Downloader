import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:subtitle_downloader/features/authentication/repos/auth_service.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _auth = AuthService();
  late Timer timer;

  @override
  void initState() {
    _auth.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      FirebaseAuth.instance.currentUser!.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        timer.cancel();
        while (context.canPop() == true) {
          context.pop();
        }
        context.pushReplacementNamed('Profile');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email has been verified!'),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                'A verification email has been sent to your email address.'),
            const Text('Please verify your email to continue.'),
            const Gap(16),
            ElevatedButton(
              onPressed: () {
                _auth.sendEmailVerification();
              },
              child: const Text('Resend Email'),
            ),
          ],
        ),
      ),
    );
  }
}
