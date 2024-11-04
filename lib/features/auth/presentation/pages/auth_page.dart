/*

Auth Page - This page determines whether to show the login or register page

*/

import 'package:flutter/material.dart';
import 'package:social_media/features/auth/presentation/pages/login_page.dart';
import 'package:social_media/features/auth/presentation/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  final bool showLoginPage;
  const AuthPage({super.key, this.showLoginPage = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // initially, show login page
  late bool showLoginPage = widget.showLoginPage; // Skill dung tu khoa late de khỏi gọi ham initState.

  // toggle between pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoginPage
        ? LoginPage(toggleRegisterPage: togglePages)
        : RegisterPage(toggleLoginPage: togglePages);
  }
}
