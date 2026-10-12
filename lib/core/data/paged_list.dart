import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The pages of a backend list loaded so far.
@immutable
class PagedState<T> {
  const PagedState({
    required this.items,
    required this.nextPage,
    required this.totalElements,
    required this.hasMore,
    this.loadingMore = false,
    this.loadMoreError,
  });

  factory PagedState.first(PageResult<T> page) => PagedState(
    items: page.items,
    nextPage: page.page + 1,
    totalElements: page.totalElements,
    hasMore: !page.isLast && page.items.isNotEmpty,
  );

  final List<T> items;
  final int nextPage;
  final int totalElements;
  final bool hasMore;
  final bool loadingMore;

  /// The last "load more" failed; the items already shown stay.
  final Object? loadMoreError;

  PagedState<T> copyWith({
    List<T>? items,
    int? nextPage,
    int? totalElements,
    bool? hasMore,
    bool? loadingMore,
    Object? Function()? loadMoreError,
  }) => PagedState(
    items: items ?? this.items,
    nextPage: nextPage ?? this.nextPage,
    totalElements: totalElements ?? this.totalElements,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreError: loadMoreError == null ? this.loadMoreError : loadMoreError(),
  );
}

/// A backend list that loads page by page as the user scrolls (the web app shows page links;
/// phones scroll). Implement [fetchPage]; the first page loads in [build].
abstract class PagedNotifier<T> extends AsyncNotifier<PagedState<T>> {
  Future<PageResult<T>> fetchPage(int page);

  @override
  Future<PagedState<T>> build() async => PagedState.first(await fetchPage(0));

  /// Loads the next page; does nothing while one is loading or when there is no more.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) {
      return;
    }
    state = AsyncData(current.copyWith(loadingMore: true, loadMoreError: () => null));
    try {
      final page = await fetchPage(current.nextPage);
      if (!ref.mounted) {
        return;
      }
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          nextPage: page.page + 1,
          totalElements: page.totalElements,
          hasMore: !page.isLast && page.items.isNotEmpty,
          loadingMore: false,
        ),
      );
    } on Object catch (error) {
      if (ref.mounted) {
        state = AsyncData(current.copyWith(loadingMore: false, loadMoreError: () => error));
      }
    }
  }

  /// Reloads from the first page (pull to refresh, after a change). Completes normally even
  /// when the reload fails: the list shows the error with a retry button, and the
  /// pull-to-refresh spinner only needs to stop.
  Future<void> reload() async {
    ref.invalidateSelf();
    try {
      await future;
    } on Object {
      // Shown by the list (AsyncError); rethrowing would report it as an uncaught error.
    }
  }
}

/// The footer of a paged list: loads the next page when it scrolls into view, shows a spinner,
/// a retry on failure, or "that's everything".
class PagedFooter<T> extends StatelessWidget {
  const PagedFooter({required this.state, required this.onLoadMore, super.key});

  final PagedState<T> state;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(Space.page),
        child: Column(
          children: [
            Text(
              errorMessage(context, state.loadMoreError!),
              style: context.text.bodySmall?.copyWith(color: context.colors.pen),
              textAlign: TextAlign.center,
            ),
            TextButton(onPressed: onLoadMore, child: Text(l10n.commonRetry)),
          ],
        ),
      );
    }
    if (state.hasMore) {
      if (!state.loadingMore) {
        // Reached the end of what's loaded: fetch more after this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(onLoadMore()));
      }
      return const LoadingView(compact: true);
    }
    if (state.items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(Space.page),
      child: Text(
        l10n.commonEndOfList,
        style: context.text.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
