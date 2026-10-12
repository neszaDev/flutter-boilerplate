import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A service with a brand button.
typedef Brand = ({
  /// Kebab-case id, as the Vue app named them.
  String id,

  /// The brand's own name (not translated).
  String label,

  /// Its mark from the Font Awesome brand set.
  FaIconData icon,
});

/// The brands of the Vue brand-button demo, in its order.
const brands = <Brand>[
  (id: 'facebook', label: 'Facebook', icon: FontAwesomeIcons.facebook),
  (id: 'twitter', label: 'Twitter', icon: FontAwesomeIcons.twitter),
  (id: 'linkedin', label: 'LinkedIn', icon: FontAwesomeIcons.linkedin),
  (id: 'flickr', label: 'Flickr', icon: FontAwesomeIcons.flickr),
  (id: 'tumblr', label: 'Tumblr', icon: FontAwesomeIcons.tumblr),
  (id: 'xing', label: 'Xing', icon: FontAwesomeIcons.xing),
  (id: 'github', label: 'GitHub', icon: FontAwesomeIcons.github),
  (id: 'stack-overflow', label: 'Stack Overflow', icon: FontAwesomeIcons.stackOverflow),
  (id: 'youtube', label: 'YouTube', icon: FontAwesomeIcons.youtube),
  (id: 'dribbble', label: 'Dribbble', icon: FontAwesomeIcons.dribbble),
  (id: 'instagram', label: 'Instagram', icon: FontAwesomeIcons.instagram),
  (id: 'pinterest', label: 'Pinterest', icon: FontAwesomeIcons.pinterest),
  (id: 'vk', label: 'VK', icon: FontAwesomeIcons.vk),
  (id: 'yahoo', label: 'Yahoo', icon: FontAwesomeIcons.yahoo),
  (id: 'behance', label: 'Behance', icon: FontAwesomeIcons.behance),
  (id: 'reddit', label: 'Reddit', icon: FontAwesomeIcons.reddit),
  (id: 'vimeo', label: 'Vimeo', icon: FontAwesomeIcons.vimeo),
];

/// How each kind of brand button is written. Code samples are code, not copy: they stay the
/// same in every language.
const brandButtonUsage = (
  both:
      'OutlinedButton.icon(onPressed: open, icon: const FaIcon(FontAwesomeIcons.facebook), '
      "label: const Text('Facebook'))",
  icon:
      "IconButton.outlined(onPressed: open, tooltip: 'Facebook', "
      'icon: const FaIcon(FontAwesomeIcons.facebook))',
  text: "OutlinedButton(onPressed: open, child: const Text('Facebook'))",
);
