import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/notifications.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';

/// `/dashboard/device/notifications`: local notifications now or in five seconds.
class DeviceNotificationsScreen extends StatefulWidget {
  const DeviceNotificationsScreen({super.key});

  @override
  State<DeviceNotificationsScreen> createState() => _DeviceNotificationsScreenState();
}

class _DeviceNotificationsScreenState extends State<DeviceNotificationsScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  int _nextId = 1;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      _initialised = true;
      _title.text = context.l10n.deviceNotificationsPageDefaultTitle;
      _body.text = context.l10n.deviceNotificationsPageDefaultBody;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send({required bool later}) async {
    final l10n = context.l10n;
    final notifications = LocalNotifications.instance;
    if (!notifications.isAvailable) {
      showToast(context, l10n.commonNotAvailable, tone: ToastTone.error);
      return;
    }
    if (!await notifications.requestPermission()) {
      if (mounted) {
        showToast(context, l10n.deviceNotificationsPageDenied, tone: ToastTone.error);
      }
      return;
    }
    final id = _nextId++;
    if (later) {
      await notifications.schedule(
        id: id,
        title: _title.text,
        body: _body.text,
        delay: const Duration(seconds: 5),
        channelName: l10n.deviceNotificationsPageChannelName,
        channelDescription: l10n.deviceNotificationsPageChannelDescription,
      );
    } else {
      await notifications.show(
        id: id,
        title: _title.text,
        body: _body.text,
        channelName: l10n.deviceNotificationsPageChannelName,
        channelDescription: l10n.deviceNotificationsPageChannelDescription,
      );
    }
    if (mounted) {
      showToast(
        context,
        later ? l10n.deviceNotificationsPageScheduled : l10n.deviceNotificationsPageSent,
        tone: ToastTone.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.deviceNotificationsPageTitle,
      description: Text(l10n.deviceNotificationsPageDescription),
      children: [
        DemoCard(
          title: l10n.deviceNotificationsPageTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabeledField(
                label: l10n.deviceNotificationsPageTitleLabel,
                child: TextField(controller: _title, textInputAction: TextInputAction.next),
              ),
              const SizedBox(height: Space.page),
              LabeledField(
                label: l10n.deviceNotificationsPageBodyLabel,
                child: TextField(controller: _body, minLines: 2, maxLines: 4),
              ),
              const SizedBox(height: Space.lg),
              FilledButton.icon(
                onPressed: () => _send(later: false),
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: Text(l10n.deviceNotificationsPageNow),
              ),
              const SizedBox(height: Space.sm),
              OutlinedButton.icon(
                onPressed: () => _send(later: true),
                icon: const Icon(Icons.schedule, size: 18),
                label: Text(l10n.deviceNotificationsPageLater),
              ),
              const SizedBox(height: Space.sm),
              Text(l10n.deviceNotificationsPageLaterHint, style: context.text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
