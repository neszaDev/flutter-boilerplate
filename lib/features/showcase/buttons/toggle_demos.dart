import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Toggle heights, one step up from the web's 28–36 px like the buttons.
enum ToggleSize {
  sm(height: 32, fontSize: 13),
  normal(height: 36, fontSize: 14),
  lg(height: 44, fontSize: 14);

  const ToggleSize({required this.height, required this.fontSize});

  final double height;
  final double fontSize;
}

/// A button that stays pressed (the web's `Toggle`): it rests like a ghost button, or with a
/// border when [outline], and fills with ink while [pressed].
class DemoToggle extends StatelessWidget {
  const DemoToggle({
    required this.label,
    required this.pressed,
    required this.onChanged,
    this.outline = false,
    this.size = ToggleSize.normal,
    super.key,
  });

  final String label;
  final bool pressed;
  final ValueChanged<bool> onChanged;
  final bool outline;
  final ToggleSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(size.height, size.height)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
      textStyle: WidgetStatePropertyAll(context.text.labelLarge?.copyWith(fontSize: size.fontSize)),
      foregroundColor: WidgetStatePropertyAll(pressed ? colors.ink950 : colors.ink700),
      backgroundColor: WidgetStatePropertyAll(
        pressed ? colors.ink100 : (outline ? colors.ply : Colors.transparent),
      ),
      side: WidgetStatePropertyAll(outline ? BorderSide(color: colors.ink300) : BorderSide.none),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      ),
    );
    void toggle() {
      Haptics.selection();
      onChanged(!pressed);
    }

    final child = Text(label);
    return MergeSemantics(
      child: Semantics(
        toggled: pressed,
        child: outline
            ? OutlinedButton(onPressed: toggle, style: style, child: child)
            : TextButton(onPressed: toggle, style: style, child: child),
      ),
    );
  }
}

/// Six toggles bound to one pressed state, like the Vue `:pressed.sync` example: pressing any
/// of them flips all of them.
class TogglePressedDemo extends StatefulWidget {
  const TogglePressedDemo({super.key});

  static const _toggles = [
    (outline: true, size: ToggleSize.sm),
    (outline: true, size: ToggleSize.normal),
    (outline: true, size: ToggleSize.lg),
    (outline: false, size: ToggleSize.sm),
    (outline: false, size: ToggleSize.normal),
    (outline: false, size: ToggleSize.lg),
  ];

  @override
  State<TogglePressedDemo> createState() => _TogglePressedDemoState();
}

class _TogglePressedDemoState extends State<TogglePressedDemo> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = _pressed ? l10n.togglePressedDemoOn : l10n.togglePressedDemoOff;
    return Wrap(
      spacing: Space.md,
      runSpacing: Space.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final toggle in TogglePressedDemo._toggles)
          DemoToggle(
            outline: toggle.outline,
            size: toggle.size,
            pressed: _pressed,
            onChanged: (pressed) => setState(() => _pressed = pressed),
            label: () {
              final size = switch (toggle.size) {
                ToggleSize.sm => l10n.togglePressedDemoSizeSm,
                ToggleSize.normal => l10n.togglePressedDemoSizeDefault,
                ToggleSize.lg => l10n.togglePressedDemoSizeLg,
              };
              return toggle.outline
                  ? l10n.togglePressedDemoOutlineLabel(size, state)
                  : l10n.togglePressedDemoPlainLabel(size, state);
            }(),
          ),
      ],
    );
  }
}

/// A button that shows a spinner and stays disabled while its (simulated) work runs.
class LoadingButtonDemo extends StatefulWidget {
  const LoadingButtonDemo({super.key});

  /// How long the simulated save takes.
  static const saveDuration = Duration(seconds: 2);

  @override
  State<LoadingButtonDemo> createState() => _LoadingButtonDemoState();
}

class _LoadingButtonDemoState extends State<LoadingButtonDemo> {
  Timer? _timer;

  bool get _saving => _timer?.isActive ?? false;

  void _save() {
    setState(() {
      _timer = Timer(LoadingButtonDemo.saveDuration, () {
        if (mounted) {
          setState(() => _timer = null);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BusyButton(
      label: _saving ? l10n.loadingButtonDemoSaving : l10n.loadingButtonDemoSave,
      busy: _saving,
      icon: LucideIcons.save,
      onPressed: _save,
    );
  }
}
