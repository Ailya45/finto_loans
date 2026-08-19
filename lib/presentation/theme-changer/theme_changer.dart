import 'package:finto_loans/presentation/providers/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeChangerScreen extends ConsumerWidget {
  static const name = 'theme_changer_screen';

  const ThemeChangerScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Tema'),
        actions: [
          IconButton(
            onPressed: () {
              // ref
              //     .read(isDarkModeProvider.notifier)
              //     .update((isDarkMode) => !isDarkMode);

              ref.read(themeNotifierProvider.notifier).toggleDarkMode();
            },
            icon: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
          ),
        ],
      ),
      body: _ThemeChangedView(),
    );
  }
}

class _ThemeChangedView extends ConsumerWidget {
  const _ThemeChangedView();

  @override
  Widget build(BuildContext context, ref) {
    final List<Color> colors = ref.watch(colorListProvider);
    final selectedColor = ref.watch(themeNotifierProvider).selectedColor;
    // final selectedColor = ref.watch(selectedColorProvider);
    return ListView.builder(
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        return RadioGroup(
          groupValue: selectedColor,
          onChanged: (value) {
            // ref.read(selectedColorProvider.notifier).state = index;
            ref.read(themeNotifierProvider.notifier).changedColorIndex(index);
          },
          child: RadioListTile(
            title: Text('Este color', style: TextStyle(color: color)),
            activeColor: color,
            subtitle: Text('${color.toARGB32()}'),
            value: index,
          ),
        );
      },
    );
  }
}