import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// The bottom tabs: switch tab instead of stacking a second copy (as the menu does).
const _tabPaths = {Routes.dashboard, Routes.testResults, Routes.files, Routes.device};

/// Follows an in-app link of a demo: tabs are switched to, other screens are pushed.
void openAppPath(BuildContext context, String path) {
  if (_tabPaths.contains(path)) {
    context.go(path);
  } else {
    unawaited(context.push<void>(path));
  }
}

/// Opens [uri] in the browser; says so when no app can open it.
Future<void> openExternal(BuildContext context, Uri uri) async {
  bool opened;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException {
    opened = false;
  }
  if (!opened && context.mounted) {
    showToast(context, context.l10n.commonErrorGeneric, tone: ToastTone.error);
  }
}

/// Scrolls the page until the widget of [key] is in view: what a `#hash` link does on the web.
void revealSection(GlobalKey key) {
  final target = key.currentContext;
  if (target != null) {
    unawaited(
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }
}
