import 'package:finto_loans/config/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

//Listado de colores inmutables
final colorListProvider = Provider((ref) => colorList);

// Un simple boolena
final isDarkModeProvider = StateProvider((ref) => false);

// Un simple int
final selectedColorProvider = StateProvider((ref) => 0);

//Objeto de tipo AppTheme (custom)
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>(
  (ref) => ThemeNotifier(),
);

//Controller o Notifier
class ThemeNotifier extends StateNotifier<AppTheme> {
  //STATE = Estado = new AppTheme()
  ThemeNotifier() : super(AppTheme());

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void changedColorIndex(int colorIndex) {
    state = state.copyWith(selectedColor: colorIndex);
  }
}