import 'package:finto_loans/config/router/app_router.dart';
import 'package:finto_loans/presentation/providers/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeNotifierProvider) ;

    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Finto',
      debugShowCheckedModeBanner: false,
      theme: appTheme.getTheme(),
    );
  }
}
