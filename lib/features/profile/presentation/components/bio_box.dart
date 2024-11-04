import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String bioText;
  const BioBox({super.key, required this.bioText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Text(
        bioText.isNotEmpty ? bioText : "Empty bio...",
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
