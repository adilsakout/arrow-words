import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/utils/providers.dart';
import '../../../puzzle/domain/entities.dart';
import '../../../puzzle/logic/puzzle_provider.dart';

final puzzleSummariesProvider = FutureProvider<List<PuzzleSummary>>((ref) {
  final repository = ref.watch(puzzleRepositoryProvider);
  return repository.listLocalAndBundled();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(puzzleSummariesProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final lastPuzzleId = prefs.getString('progress.last');
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appString('appTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: l10n.appString('settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: summaries.when(
          data: (puzzles) {
            final daily = puzzles.firstWhereOrNull((element) => element.isDaily);
            final others = puzzles.where((p) => p != daily).toList();
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                if (daily != null)
                  _PuzzleTile(
                    icon: Icons.wb_sunny_outlined,
                    title: l10n.appString('dailyPuzzle'),
                    subtitle: '${daily.title} — ${daily.author}',
                    onTap: () => context.push('/puzzle/${daily.id}'),
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.wb_twilight),
                    title: Text(l10n.appString('dailyPuzzle')),
                    subtitle: Text(l10n.appString('dailyUnavailable')),
                    enabled: false,
                  ),
                if (lastPuzzleId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _PuzzleTile(
                      icon: Icons.play_arrow_rounded,
                      title: l10n.appString('continueLast'),
                      subtitle: lastPuzzleId,
                      onTap: () => context.push('/puzzle/$lastPuzzleId'),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 12),
                  child: Text(
                    l10n.appString('puzzlePacks'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ...others.map((summary) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _PuzzleTile(
                        icon: Icons.grid_on,
                        title: summary.title,
                        subtitle: '${summary.width}×${summary.height} · ${summary.author}',
                        onTap: () => context.push('/puzzle/${summary.id}'),
                      ),
                    )),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.push('/import'),
                  icon: const Icon(Icons.file_download),
                  label: Text(l10n.appString('importJson')),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
        ),
      ),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
