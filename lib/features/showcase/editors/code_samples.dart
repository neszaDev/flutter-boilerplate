/// Languages of the code editor demo, with the name highlight.js knows them by.
enum CodeLanguage {
  markdown('markdown'),
  javascript('javascript'),
  html('xml');

  const CodeLanguage(this.highlightName);

  final String highlightName;
}

/// Sample documents of the code editor demo, one per language (code, so not translated). The
/// same samples as the web demo.
const codeSamples = <CodeLanguage, String>{
  CodeLanguage.markdown: '''### [CodeMirror](https://codemirror.net)
A versatile _text_ editor implemented in **JavaScript** for the browser.
It is specialized for editing `code`, and comes with a number of language modes and addons that implement more advanced editing functionality.
''',
  CodeLanguage.javascript: '''const component = {
\tname: "react-codemirror",
\tauthor: "uiwjs",
\trepo: "https://github.com/uiwjs/react-codemirror"
};''',
  CodeLanguage.html: '''<!DOCTYPE html>
<html lang="en">
<head>

  <meta charset="utf-8"/>
  <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
  <meta name="description" content=""/>
  <meta name="author" content="Marksheet"/>
  <meta name="keyword" content=""/>
  <link rel="shortcut icon" href="img/favicon.png"/>

  <title></title>

  <!-- Icons -->
  <link href="node_modules/lucide-static/font/lucide.css" rel="stylesheet"/>

  <!-- Main styles for this application -->
  <link href="css/style.css" rel="stylesheet"/>

</head>


<body>
  <header class="app-header">
  <h1>I ♥ Marksheet</h1>
  ...
</header>
  <div class="app-body">
    <div class="sidebar">
      ...
    </div>
    <!-- Main content -->
    <main class="main">

    </main>
  </div>
  <footer class="app-footer">
    ...
  </footer>

  <!-- Main scripts -->
  <script src="js/app-config.js"></script>
  <script src="js/app.js"></script>

</body>
</html>''',
};

/// Tabs are shown 4 spaces wide, as the web editor's `tabSize: 4` (phone keyboards have no tab
/// key, and a tab's width depends on the font).
const tabSize = 4;

/// [source] with each tab expanded to [tabSize] spaces.
String expandTabs(String source) => source.replaceAll('\t', ' ' * tabSize);
