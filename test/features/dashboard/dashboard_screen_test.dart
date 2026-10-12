import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/features/dashboard/dashboard_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_backend.dart';
import '../../helpers/test_app.dart';

class _SignedInSession extends SessionController {
  @override
  SessionState build() => const SignedIn(UserProfile(id: 1, email: 'ada@example.com'));
}

void main() {
  group('DashboardScreen', () {
    testWidgets('pull to refresh survives a failing backend and shows the error', (tester) async {
      final l10n = await englishStrings();
      await pumpScreen(
        tester,
        const DashboardScreen(),
        overrides: [
          sessionProvider.overrideWith(_SignedInSession.new),
          httpClientAdapterProvider.overrideWithValue(
            FakeBackend((_) async => reply(503, {'status': 503, 'message': 'Down'})),
          ),
        ],
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.text(l10n.errorPageTitle), findsOneWidget);
    });
  });
}
