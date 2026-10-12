import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// A scanned value is a link worth offering to open (only web links; never `javascript:` or
/// app schemes from an unknown code).
Uri? linkIn(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty
      ? uri
      : null;
}

/// `/dashboard/device/scanner`: scan QR codes and barcodes, and make a QR code.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  late final _text = TextEditingController(text: '');
  Barcode? _last;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      _initialised = true;
      _text.text = context.l10n.scannerPageMakeDefault;
    }
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    _text.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null || barcode!.rawValue == _last?.rawValue) {
      return;
    }
    Haptics.success();
    setState(() => _last = barcode);
  }

  Future<void> _open(Uri link) async {
    final l10n = context.l10n;
    // A code can carry any link: show it before leaving the app.
    final go = await confirm(
      context,
      title: l10n.scannerPageOpenConfirmTitle,
      text: link.toString(),
      confirmLabel: l10n.scannerPageOpenConfirmOk,
      cancelLabel: l10n.commonCancel,
      destructive: false,
    );
    if (go && !await launchUrl(link, mode: LaunchMode.externalApplication) && mounted) {
      showToast(context, l10n.sharePageCantOpen, tone: ToastTone.error);
    }
  }

  Widget _error(BuildContext context, MobileScannerException error) {
    final l10n = context.l10n;
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied => l10n.scannerPageErrorPermission,
      MobileScannerErrorCode.unsupported => l10n.scannerPageErrorUnsupported,
      _ => l10n.scannerPageErrorGeneric,
    };
    return ColoredBox(
      color: context.colors.ink950,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(color: context.colors.paper),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final last = _last;
    final value = last?.rawValue;
    final link = value == null ? null : linkIn(value);

    return AppPage(
      title: l10n.scannerPageTitle,
      description: Text(l10n.scannerPageDescription),
      children: [
        DemoCard(
          title: l10n.scannerPageScanTitle,
          padding: EdgeInsets.zero,
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: l10n.scannerPageTorch,
                icon: const Icon(Icons.flashlight_on_outlined),
                onPressed: _controller.toggleTorch,
              ),
              IconButton(
                tooltip: l10n.scannerPageSwitchCamera,
                icon: const Icon(Icons.cameraswitch_outlined),
                onPressed: _controller.switchCamera,
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: _error,
            ),
          ),
        ),
        DemoCard(
          title: l10n.scannerPageResultTitle,
          child: last == null || value == null
              ? Text(l10n.scannerPageEmpty, style: context.text.bodyMedium)
              : Semantics(
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(value, style: context.text.titleMedium),
                      const SizedBox(height: Space.xs),
                      Text(l10n.scannerPageFormat(last.format.name), style: context.text.bodySmall),
                      const SizedBox(height: Space.md),
                      Wrap(
                        spacing: Space.sm,
                        runSpacing: Space.sm,
                        children: [
                          if (link != null)
                            FilledButton.icon(
                              onPressed: () => _open(link),
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: Text(l10n.scannerPageOpenLink),
                            ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: value));
                              if (context.mounted) {
                                showToast(context, l10n.commonCopied, tone: ToastTone.success);
                              }
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: Text(l10n.commonCopy),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
        DemoCard(
          title: l10n.scannerPageMakeTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _text,
                // A QR code holds at most 2953 bytes; 700 characters fit even at 4 bytes each.
                maxLength: 700,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.scannerPageMakeLabel),
              ),
              const SizedBox(height: Space.page),
              if (_text.text.isNotEmpty)
                Center(
                  child: Semantics(
                    label: l10n.scannerPageMakeSemantics(_text.text),
                    child: Container(
                      // Scanners need dark modules on a light ground, in both themes.
                      color: Colors.white,
                      padding: const EdgeInsets.all(Space.md),
                      child: QrImageView(data: _text.text, size: 200),
                    ),
                  ),
                ),
              const SizedBox(height: Space.page),
              OutlinedButton.icon(
                onPressed: _text.text.isEmpty
                    ? null
                    : () => SharePlus.instance.share(ShareParams(text: _text.text)),
                icon: const Icon(Icons.ios_share, size: 18),
                label: Text(l10n.commonShare),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
