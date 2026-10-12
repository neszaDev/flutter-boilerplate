import 'package:flutter_boilerplate/features/showcase/campus/rich_text_html.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('deltaToHtml', () {
    test('writes an empty paragraph for an empty document', () {
      expect(
        deltaToHtml([
          {'insert': '\n'},
        ]),
        '<p></p>',
      );
    });

    test('wraps marks like the web editor', () {
      expect(
        deltaToHtml([
          {'insert': 'Hello '},
          {
            'insert': 'world',
            'attributes': {'bold': true, 'italic': true},
          },
          {
            'insert': ' site',
            'attributes': {'underline': true, 'link': 'https://mfu.ac.th'},
          },
          {'insert': '\n'},
        ]),
        '<p>Hello <strong><em>world</em></strong><a href="https://mfu.ac.th"><u> site</u></a></p>',
      );
    });

    test('groups consecutive list lines into one list', () {
      expect(
        deltaToHtml([
          {'insert': 'a'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'},
          },
          {'insert': 'b'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'},
          },
          {'insert': 'c'},
          {
            'insert': '\n',
            'attributes': {'list': 'ordered'},
          },
        ]),
        '<ul><li><p>a</p></li><li><p>b</p></li></ul><ol><li><p>c</p></li></ol>',
      );
    });

    test('writes headings, quotes and code blocks', () {
      expect(
        deltaToHtml([
          {'insert': 'Title'},
          {
            'insert': '\n',
            'attributes': {'header': 2},
          },
          {'insert': 'Said'},
          {
            'insert': '\n',
            'attributes': {'blockquote': true},
          },
          {'insert': 'a < b'},
          {
            'insert': '\n',
            'attributes': {'code-block': true},
          },
          {'insert': 'end\n'},
        ]),
        '<h2>Title</h2><blockquote><p>Said</p></blockquote><pre><code>a &lt; b</code></pre>'
        '<p>end</p>',
      );
    });

    test('escapes markup typed as text and skips embeds', () {
      expect(
        deltaToHtml([
          {'insert': '<b>"&"</b>'},
          {
            'insert': {'image': 'x.png'},
          },
          {'insert': '\nnext\n'},
        ]),
        '<p>&lt;b&gt;&quot;&amp;&quot;&lt;/b&gt;</p><p>next</p>',
      );
    });
  });
}
