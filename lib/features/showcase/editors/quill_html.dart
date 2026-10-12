import 'package:flutter/foundation.dart';
import 'package:flutter_quill/quill_delta.dart';

/// The embed type of a horizontal rule in the document.
const ruleEmbedType = 'divider';

/// Marks in the order the web editor (Tiptap) nests them, outermost first.
const _markOrder = ['link', 'bold', 'code', 'italic', 'strike', 'underline'];

const _markTags = {
  'bold': 'strong',
  'code': 'code',
  'italic': 'em',
  'strike': 's',
  'underline': 'u',
};

@immutable
class _Mark {
  const _Mark(this.name, [this.href]);

  final String name;
  final String? href;

  String get open => name == 'link'
      ? '<a target="_blank" rel="noopener noreferrer nofollow" href="${_escape(href ?? '', attribute: true)}">'
      : '<${_markTags[name]}>';

  String get close => name == 'link' ? '</a>' : '</${_markTags[name]}>';

  @override
  bool operator ==(Object other) => other is _Mark && other.name == name && other.href == href;

  @override
  int get hashCode => Object.hash(name, href);
}

/// A piece of a line: text with its inline attributes, or an embed.
class _Segment {
  const _Segment.text(this.text, this.attributes) : embed = null;

  const _Segment.embed(String this.embed) : text = '', attributes = const {};

  final String text;
  final Map<String, Object?> attributes;
  final String? embed;

  List<_Mark> get marks => [
    for (final name in _markOrder)
      if (attributes[name] case final Object value when value != false)
        _Mark(name, name == 'link' ? '$value' : null),
  ];
}

/// One line of the document and the block attributes of its newline.
class _Line {
  const _Line(this.segments, this.attributes);

  final List<_Segment> segments;
  final Map<String, Object?> attributes;

  String? get list => attributes['list'] as String?;

  bool get quote => attributes['blockquote'] == true;

  bool get code => attributes['code-block'] == true;

  int? get header => attributes['header'] as int?;

  bool get isRule => segments.length == 1 && segments.single.embed == ruleEmbedType;

  String get plainText => segments.map((segment) => segment.text).join();
}

String _escape(String text, {bool attribute = false}) {
  final escaped = text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  return attribute ? escaped.replaceAll('"', '&quot;') : escaped;
}

List<_Line> _linesOf(Delta delta) {
  final lines = <_Line>[];
  var segments = <_Segment>[];
  for (final operation in delta.toList()) {
    if (!operation.isInsert) {
      continue;
    }
    final data = operation.data;
    final Map<String, Object?> attributes = operation.attributes ?? const {};
    if (data is String) {
      final parts = data.split('\n');
      for (var index = 0; index < parts.length; index++) {
        if (parts[index].isNotEmpty) {
          segments.add(_Segment.text(parts[index], attributes));
        }
        if (index < parts.length - 1) {
          lines.add(_Line(segments, attributes));
          segments = [];
        }
      }
    } else if (data is Map && data.isNotEmpty) {
      segments.add(_Segment.embed('${data.keys.first}'));
    }
  }
  if (segments.isNotEmpty) {
    lines.add(_Line(segments, const {}));
  }
  return lines;
}

/// The inline HTML of [segments], marks opened and closed as little as possible.
String _inline(List<_Segment> segments) {
  final out = StringBuffer();
  final open = <_Mark>[];
  for (final segment in segments) {
    final marks = segment.marks;
    var kept = 0;
    while (kept < open.length && kept < marks.length && open[kept] == marks[kept]) {
      kept++;
    }
    for (var index = open.length - 1; index >= kept; index--) {
      out.write(open[index].close);
    }
    open.removeRange(kept, open.length);
    for (final mark in marks.skip(kept)) {
      out.write(mark.open);
      open.add(mark);
    }
    out.write(_escape(segment.text));
  }
  for (final mark in open.reversed) {
    out.write(mark.close);
  }
  return out.toString();
}

/// The HTML of a Quill document, in the shape the web editor (Tiptap's `getHTML()`) writes:
/// paragraphs, `h1`–`h3`, lists of `<li><p>`, quotes of paragraphs, `<pre><code>` blocks,
/// `<hr>`, and `strong`/`em`/`u`/`s`/`code`/`a` marks.
String deltaToHtml(Delta delta) {
  final lines = _linesOf(delta);
  final out = StringBuffer();
  var index = 0;
  while (index < lines.length) {
    final line = lines[index];
    if (line.code) {
      final code = <String>[];
      while (index < lines.length && lines[index].code) {
        code.add(_escape(lines[index].plainText));
        index++;
      }
      out.write('<pre><code>${code.join('\n')}</code></pre>');
    } else if (line.list case final list?) {
      final tag = list == 'ordered' ? 'ol' : 'ul';
      out.write('<$tag>');
      while (index < lines.length && lines[index].list == list && !lines[index].code) {
        out.write('<li><p>${_inline(lines[index].segments)}</p></li>');
        index++;
      }
      out.write('</$tag>');
    } else if (line.quote) {
      out.write('<blockquote>');
      while (index < lines.length &&
          lines[index].quote &&
          lines[index].list == null &&
          !lines[index].code) {
        out.write('<p>${_inline(lines[index].segments)}</p>');
        index++;
      }
      out.write('</blockquote>');
    } else {
      final header = line.header;
      if (line.isRule) {
        out.write('<hr>');
      } else if (header != null && header >= 1 && header <= 3) {
        out.write('<h$header>${_inline(line.segments)}</h$header>');
      } else {
        out.write('<p>${_inline(line.segments)}</p>');
      }
      index++;
    }
  }
  return out.toString();
}
