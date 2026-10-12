import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/editors/quill_html.dart';
import 'package:flutter_boilerplate/features/showcase/editors/rich_text_editor.dart';
import 'package:flutter_boilerplate/features/showcase/editors/sample_document.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

const _link = '<a target="_blank" rel="noopener noreferrer nofollow" href=';

QuillController _controller(String text, TextSelection selection) => QuillController(
  document: Document.fromDelta(Delta()..insert('$text\n')),
  selection: selection,
);

String _html(QuillController controller) => deltaToHtml(controller.document.toDelta());

void main() {
  group('deltaToHtml', () {
    test('writes paragraphs, an empty one included', () {
      expect(
        deltaToHtml(Delta()..insert('Spring term\n\nSummer\n')),
        '<p>Spring term</p><p></p><p>Summer</p>',
      );
    });

    test('nests marks like the web editor and keeps them open across runs', () {
      final delta = Delta()
        ..insert('Spring ', {'bold': true})
        ..insert('term', {'bold': true, 'italic': true})
        ..insert(' report', {'link': 'https://example.com/?a=1&b="2"', 'underline': true})
        ..insert('\n');

      expect(
        deltaToHtml(delta),
        '<p><strong>Spring <em>term</em></strong>'
        '$_link"https://example.com/?a=1&amp;b=&quot;2&quot;"><u> report</u></a></p>',
      );
    });

    test('writes headings, lists, quotes, code blocks and rules', () {
      final delta = Delta()
        ..insert('Title')
        ..insert('\n', {'header': 2})
        ..insert('One')
        ..insert('\n', {'list': 'bullet'})
        ..insert('Two')
        ..insert('\n', {'list': 'bullet'})
        ..insert('First')
        ..insert('\n', {'list': 'ordered'})
        ..insert('A mark says where a student stands.')
        ..insert('\n', {'blockquote': true})
        ..insert('const a = 1;')
        ..insert('\n', {'code-block': true})
        ..insert('a < b')
        ..insert('\n', {'code-block': true})
        ..insert({ruleEmbedType: 'hr'})
        ..insert('\n');

      expect(
        deltaToHtml(delta),
        '<h2>Title</h2>'
        '<ul><li><p>One</p></li><li><p>Two</p></li></ul>'
        '<ol><li><p>First</p></li></ol>'
        '<blockquote><p>A mark says where a student stands.</p></blockquote>'
        '<pre><code>const a = 1;\na &lt; b</code></pre>'
        '<hr>',
      );
    });
  });

  group('sampleDocument', () {
    test('is the web article: bold lead, links, quote and italics', () {
      final html = deltaToHtml(sampleDocument(en));

      expect(html, startsWith('<p><strong>A report card</strong> is a document'));
      expect(html, contains('$_link"https://en.wikipedia.org/wiki/School">school</a>'));
      expect(html, contains('<blockquote><p>${en.textEditorsPageArticleQuote}</p></blockquote>'));
      expect(html, contains('<em>fifty years ago</em>'));
      expect(html, isNot(contains('<b>')));
    });
  });

  group('applyLink', () {
    test('links the selection, then edits and removes the link around the caret', () {
      final controller = _controller(
        'Spring term',
        const TextSelection(baseOffset: 0, extentOffset: 6),
      );
      addTearDown(controller.dispose);

      applyLink(controller, ' https://example.com ');
      expect(_html(controller), '<p>$_link"https://example.com">Spring</a> term</p>');

      controller.updateSelection(const TextSelection.collapsed(offset: 6), ChangeSource.local);
      applyLink(controller, 'https://example.org');
      expect(_html(controller), '<p>$_link"https://example.org">Spring</a> term</p>');

      controller.updateSelection(const TextSelection.collapsed(offset: 3), ChangeSource.local);
      applyLink(controller, '');
      expect(_html(controller), '<p>Spring term</p>');
    });

    test('inserts the address as a link at a bare caret', () {
      final controller = _controller('See ', const TextSelection.collapsed(offset: 4));
      addTearDown(controller.dispose);

      applyLink(controller, 'https://example.com');

      expect(_html(controller), '<p>See $_link"https://example.com">https://example.com</a></p>');
    });
  });

  group('insertRule', () {
    test('puts the rule on a line of its own and the caret after it', () {
      final controller = _controller('Spring term', const TextSelection.collapsed(offset: 11));
      addTearDown(controller.dispose);

      insertRule(controller);

      expect(_html(controller), '<p>Spring term</p><hr><p></p>');
      expect(controller.selection, const TextSelection.collapsed(offset: 14));
    });
  });
}
