import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media/themes/dark_mode.dart';
import 'package:social_media/themes/light_mode.dart';

class ThemeCubit extends Cubit<ThemeData> {
  bool _isDarkMode;
  late final SharedPreferences sharedPreferences;

  ThemeCubit(this.sharedPreferences, this._isDarkMode)
      : super(_isDarkMode ? darkMode : lightMode);

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;

    if (isDarkMode) {
      sharedPreferences.setBool('isDarkMode', isDarkMode);
      emit(darkMode);
    } else {
      sharedPreferences.setBool('isDarkMode', isDarkMode);
      emit(lightMode);
    }
  }
}
