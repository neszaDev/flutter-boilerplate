import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_boilerplate/features/showcase/campus/labels.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

const _qrSize = 200.0;
const _badgeSize = 50.0;

/// Scanners need dark modules on a light ground, so the code keeps the daylight palette in the
/// dark theme too.
const _paper = MarksheetColors.light;

/// The level-H code for [text], or null when the text doesn't fit in a QR code.
QrCode? qrCodeFor(String text) {
  try {
    final code = QrCode.fromData(data: text, errorCorrectLevel: QrErrorCorrectLevel.H);
    // Laying the modules out is what finds data that doesn't fit; the package's own validator
    // and QrImageView only find out while painting.
    QrImage(code);
    return code;
  } on InputTooLongException {
    return null;
  }
}

/// The campus QR code card (Vue `QRCodes`): a level-H code with a campus badge in a red-ringed
/// circle, a label under it, fields to change both, and the share sheet for the code as a PNG
/// (save it to Photos from there) or for its content. "Scan a code" opens the phone's scanner.
class QrCodeCard extends StatefulWidget {
  const QrCodeCard({super.key});

  @override
  State<QrCodeCard> createState() => _QrCodeCardState();
}

class _QrCodeCardState extends State<QrCodeCard> {
  final _text = TextEditingController(text: qrDefaults.text);
  final _label = TextEditingController(text: qrDefaults.label);
  final _code = GlobalKey();

  @override
  void dispose() {
    _text.dispose();
    _label.dispose();
    super.dispose();
  }

  /// Where the share sheet points from on iPad.
  Rect? _origin(BuildContext context) {
    final box = context.findRenderObject();
    return box is RenderBox && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
  }

  /// Shares the code as it shows on screen, badge included, as `qr-code-<label>.png`.
  Future<void> _shareImage(BuildContext button) async {
    final origin = _origin(button);
    final boundary = _code.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      return;
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) {
      if (mounted) {
        showToast(context, context.l10n.commonErrorGeneric, tone: ToastTone.error);
      }
      return;
    }
    final name = qrFileName(_label.text);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(data.buffer.asUint8List(), mimeType: 'image/png', name: name)],
        fileNameOverrides: [name],
        sharePositionOrigin: origin,
      ),
    );
  }

  Future<void> _shareText(BuildContext button) => SharePlus.instance.share(
    ShareParams(
      text: _text.text,
      subject: _label.text.trim().isEmpty ? null : _label.text,
      sharePositionOrigin: _origin(button),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: Listenable.merge([_text, _label]),
      builder: (context, _) {
        final text = _text.text;
        final code = qrCodeFor(text);
        final empty = text.isEmpty;
        return SheetCard(
          title: l10n.campusQrCodeTitle,
          action: Builder(
            builder: (button) => IconButton.filled(
              tooltip: l10n.campusQrCodeShareImage,
              onPressed: empty || code == null ? null : () => _shareImage(button),
              icon: const Icon(LucideIcons.imageDown, size: 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: DecoratedBox(
                  // Around the shared image, not in it.
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Radii.sm),
                    border: Border.all(color: context.colors.ink200),
                  ),
                  child: RepaintBoundary(
                    key: _code,
                    child: _CodeTile(text: text, code: code),
                  ),
                ),
              ),
              const SizedBox(height: Space.md),
              Text(
                _label.text,
                textAlign: TextAlign.center,
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: Space.lg),
              _Field(label: l10n.campusQrCodeTextLabel, controller: _text, multiline: true),
              const SizedBox(height: Space.page),
              _Field(label: l10n.campusQrCodeLabelLabel, controller: _label),
              const SizedBox(height: Space.lg),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  Builder(
                    builder: (button) => OutlinedButton.icon(
                      onPressed: empty ? null : () => _shareText(button),
                      icon: const Icon(LucideIcons.share2, size: 18),
                      label: Text(l10n.campusQrCodeShareText),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push<void>(Routes.deviceScanner),
                    icon: const Icon(LucideIcons.scanQrCode, size: 18),
                    label: Text(l10n.campusQrCodeScan),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The code on a white tile with the badge in its centre, or why there is no code.
class _CodeTile extends StatelessWidget {
  const _CodeTile({required this.text, required this.code});

  final String text;

  /// Null when [text] doesn't fit in a QR code.
  final QrCode? code;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: _paper.ply,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: switch (code) {
        null => SizedBox.square(
          dimension: _qrSize,
          child: Center(
            child: Semantics(
              container: true,
              liveRegion: true,
              child: Text(
                l10n.campusQrCodeTooLong,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: _paper.pen),
              ),
            ),
          ),
        ),
        final code => Stack(
          alignment: Alignment.center,
          children: [
            // The package labels the code without a node of its own; give it one.
            Semantics(
              container: true,
              image: true,
              child: QrImageView.withQr(
                qr: code,
                size: _qrSize,
                padding: const EdgeInsets.all(Space.sm),
                backgroundColor: _paper.ply,
                eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: _paper.ink950),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: _paper.ink950,
                ),
                semanticsLabel: l10n.campusQrCodeCodeAlt(text),
              ),
            ),
            ExcludeSemantics(
              child: Container(
                width: _badgeSize,
                height: _badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _paper.ply,
                  border: Border.all(color: _paper.pen, width: 3),
                ),
                child: Icon(LucideIcons.graduationCap, size: 26, color: _paper.folder),
              ),
            ),
          ],
        ),
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, this.multiline = false});

  final String label;
  final TextEditingController controller;
  final bool multiline;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ExcludeSemantics(child: Text(label, style: context.text.titleSmall)),
      ),
      Semantics(
        label: label,
        child: TextField(
          controller: controller,
          minLines: 1,
          maxLines: multiline ? 4 : 1,
          keyboardType: multiline ? TextInputType.url : TextInputType.text,
          autocorrect: !multiline,
        ),
      ),
    ],
  );
}
