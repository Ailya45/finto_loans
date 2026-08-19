import 'package:finto_loans/presentation/screens/clients/cliennt_detail.dart';
import 'package:finto_loans/presentation/screens/config/configuration.dart';
import 'package:finto_loans/presentation/screens/main/main_screen.dart';
import 'package:finto_loans/presentation/theme-changer/theme_changer.dart';
import 'package:finto_loans/domain/entities/client.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const MainScreen();
      },
    ),
    GoRoute(
      path: '/client-detail',
      builder: (context, state) {
        final client = state.extra as Client;
        return ClientDetailScreen(client: client);
      },
    ),
    GoRoute(
      path: '/configuration',
      builder: (context, state) {
        final configurationName = state.extra as String? ?? 'Configuración';
        return ConfigurationScreen(configurationName: configurationName);
      },
    ),
    GoRoute(
      path: '/theme-changer',
      builder: (context, state) {
        return const ThemeChangerScreen();
      },
    )
  ],
);
