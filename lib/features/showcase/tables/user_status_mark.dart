import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_boilerplate/features/showcase/tables/users_data.dart';

/// The localized name of a [UserStatus].
String userStatusName(AppLocalizations l10n, UserStatus status) => switch (status) {
  UserStatus.active => l10n.usersTableStatusActive,
  UserStatus.inactive => l10n.usersTableStatusInactive,
  UserStatus.pending => l10n.usersTableStatusPending,
  UserStatus.banned => l10n.usersTableStatusBanned,
};

/// The localized name of a [UserRole].
String userRoleName(AppLocalizations l10n, UserRole role) => switch (role) {
  UserRole.member => l10n.usersTableRoleMember,
  UserRole.staff => l10n.usersTableRoleStaff,
  UserRole.admin => l10n.usersTableRoleAdmin,
};

/// A user's account status as a drawn mark plus its name (the Vue status badge): a tick for
/// active, the pen circle for banned, the pencil box for pending, a plain dash for inactive.
/// Status is a mark, never a pill.
class UserStatusMark extends StatelessWidget {
  const UserStatusMark({required this.status, this.color, super.key});

  final UserStatus status;

  /// Prints mark and name in this colour (a table on the folder green).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mark = switch (status) {
      UserStatus.active => TestStatus.passed,
      UserStatus.banned => TestStatus.failed,
      UserStatus.pending => TestStatus.pending,
      UserStatus.inactive => null,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mark == null)
          ExcludeSemantics(
            child: CustomPaint(
              size: const Size.square(20),
              painter: _DashPainter(color ?? colors.ink400),
            ),
          )
        else
          Mark(status: mark, color: color),
        const SizedBox(width: Space.sm),
        Flexible(
          child: Text(
            userStatusName(context.l10n, status),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color ?? (status == UserStatus.banned ? colors.pen : colors.ink700),
            ),
          ),
        ),
      ],
    );
  }
}

/// The pencil dash of an inactive account (`M5 12.4c4.6-.5 9.3-.6 14 .1` on a 24 grid).
class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas
      ..save()
      ..scale(scale);
    final path = Path()
      ..moveTo(5, 12.4)
      ..relativeCubicTo(4.6, -0.5, 9.3, -0.6, 14, 0.1);
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}
