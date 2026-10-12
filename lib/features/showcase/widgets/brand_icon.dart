import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// The Font Awesome mark of each [Brand] (Lucide ships no brand marks).
const brandIcons = <Brand, FaIconData>{
  Brand.facebook: FontAwesomeIcons.facebook,
  Brand.twitter: FontAwesomeIcons.twitter,
  Brand.linkedin: FontAwesomeIcons.linkedin,
  Brand.mastercard: FontAwesomeIcons.ccMastercard,
  Brand.visa: FontAwesomeIcons.ccVisa,
  Brand.stripe: FontAwesomeIcons.ccStripe,
  Brand.paypal: FontAwesomeIcons.ccPaypal,
  Brand.googlePay: FontAwesomeIcons.googlePay,
  Brand.amex: FontAwesomeIcons.ccAmex,
};

/// A one-colour brand logo in [color] (or the icon theme's). With a [label] it is announced as
/// that name; without, it is decorative.
class BrandIcon extends StatelessWidget {
  const BrandIcon(this.brand, {this.label, this.size = 20, this.color, super.key});

  final Brand brand;
  final String? label;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final icon = FaIcon(brandIcons[brand], size: size, color: color);
    return label == null
        ? ExcludeSemantics(child: icon)
        : Semantics(
            label: label,
            image: true,
            child: ExcludeSemantics(child: icon),
          );
  }
}
