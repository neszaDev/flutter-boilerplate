/// Turns a Quill delta (`document.toDelta().toJson()`) into the HTML the web app's rich-text
/// editor (Tiptap) saves: `<p>`, `<h1>`–`<h6>`, `<ul>`/`<ol>` of `<li><p>`, `<blockquote>`,
/// `<pre><code>`, and the marks `<strong>`, `<em>`, `<u>`, `<s>`, `<code>`, `<a href>`.
/// Embeds (images, formulas) are left out: the campus editor has no button for them.
String deltaToHtml(Iterable<Object?> ops) {
  final lines = <_Line>[];
  var segments = <_Segment>[];
  for (final op in ops) {
    if (op is! Map) {
      continue;
    }
    final insert = op['insert'];
    if (insert is! String) {
      continue;
    }
    final attributes = _attributes(op['attributes']);
    final parts = insert.split('\n');
    for (final (index, part) in parts.indexed) {
      if (part.isNotEmpty) {
        segments.add(_Segment(part, attributes));
      }
      // Each newline ends a line; its attributes are the line's block format.
      if (index < parts.length - 1) {
        lines.add(_Line(segments, attributes));
        segments = [];
      }
    }
  }
  if (segments.isNotEmpty) {
    lines.add(_Line(segments, const {}));
  }

  final html = StringBuffer();
  var index = 0;
  // Consecutive lines of the same list, quote or code block share one element.
  List<_Line> run(bool Function(_Line line) same) {
    final group = <_Line>[];
    while (index < lines.length && same(lines[index])) {
      group.add(lines[index]);
      index++;
    }
    return group;
  }

  while (index < lines.length) {
    final line = lines[index];
    final list = line.block['list'];
    if (list == 'bullet' || list == 'ordered') {
      final tag = list == 'ordered' ? 'ol' : 'ul';
      final items = run((next) => next.block['list'] == list);
      html.write('<$tag>${items.map((item) => '<li><p>${item.inline}</p></li>').join()}</$tag>');
    } else if (line.block['code-block'] != null) {
      final code = run((next) => next.block['code-block'] != null);
      html.write('<pre><code>${code.map((item) => _escape(item.text)).join('\n')}</code></pre>');
    } else if (line.block['blockquote'] == true) {
      final quote = run((next) => next.block['blockquote'] == true);
      html.write('<blockquote>${quote.map((item) => '<p>${item.inline}</p>').join()}</blockquote>');
    } else {
      final header = line.block['header'];
      final tag = header is int && header >= 1 && header <= 6 ? 'h$header' : 'p';
      html.write('<$tag>${line.inline}</$tag>');
      index++;
    }
  }
  return html.toString();
}

Map<String, Object?> _attributes(Object? value) =>
    value is Map ? {for (final MapEntry(:key, :value) in value.entries) '$key': value} : const {};

String _escape(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

class _Segment {
  const _Segment(this.text, this.attributes);

  final String text;
  final Map<String, Object?> attributes;

  String get html {
    var result = _escape(text);
    if (attributes['code'] == true) {
      result = '<code>$result</code>';
    }
    if (attributes['strike'] == true) {
      result = '<s>$result</s>';
    }
    if (attributes['underline'] == true) {
      result = '<u>$result</u>';
    }
    if (attributes['italic'] == true) {
      result = '<em>$result</em>';
    }
    if (attributes['bold'] == true) {
      result = '<strong>$result</strong>';
    }
    final link = attributes['link'];
    if (link is String && link.isNotEmpty) {
      result = '<a href="${_escape(link)}">$result</a>';
    }
    return result;
  }
}

class _Line {
  const _Line(this.segments, this.block);

  final List<_Segment> segments;
  final Map<String, Object?> block;

  String get inline => segments.map((segment) => segment.html).join();

  String get text => segments.map((segment) => segment.text).join();
}
