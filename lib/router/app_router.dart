import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/settings_provider.dart';
import '../features/puzzle/presentation/screens/home_screen.dart';
import '../features/puzzle/presentation/screens/import_screen.dart';
import '../features/puzzle/presentation/screens/puzzle_screen.dart';
import '../features/puzzle/presentation/screens/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(settingsControllerProvider);
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/puzzle/:id',
        name: 'puzzle',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PuzzleScreen(puzzleId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/import',
        name: 'import',
        builder: (context, state) => const ImportPuzzleScreen(),
      ),
    ],
  );
});
