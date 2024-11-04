import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/components/my_button.dart';
import 'package:social_media/features/auth/presentation/components/my_textfield.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/responsive/contrained_scaffold.dart';

class LoginPage extends StatefulWidget {
  final void Function()? toggleRegisterPage;
  const LoginPage({super.key, required this.toggleRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  // login button
  void login() {
    // prepare email & pw
    final String email = emailController.text;
    final String pw = pwController.text;

    // auth cubit
    final AuthCubit authCubit = context.read<AuthCubit>();

    // ensure that the email & pw fields are not empty
    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter both email and password")));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return ContrainedScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //logo
                  Icon(
                    Icons.lock_open_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 80,
                  ),
              
                  const SizedBox(
                    height: 50,
                  ),
              
                  // welcome back msg
                  Text(
                    "Welcome back, you've been missed!",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
              
                  const SizedBox(
                    height: 25,
                  ),
              
                  // email textfield
                  MyTextfield(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController,
                  ),
              
                  const SizedBox(height: 10),
                  // password textfield
                  MyTextfield(
                    hintText: "Password",
                    obscureText: true,
                    controller: pwController,
                  ),
                  const SizedBox(height: 40),
              
                  // login button
                  MyButton(
                    text: "Login",
                    onTap: login,
                  ),
              
                  const SizedBox(height: 25),
              
                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member? ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.toggleRegisterPage,
                        child: Text(
                          "Register now",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
