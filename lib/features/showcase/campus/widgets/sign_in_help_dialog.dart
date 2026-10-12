import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/campus_badge.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showSignInHelpDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const SignInHelpDialog());

/// The sign-in help dialog (Vue `SignIn`): who to contact (call or email), the competency
/// dictionary and user manual in Thai and English, and the form to report a sign-in problem.
/// Google sign-in is left out: the Spring API has no Google login.
class SignInHelpDialog extends StatelessWidget {
  const SignInHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      scrollable: true,
      semanticLabel: l10n.campusSignInHelpTitle,
      title: Column(
        children: [
          const CampusBadge(),
          const SizedBox(height: Space.md),
          Text(l10n.campusSignInHelpTitle, textAlign: TextAlign.center),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.campusSignInHelpDescription, textAlign: TextAlign.center),
          const SizedBox(height: Space.card),
          _HelpItem(
            number: 1,
            title: l10n.campusSignInHelpContactTitle,
            children: [
              Text(l10n.campusSignInHelpContactText(SignInHelp.phone)),
              _HelpLink(
                label: l10n.campusSignInHelpCall,
                icon: LucideIcons.phone,
                uri: SignInHelp.phoneUri,
              ),
              _HelpLink(
                label: SignInHelp.email,
                icon: LucideIcons.mail,
                uri: Uri(scheme: 'mailto', path: SignInHelp.email),
              ),
            ],
          ),
          _HelpItem(
            number: 2,
            title: l10n.campusSignInHelpCompetencyTitle,
            children: [
              _HelpLink.document(
                label: l10n.campusSignInHelpThaiVersion,
                uri: SignInHelp.competencyThai,
              ),
              _HelpLink.document(
                label: l10n.campusSignInHelpEnglishVersion,
                uri: SignInHelp.competencyEnglish,
              ),
            ],
          ),
          _HelpItem(
            number: 3,
            title: l10n.campusSignInHelpManualTitle,
            children: [
              _HelpLink.document(
                label: l10n.campusSignInHelpThaiVersion,
                uri: SignInHelp.manualThai,
              ),
              _HelpLink.document(
                label: l10n.campusSignInHelpEnglishVersion,
                uri: SignInHelp.manualEnglish,
              ),
            ],
          ),
          _HelpItem(
            number: 4,
            title: l10n.campusSignInHelpIssueTitle,
            children: [
              _HelpLink.document(label: l10n.campusSignInHelpIssueLink, uri: SignInHelp.issueForm),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.campusSignInHelpClose),
        ),
      ],
    );
  }
}

/// One numbered entry of the help list.
class _HelpItem extends StatelessWidget {
  const _HelpItem({required this.number, required this.title, required this.children});

  final int number;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bold = context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.page),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: ExcludeSemantics(child: Text('$number.', style: bold)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: bold),
                const SizedBox(height: Space.xs),
                Wrap(spacing: Space.page, children: children),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A link of the help list: the dialer, the mail app, or a document in the browser.
class _HelpLink extends StatelessWidget {
  const _HelpLink({required this.label, required this.icon, required this.uri}) : external = false;

  const _HelpLink.document({required this.label, required this.uri})
    : icon = LucideIcons.externalLink,
      external = true;

  final String label;
  final IconData icon;
  final Uri uri;

  /// Opens in the browser (said to screen readers), rather than in the dialer or mail app.
  final bool external;

  Future<void> _open(BuildContext context) async {
    final opened = await launchUrl(
      uri,
      mode: external ? LaunchMode.externalApplication : LaunchMode.platformDefault,
    );
    if (!opened && context.mounted) {
      showToast(context, context.l10n.commonNotAvailable, tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    hint: external ? context.l10n.campusSignInHelpOpensExternally : null,
    child: TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
      onPressed: () => _open(context),
      iconAlignment: external ? IconAlignment.end : IconAlignment.start,
      icon: Icon(icon, size: 14),
      label: Text(label),
    ),
  );
}
