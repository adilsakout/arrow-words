import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/app_localizations.dart';
import '../../../puzzle/logic/puzzle_provider.dart';
import 'home_screen.dart';

class ImportPuzzleScreen extends ConsumerStatefulWidget {
  const ImportPuzzleScreen({super.key});

  @override
  ConsumerState<ImportPuzzleScreen> createState() => _ImportPuzzleScreenState();
}

class _ImportPuzzleScreenState extends ConsumerState<ImportPuzzleScreen> {
  final _controller = TextEditingController();
  bool _isImporting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appString('importJson')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              l10n.appString('importInstructions'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: _error,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isImporting
                        ? null
                        : () {
                            context.pop();
                          },
                    child: Text(l10n.appString('cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isImporting ? null : () => _importPuzzle(context),
                    child: _isImporting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.appString('confirm')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importPuzzle(BuildContext context) async {
    setState(() {
      _isImporting = true;
      _error = null;
    });
    try {
      final repository = ref.read(puzzleRepositoryProvider);
      await repository.importFromJson(_controller.text);
      ref.invalidate(puzzleSummariesProvider);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appString('importSuccess'))),
      );
      context.pop();
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }
}
