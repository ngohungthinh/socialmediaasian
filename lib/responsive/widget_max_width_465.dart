import 'package:flutter/material.dart';

class WidgetMaxWidth465 extends StatelessWidget {
  final Widget child;
  const WidgetMaxWidth465({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 465),
          child: child,
        ),
      ),
    );
  }
}
