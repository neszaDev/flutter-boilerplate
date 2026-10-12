import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/marketing/marketing_screens.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// `/dashboard/device/share`: the share sheet, links, email, calls, texts and the clipboard.
class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  static final _email = Uri(scheme: 'mailto', path: 'hello@example.com');
  static final _phone = Uri(scheme: 'tel', path: '+15555550100');
  static final _sms = Uri(scheme: 'sms', path: '+15555550100');

  Future<void> _launch(BuildContext context, Uri uri, {LaunchMode? mode}) async {
    final opened = await launchUrl(uri, mode: mode ?? LaunchMode.platformDefault);
    if (!opened && context.mounted) {
      showToast(context, context.l10n.sharePageCantOpen, tone: ToastTone.error);
    }
  }

  /// Where the iPad share popover points.
  Rect? _origin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget action(IconData icon, String label, VoidCallback onPressed) => Builder(
      builder: (context) => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );

    Widget column(List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(height: Space.sm),
          child,
        ],
      ],
    );

    return AppPage(
      title: l10n.sharePageTitle,
      description: Text(l10n.sharePageDescription),
      children: [
        DemoCard(
          title: l10n.sharePageShareTitle,
          child: column([
            Builder(
              builder: (context) => FilledButton.icon(
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    text: l10n.sharePageShareTextValue,
                    sharePositionOrigin: _origin(context),
                  ),
                ),
                icon: const Icon(Icons.ios_share, size: 18),
                label: Text(l10n.sharePageShareText),
              ),
            ),
            Builder(
              builder: (context) => OutlinedButton.icon(
                onPressed: () => SharePlus.instance.share(
                  ShareParams(uri: webBoilerplateUrl, sharePositionOrigin: _origin(context)),
                ),
                icon: const Icon(Icons.link, size: 18),
                label: Text(l10n.sharePageShareLink),
              ),
            ),
          ]),
        ),
        DemoCard(
          title: l10n.sharePageOpenTitle,
          child: column([
            action(
              Icons.open_in_browser,
              l10n.sharePageBrowser,
              () => _launch(context, webBoilerplateUrl, mode: LaunchMode.externalApplication),
            ),
            action(
              Icons.web,
              l10n.sharePageInApp,
              () => _launch(context, webBoilerplateUrl, mode: LaunchMode.inAppBrowserView),
            ),
            action(Icons.mail_outline, l10n.sharePageEmail, () => _launch(context, _email)),
            action(Icons.call_outlined, l10n.sharePageCall, () => _launch(context, _phone)),
            action(Icons.sms_outlined, l10n.sharePageSms, () => _launch(context, _sms)),
          ]),
        ),
        DemoCard(
          title: l10n.sharePageClipboardTitle,
          child: column([
            action(Icons.copy, l10n.sharePageCopy, () async {
              await Clipboard.setData(ClipboardData(text: l10n.sharePageShareTextValue));
              if (context.mounted) {
                showToast(context, l10n.sharePageCopied, tone: ToastTone.success);
              }
            }),
            action(Icons.paste, l10n.sharePagePaste, () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (!context.mounted) {
                return;
              }
              final text = data?.text;
              showToast(
                context,
                text == null || text.isEmpty
                    ? l10n.sharePageClipboardEmpty
                    : l10n.sharePagePasted(text),
              );
            }),
          ]),
        ),
      ],
    );
  }
}
