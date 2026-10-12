import 'package:flutter/painting.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/utils/file_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RichMessage.spans', () {
    test('styles tagged parts and keeps the rest as text', () {
      final spans = RichMessage.spans('Based on <upstream>Next.js</upstream> by ixartz.', {
        'upstream': (text) => TextSpan(text: text.toUpperCase()),
      });

      expect(spans.map((span) => (span as TextSpan).text), ['Based on ', 'NEXT.JS', ' by ixartz.']);
    });

    test('renders unknown tags as plain text', () {
      final spans = RichMessage.spans('A <b>bold</b> move', const {});

      expect(spans.map((span) => (span as TextSpan).text).join(), 'A bold move');
    });
  });

  group('generated messages', () {
    test('use the French plural rules', () async {
      final fr = await AppLocalizations.delegate.load(const Locale('fr'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(en.authFormErrorRateLimited(1), 'Too many attempts. Try again in 1 minute.');
      expect(en.authFormErrorRateLimited(5), 'Too many attempts. Try again in 5 minutes.');
      expect(fr.authFormErrorRateLimited(5), contains('5 minutes'));
    });
  });

  group('formatFileSize', () {
    test('picks bytes, kilobytes or megabytes', () {
      expect(formatFileSize(512, 'en'), '512 B');
      expect(formatFileSize(1536, 'en'), '1.5 KB');
      expect(formatFileSize(3 * 1024 * 1024, 'en'), '3.0 MB');
      expect(formatFileSize(1536, 'fr'), '1,5 KB');
    });
  });
}
