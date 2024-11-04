/*

SETTINGS PAGE

- Dark Mode
- Blocked Users
- Account Settings

*/


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/responsive/widget_max_width_465.dart';
import 'package:social_media/themes/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // theme cubit
    final ThemeCubit themeCubit = context.watch<ThemeCubit>();

    bool isDarkMode = themeCubit.isDarkMode;

    return WidgetMaxWidth465(
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Settings"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // dark mode tile
            ListTile(
              title: const Text("Dark Mode"),
              trailing: CupertinoSwitch(value: isDarkMode, onChanged:(value) => themeCubit.toggleTheme()),
            )
          ],
        ),
      ),
    );
  }
}
