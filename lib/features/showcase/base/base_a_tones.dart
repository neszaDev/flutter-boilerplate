/// The Marksheet stand-ins for the eight colour variants the base demos cycle through, in the
/// web order: primary → [folder], secondary → [ink], success → [pass], warning → [pencil],
/// info → [deep] (folder deep), danger → [pen], light → [light] (ink 300), dark → [dark]
/// (ink 950). Red pen keeps its meaning: it stands for the error/danger slot only.
///
/// Colours live in `base_a_tone_colors.dart`; this file stays pure Dart.
enum Tone { folder, ink, pass, pencil, deep, pen, light, dark }
