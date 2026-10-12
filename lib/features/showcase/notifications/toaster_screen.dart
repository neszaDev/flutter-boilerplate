import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/device/notifications.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/notifications/phone_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final _log = appLogger('showcase.toaster');

/// Where a toast shows: in the page, or floating over the screen.
enum ToastPosition {
  inPage(Alignment.topCenter),
  topLeft(Alignment.topLeft),
  topCenter(Alignment.topCenter),
  topRight(Alignment.topRight),
  topFull(Alignment.topCenter),
  bottomLeft(Alignment.bottomLeft),
  bottomCenter(Alignment.bottomCenter),
  bottomRight(Alignment.bottomRight),
  bottomFull(Alignment.bottomCenter);

  const ToastPosition(this.alignment);

  final Alignment alignment;

  bool get isTop => alignment.y < 0;

  bool get isFullWidth => this == topFull || this == bottomFull;
}

String _positionLabel(AppLocalizations l10n, ToastPosition position) => switch (position) {
  ToastPosition.inPage => l10n.toasterPagePositionStatic,
  ToastPosition.topLeft => l10n.toasterPagePositionTopLeft,
  ToastPosition.topCenter => l10n.toasterPagePositionTopCenter,
  ToastPosition.topRight => l10n.toasterPagePositionTopRight,
  ToastPosition.topFull => l10n.toasterPagePositionTopFull,
  ToastPosition.bottomLeft => l10n.toasterPagePositionBottomLeft,
  ToastPosition.bottomCenter => l10n.toasterPagePositionBottomCenter,
  ToastPosition.bottomRight => l10n.toasterPagePositionBottomRight,
  ToastPosition.bottomFull => l10n.toasterPagePositionBottomFull,
};

/// How long a toast stays: the typed milliseconds when hiding is on and the number is
/// positive, else null (until closed).
Duration? autohideDelay({required bool enabled, required String milliseconds}) {
  final value = int.tryParse(milliseconds.trim()) ?? 0;
  return enabled && value > 0 ? Duration(milliseconds: value) : null;
}

/// The phone's notification service; overridden in tests.
final phoneNotifierProvider = Provider<PhoneNotifier>((ref) => const LocalPhoneNotifier());

/// [PhoneNotifier] on [LocalNotifications]. Every demo notification has the same id, so a new
/// one replaces the last (the web demo's `tag`).
class LocalPhoneNotifier implements PhoneNotifier {
  const LocalPhoneNotifier();

  static const _id = 4101;

  @override
  Future<bool> requestPermission() => LocalNotifications.instance.requestPermission();

  @override
  Future<bool> show({
    required String title,
    required String body,
    required String channel,
    Duration? delay,
  }) async {
    try {
      if (delay == null) {
        await LocalNotifications.instance.show(
          id: _id,
          title: title,
          body: body,
          channelName: channel,
        );
      } else {
        await LocalNotifications.instance.schedule(
          id: _id,
          title: title,
          body: body,
          delay: delay,
          channelName: channel,
        );
      }
      return true;
    } on PlatformException catch (error) {
      _log.warning('Demo notification refused', error);
      return false;
    } on MissingPluginException catch (error) {
      _log.warning('Notifications unavailable', error);
      return false;
    }
  }
}

/// One toast and the options it was added with.
@immutable
class _Toast {
  const _Toast({
    required this.id,
    required this.title,
    required this.body,
    required this.position,
    this.closeButton = true,
    this.fade = true,
    this.autohide,
  });

  final int id;
  final String title;
  final String body;
  final ToastPosition position;
  final bool closeButton;
  final bool fade;

  /// Null: stays until closed.
  final Duration? autohide;
}

const _notifyLater = Duration(seconds: 5);

/// `/dashboard/notifications/toaster`: set the options, then add toasts in the page or
/// floating over the screen; the phone's snack bars; and a real phone notification.
class ToasterScreen extends ConsumerStatefulWidget {
  const ToasterScreen({super.key});

  @override
  ConsumerState<ToasterScreen> createState() => _ToasterScreenState();
}

class _ToasterScreenState extends ConsumerState<ToasterScreen> {
  final _autohideMs = TextEditingController(text: '5000');
  final _title = TextEditingController();
  final _body = TextEditingController();
  var _autohide = true;
  var _position = ToastPosition.topRight;
  var _fade = true;
  var _closeButton = true;
  final _counts = <ToastPosition, int>{ToastPosition.inPage: 2};
  final _inPage = <_Toast>[];
  final _floating = <_Toast>[];
  var _nextId = 1;
  var _initialized = false;
  var _sending = false;
  PhoneNotificationResult? _notification;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    final l10n = context.l10n;
    _title.text = l10n.toasterPageDefaultTitle;
    for (final number in [1, 2]) {
      _inPage.add(
        _Toast(
          id: _nextId++,
          title: l10n.toasterPageDefaultTitle,
          body: l10n.toasterPageGeneratedBody(
            '$number',
            _positionLabel(l10n, ToastPosition.inPage),
          ),
          position: ToastPosition.inPage,
        ),
      );
    }
  }

  @override
  void dispose() {
    _autohideMs.dispose();
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _add() {
    final l10n = context.l10n;
    final number = (_counts[_position] ?? 0) + 1;
    final title = _title.text.trim();
    final body = _body.text.trim();
    final toast = _Toast(
      id: _nextId++,
      title: title.isEmpty ? l10n.toasterPageDefaultTitle : title,
      body: body.isEmpty
          ? l10n.toasterPageGeneratedBody('$number', _positionLabel(l10n, _position))
          : body,
      position: _position,
      closeButton: _closeButton,
      fade: _fade,
      autohide: autohideDelay(enabled: _autohide, milliseconds: _autohideMs.text),
    );
    // Put the keyboard away so the toasts at the bottom can be seen.
    FocusScope.of(context).unfocus();
    setState(() {
      _counts[_position] = number;
      (toast.position == ToastPosition.inPage ? _inPage : _floating).add(toast);
    });
  }

  void _remove(int id) => setState(() {
    _inPage.removeWhere((toast) => toast.id == id);
    _floating.removeWhere((toast) => toast.id == id);
  });

  Future<void> _notify({Duration? delay}) async {
    final l10n = context.l10n;
    final title = _title.text.trim();
    final body = _body.text.trim();
    setState(() => _sending = true);
    final result = await sendPhoneNotification(
      ref.read(phoneNotifierProvider),
      title: title.isEmpty ? l10n.toasterPageDefaultTitle : title,
      body: body.isEmpty ? l10n.toasterPagePhoneBody : body,
      channel: l10n.toasterPagePhoneChannel,
      delay: delay,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _sending = false;
      _notification = result;
    });
  }

  String _notificationText(AppLocalizations l10n) => switch (_notification) {
    null => '',
    PhoneNotificationResult.shown => l10n.toasterPagePhoneShown,
    PhoneNotificationResult.scheduled => l10n.toasterPagePhoneScheduled,
    PhoneNotificationResult.denied => l10n.toasterPagePhoneDenied,
    PhoneNotificationResult.unsupported => l10n.toasterPagePhoneUnsupported,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final page = AppPage(
      title: l10n.toasterPageTitle,
      description: Text(l10n.toasterPageDescription),
      children: [
        DemoCard(
          title: l10n.toasterPageCardTitle,
          description: l10n.toasterPageCardDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(l10n.toasterPageFormTitle, style: context.text.titleMedium),
              ),
              const SizedBox(height: Space.sm),
              _CheckRow(
                label: l10n.toasterPageAutohide,
                value: _autohide,
                onChanged: (value) => setState(() => _autohide = value),
              ),
              if (_autohide) ...[
                const SizedBox(height: Space.sm),
                _Field(
                  label: l10n.toasterPageAutohideMs,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 160,
                      child: TextField(
                        key: const Key('toaster.autohideMs'),
                        controller: _autohideMs,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: context.type.table.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: Space.page),
              _Field(
                label: l10n.toasterPagePosition,
                child: DropdownButtonFormField<ToastPosition>(
                  key: const Key('toaster.position'),
                  initialValue: _position,
                  isExpanded: true,
                  items: [
                    for (final position in ToastPosition.values)
                      DropdownMenuItem(
                        value: position,
                        child: Text(_positionLabel(l10n, position)),
                      ),
                  ],
                  onChanged: (position) {
                    if (position != null) {
                      setState(() => _position = position);
                    }
                  },
                ),
              ),
              const SizedBox(height: Space.sm),
              _CheckRow(
                label: l10n.toasterPageFade,
                value: _fade,
                onChanged: (value) => setState(() => _fade = value),
              ),
              _CheckRow(
                label: l10n.toasterPageCloseButton,
                value: _closeButton,
                onChanged: (value) => setState(() => _closeButton = value),
              ),
              const SizedBox(height: Space.sm),
              _Field(
                label: l10n.toasterPageToastTitle,
                child: TextField(
                  key: const Key('toaster.title'),
                  controller: _title,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(height: Space.page),
              _Field(
                label: l10n.toasterPageToastBody,
                child: TextField(
                  key: const Key('toaster.body'),
                  controller: _body,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: l10n.toasterPageToastBodyPlaceholder),
                ),
              ),
              const SizedBox(height: Space.card),
              Divider(color: colors.ink200),
              const SizedBox(height: Space.card),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  FilledButton(onPressed: _add, child: Text(l10n.toasterPageAddToast)),
                  OutlinedButton.icon(
                    onPressed: _sending ? null : () => unawaited(_notify()),
                    icon: const Icon(LucideIcons.bellRing, size: 18),
                    label: Text(l10n.toasterPagePhone),
                  ),
                  OutlinedButton.icon(
                    onPressed: _sending ? null : () => unawaited(_notify(delay: _notifyLater)),
                    icon: const Icon(LucideIcons.clock, size: 18),
                    label: Text(l10n.toasterPagePhoneLater),
                  ),
                ],
              ),
              const SizedBox(height: Space.sm),
              Semantics(
                container: true,
                liveRegion: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 20),
                  child: Text(_notificationText(l10n), style: context.text.bodySmall),
                ),
              ),
              const SizedBox(height: Space.lg),
              _InPageToasts(toasts: _inPage, onRemoved: _remove),
            ],
          ),
        ),
        DemoCard(
          title: l10n.toasterPageSnackbarTitle,
          description: l10n.toasterPageSnackbarDescription,
          child: Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              OutlinedButton(
                onPressed: () => showToast(context, l10n.toasterPageSnackbarNeutralMessage),
                child: Text(l10n.toasterPageSnackbarNeutral),
              ),
              OutlinedButton(
                onPressed: () => showToast(
                  context,
                  l10n.toasterPageSnackbarSuccessMessage,
                  tone: ToastTone.success,
                ),
                child: Text(l10n.toasterPageSnackbarSuccess),
              ),
              OutlinedButton(
                onPressed: () => showToast(
                  context,
                  l10n.toasterPageSnackbarErrorMessage,
                  tone: ToastTone.error,
                ),
                child: Text(l10n.toasterPageSnackbarError),
              ),
            ],
          ),
        ),
      ],
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        page,
        _FloatingToasts(toasts: _floating, onRemoved: _remove),
      ],
    );
  }
}

/// A printed label above a control, read together with it.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label, style: context.text.titleSmall),
        ),
        child,
      ],
    ),
  );
}

/// A checkbox with its label, the whole row tappable.
class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: value,
    onChanged: (checked) => onChanged(checked ?? false),
    title: Text(label, style: context.text.bodyMedium),
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
  );
}

/// The "static" toasts, drawn in the page.
class _InPageToasts extends StatelessWidget {
  const _InPageToasts({required this.toasts, required this.onRemoved});

  final List<_Toast> toasts;
  final ValueChanged<int> onRemoved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const Key('toaster.static'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.toasterPageStaticTitle, style: context.text.titleMedium),
        ),
        const SizedBox(height: Space.md),
        if (toasts.isEmpty)
          Text(l10n.toasterPageStaticEmpty, style: context.text.bodySmall)
        else
          for (final (index, toast) in toasts.indexed) ...[
            if (index > 0) const SizedBox(height: Space.md),
            _ToastCard(
              key: ValueKey(toast.id),
              toast: toast,
              onRemoved: () => onRemoved(toast.id),
            ),
          ],
      ],
    );
  }
}

/// The floating toasts, over the whole screen: each position stacks its own, newest nearest
/// the edge, at most three at a time. Taps between toasts reach the page.
class _FloatingToasts extends StatelessWidget {
  const _FloatingToasts({required this.toasts, required this.onRemoved});

  final List<_Toast> toasts;
  final ValueChanged<int> onRemoved;

  static const _visible = 3;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        // Top toasts start under the app bar, so they never cover the back button.
        padding: EdgeInsets.fromLTRB(
          Space.page,
          kToolbarHeight + Space.sm,
          Space.page,
          Space.page + keyboard,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = math.min(320.0, constraints.maxWidth * 0.8);
            return Stack(
              children: [
                for (final position in ToastPosition.values)
                  if (toasts.any((toast) => toast.position == position))
                    Align(
                      alignment: position.alignment,
                      child: SizedBox(
                        width: position.isFullWidth ? constraints.maxWidth : narrow,
                        child: _group(position),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _group(ToastPosition position) {
    final mine = toasts.where((toast) => toast.position == position).toList();
    final shown = mine.sublist(math.max(0, mine.length - _visible));
    final ordered = position.isTop ? shown.reversed.toList() : shown;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, toast) in ordered.indexed) ...[
          if (index > 0) const SizedBox(height: Space.sm),
          _ToastCard(
            key: ValueKey(toast.id),
            toast: toast,
            floating: true,
            onRemoved: () => onRemoved(toast.id),
          ),
        ],
      ],
    );
  }
}

/// One toast: title, optional close button and body, announced when it appears. It fades in
/// and out when asked (not under reduced motion), hides itself after its delay, and can be
/// swiped away.
class _ToastCard extends StatefulWidget {
  const _ToastCard({
    required this.toast,
    required this.onRemoved,
    this.floating = false,
    super.key,
  });

  final _Toast toast;
  final VoidCallback onRemoved;
  final bool floating;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late final _opacity = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  Timer? _timer;
  var _animate = false;
  var _started = false;
  var _closing = false;

  @override
  void initState() {
    super.initState();
    final delay = widget.toast.autohide;
    if (delay != null) {
      _timer = Timer(delay, () => unawaited(_close()));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    _animate = widget.toast.fade && !MediaQuery.disableAnimationsOf(context);
    if (_animate) {
      unawaited(_opacity.forward());
    } else {
      _opacity.value = 1;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _opacity.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing) {
      return;
    }
    _closing = true;
    _timer?.cancel();
    if (_animate) {
      await _opacity.reverse();
    }
    if (mounted) {
      widget.onRemoved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final toast = widget.toast;
    return FadeTransition(
      opacity: _opacity,
      child: Dismissible(
        key: ValueKey('dismiss-${toast.id}'),
        onDismissed: (_) => widget.onRemoved(),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Material(
            color: colors.ply,
            elevation: widget.floating ? 6 : 1,
            shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.md),
              side: BorderSide(color: colors.ink200),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Space.md,
                    toast.closeButton ? 0 : 10,
                    0,
                    toast.closeButton ? 0 : 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          toast.title,
                          style: context.text.titleSmall?.copyWith(color: colors.ink950),
                        ),
                      ),
                      if (toast.closeButton)
                        IconButton(
                          tooltip: context.l10n.toasterPageClose,
                          onPressed: () => unawaited(_close()),
                          icon: const Icon(LucideIcons.x, size: 16),
                        ),
                    ],
                  ),
                ),
                Divider(color: colors.ink200),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Space.md, 10, Space.md, Space.md),
                  child: Text(
                    toast.body,
                    style: context.text.bodyMedium?.copyWith(color: colors.ink700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
