# Design System: Marksheet (Flutter)

The same design as the web app — see nextjs-boilerplate's `DESIGN.md` for the full intent ("The
Report Card": folder-green cover, pale card stock, navy form ink, a green tick, a red pen and a
graphite pencil; Libre Franklin for print, Kalam for the hand). This file says where each part
lives in Flutter.

| Web | Flutter |
|---|---|
| CSS variables in `global.css` (`--folder`, `--ink-900`, …) | `MarksheetColors` (`lib/core/theme/marksheet_colors.dart`), read with `context.colors.folder` |
| Tailwind theme → shadcn tokens (`--primary`, `--border`, …) | `ColorScheme` built in `AppTheme` (`primary` = folder, `outline` = ink-300, `error` = pen…) |
| Type scale (`display`, `page-title`, `title`, `label`, `figure`, `hand-*`) | `TextTheme` (`displayLarge`, `headlineMedium`, `titleLarge`, …) + `context.type.formLabel / figure / table / handRemark / handNote / code` |
| `rounded` and `spacing` tokens | `Radii` and `Space` |
| `Mark` (SVG strokes with `pathLength=1`) | `Mark` (`lib/core/widgets/mark.dart`): the same paths, drawn on with `PathMetric` |
| `Card` + `border-b-[3px] border-double` header | `SheetCard`, `DoubleRule` |
| `DemoCard`, `PageHeader` | same names in `lib/core/widgets/page_layout.dart` |
| `prefers-reduced-motion` | `MediaQuery.disableAnimationsOf` (marks are static) |

## Differences on the phone

- **Dark theme.** The web design is daylight only; phones follow the system setting, so
  `MarksheetColors.dark` inverts the ink ramp onto a night desk and lifts the marks for contrast.
  The default stays light; users choose in Settings.
- **Navigation.** The folder-green sidebar becomes the Menu tab (same sections, same order); the
  main destinations are bottom tabs.
- **Tables** become ruled lists (`ResultRow`): status mark, name with the hand-written note, date,
  score in tabular figures.
- **Hover** states become pressed states and long-press tooltips.
- **Touch targets** are at least 44 pt (buttons 44 high instead of 36).
- **Haptics** confirm success (light) and failure (medium), and can be turned off.

## Rules

- Colours come from the theme only. A screen with `Color(0x…)` is a bug unless the colour *is*
  the data (a brand colour, a palette swatch).
- Check every new screen in light and dark, at the largest text size, with TalkBack/VoiceOver.
