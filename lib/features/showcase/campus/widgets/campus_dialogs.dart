import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/campus/two_factor.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/loading_overlay.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/message_dialog.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/sign_in_help_dialog.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/two_factor_dialog.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// How long the loading overlay demo stays up.
const loadingDemoDuration = Duration(seconds: 2);

/// The campus dialogs, each opened by a button: sign-in help, the two-factor step, an error
/// message and the loading overlay. The two-factor step reports its failures through the same
/// error dialog and overlay, as the Vue app did through its store.
class CampusDialogs extends StatefulWidget {
  const CampusDialogs({required this.email, super.key});

  /// Address the two-factor code is sent to.
  final String email;

  @override
  State<CampusDialogs> createState() => _CampusDialogsState();
}

class _CampusDialogsState extends State<CampusDialogs> {
  String? _lastAction;

  void _report(String? code) {
    if (code != null && mounted) {
      setState(() => _lastAction = code);
    }
  }

  Future<void> _openError() async {
    final l10n = context.l10n;
    final code = await showMessageDialog(
      context,
      content: DialogMessageContent(
        title: l10n.campusDialogsErrorTitle,
        message: l10n.campusDialogsSampleError,
        number: '1',
        code: '40100',
      ),
      buttons: [
        DialogMessageButton(code: 'cancel', label: l10n.campusDialogsCancel, icon: LucideIcons.ban),
        DialogMessageButton(
          code: 'submit',
          label: l10n.campusDialogsSubmit,
          icon: LucideIcons.send,
          variant: DialogButtonVariant.primary,
        ),
      ],
    );
    _report(code);
  }

  /// Shows a failed two-factor step; "Cancel" closes the two-factor dialog too.
  Future<bool> _twoFactorFailed(TwoFactorFailure failure) async {
    final l10n = context.l10n;
    Haptics.error();
    final code = await showMessageDialog(
      context,
      content: DialogMessageContent(
        title: l10n.campusDialogsErrorTitle,
        message: failure.message(l10n),
        number: '1',
        code: failure.code,
      ),
      buttons: [
        DialogMessageButton(code: 'cancel', label: l10n.campusDialogsCancel, icon: LucideIcons.ban),
        DialogMessageButton(
          code: 'retry',
          label: l10n.campusDialogsRetry,
          icon: LucideIcons.rotateCcw,
          variant: DialogButtonVariant.primary,
        ),
      ],
    );
    _report(code);
    return code == 'cancel';
  }

  Future<void> _openTwoFactor() => showDialog<void>(
    context: context,
    builder: (_) => TwoFactorDialog(email: widget.email, onFailure: _twoFactorFailed),
  );

  Future<void> _openLoading() =>
      showLoadingOverlay(context, () => Future<void>.delayed(loadingDemoDuration));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lastAction = _lastAction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            OutlinedButton.icon(
              onPressed: () => showSignInHelpDialog(context),
              icon: const Icon(LucideIcons.circleQuestionMark, size: 18),
              label: Text(l10n.campusDialogsOpenHelp),
            ),
            OutlinedButton.icon(
              onPressed: _openTwoFactor,
              icon: const Icon(LucideIcons.shieldCheck, size: 18),
              label: Text(l10n.campusDialogsOpenTwoFactor),
            ),
            OutlinedButton.icon(
              onPressed: () => unawaited(_openError()),
              icon: const Icon(LucideIcons.messageSquareWarning, size: 18),
              label: Text(l10n.campusDialogsOpenError),
            ),
            OutlinedButton.icon(
              onPressed: _openLoading,
              icon: const Icon(LucideIcons.loaderCircle, size: 18),
              label: Text(l10n.campusDialogsOpenLoading),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        Semantics(
          container: true,
          liveRegion: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 20),
            child: Text(
              lastAction == null ? '' : l10n.campusDialogsLastAction(lastAction),
              style: context.text.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
