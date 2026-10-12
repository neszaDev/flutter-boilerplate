import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/connectivity.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A strip at the top of the page while the phone has no network.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider);
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: online
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Container(
                width: double.infinity,
                color: context.colors.ink950,
                padding: const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.sm),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: context.colors.paper),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Text(
                        context.l10n.commonOfflineBanner,
                        style: context.text.bodySmall?.copyWith(color: context.colors.paper),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
