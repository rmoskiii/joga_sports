import 'package:flutter/material.dart';

import '../di/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// Loads data with [load], shows a loader or error, then calls [builder].
///
/// Reloads automatically when app data changes (e.g. after a booking), so
/// every screen stays in sync without manual refresh logic.
///
/// If the inputs to [load] change (a filter, a tab), give the view a key
/// that changes with them, e.g. `key: ValueKey(filter)`.
class AsyncView<T> extends StatefulWidget {
  const AsyncView({
    super.key,
    required this.load,
    required this.builder,
  });

  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;

  @override
  State<AsyncView<T>> createState() => _AsyncViewState<T>();
}

class _AsyncViewState<T> extends State<AsyncView<T>> {
  Future<T>? _future;
  Listenable? _changes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final changes = context.services.changes;
    if (!identical(changes, _changes)) {
      _changes?.removeListener(_reload);
      _changes = changes..addListener(_reload);
      _future = widget.load();
    }
  }

  @override
  void dispose() {
    _changes?.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = widget.load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data as T);
        }
        // Material ancestor so these states render correctly even when the
        // view is a whole screen (no Scaffold above it).
        return Material(
          color: AppColors.background,
          child: snapshot.hasError
              ? _ErrorState(error: snapshot.error!, onRetry: _reload)
              : const Center(
                  child: SizedBox.square(
                    dimension: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.lime,
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is StateError
        ? (error as StateError).message
        : 'Something went wrong. Check your connection and try again.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(height: Space.sm),
            Text(message, style: AppText.small, textAlign: TextAlign.center),
            const SizedBox(height: Space.md),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
