import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final IconData iconData;
  final void Function()? onTap;
  final String titleText;

  const MyDrawerTile({
    super.key,
    required this.iconData,
    required this.titleText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        titleText,
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
      ),
      leading: Icon(
        iconData,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
    );
  }
}
