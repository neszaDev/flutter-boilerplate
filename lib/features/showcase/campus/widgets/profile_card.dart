import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_boilerplate/features/showcase/campus/labels.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The campus profile card (Vue `VPersonal`): photo with a local preview of a newly chosen
/// one, the person's details, and which social accounts are linked (greyed when missing).
class ProfileCard extends StatefulWidget {
  const ProfileCard({required this.profile, super.key});

  final CampusProfile profile;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  ({Uint8List bytes, String name})? _preview;

  /// Picks a photo from the library and previews it. Nothing is uploaded.
  Future<void> _choosePhoto() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600);
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (mounted) {
        setState(() => _preview = (bytes: bytes, name: file.name));
      }
    } on PlatformException {
      if (mounted) {
        showToast(context, context.l10n.commonPermissionDenied, tone: ToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = widget.profile;
    final preview = _preview;
    final rows = [
      (l10n.campusProfileAgency, LucideIcons.network, profile.agency),
      (l10n.campusProfileBranch, LucideIcons.school, profile.branch),
      (l10n.campusProfilePosition, LucideIcons.briefcase, profile.position),
      (l10n.campusProfileMobile, LucideIcons.smartphone, profile.mobile),
      (l10n.campusProfileEmail, LucideIcons.mail, profile.email),
      (l10n.campusProfileGender, LucideIcons.users, profile.gender),
      (l10n.campusProfileBirthDate, LucideIcons.calendar, profile.birthDate),
      (l10n.campusProfileAddress, LucideIcons.mapPin, profile.address),
    ];

    return SheetCard(
      title: l10n.campusProfileTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _Photo(
              name: profile.name,
              preview: preview?.bytes,
              onChange: _choosePhoto,
            ),
          ),
          const SizedBox(height: Space.md),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Semantics(
            container: true,
            liveRegion: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 18),
              child: Text(
                preview == null ? '' : l10n.campusProfilePhotoPreview(preview.name),
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: Space.page),
          for (final (term, icon, value) in rows) _InfoRow(term: term, icon: icon, value: value),
          const SizedBox(height: Space.sm),
          _SocialLinks(links: profile.links),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.name, required this.preview, required this.onChange});

  final String name;
  final Uint8List? preview;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final photo = preview;
    return SizedBox.square(
      dimension: 144,
      child: Stack(
        children: [
          Semantics(
            container: true,
            image: true,
            label: context.l10n.campusProfilePhotoAlt(name),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.ply, width: 4),
              ),
              child: CircleAvatar(
                radius: 68,
                backgroundColor: colors.folder,
                foregroundColor: colors.folderInk,
                backgroundImage: photo == null ? null : MemoryImage(photo),
                child: photo == null
                    ? ExcludeSemantics(
                        child: Text(
                          initials(name),
                          style: context.text.headlineLarge?.copyWith(color: colors.folderInk),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton.filled(
              tooltip: context.l10n.campusProfileChangePhoto,
              onPressed: onChange,
              style: IconButton.styleFrom(
                backgroundColor: colors.folder,
                foregroundColor: colors.folderInk,
                minimumSize: const Size.square(44),
                side: BorderSide(color: colors.paperCard, width: 4),
              ),
              icon: const Icon(LucideIcons.camera, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.term, required this.icon, required this.value});

  final String term;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: colors.ink600),
                const SizedBox(width: Space.sm),
                Expanded(child: Text(term, style: context.text.titleSmall)),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: Space.lg),
              child: Text(
                value,
                style: context.text.bodyMedium?.copyWith(fontSize: 14, color: colors.ink700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLinks extends StatelessWidget {
  const _SocialLinks({required this.links});

  final Map<SocialNetwork, String?> links;

  static const _icons = {
    SocialNetwork.facebook: FontAwesomeIcons.facebook,
    SocialNetwork.instagram: FontAwesomeIcons.instagram,
    SocialNetwork.google: FontAwesomeIcons.google,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    String network(SocialNetwork network) => switch (network) {
      SocialNetwork.facebook => l10n.campusProfileNetworkFacebook,
      SocialNetwork.instagram => l10n.campusProfileNetworkInstagram,
      SocialNetwork.google => l10n.campusProfileNetworkGoogle,
    };
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: colors.ink200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md),
              child: FormLabel(l10n.campusProfileSocialTitle, color: colors.ink700),
            ),
            Expanded(child: Divider(color: colors.ink200)),
          ],
        ),
        const SizedBox(height: Space.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final item in SocialNetwork.values) ...[
              if (item != SocialNetwork.values.first) const SizedBox(width: Space.md),
              Builder(
                builder: (context) {
                  final linked = links[item] != null;
                  final label = linked
                      ? l10n.campusProfileSocialLinked(network(item))
                      : l10n.campusProfileSocialMissing(network(item));
                  // Long-press shows the state, like the web's hover title.
                  // Its own node, so each network is read on its own.
                  return Semantics(
                    container: true,
                    child: Tooltip(
                      message: label,
                      excludeFromSemantics: true,
                      child: Opacity(
                        opacity: linked ? 1 : 0.6,
                        child: FaIcon(
                          _icons[item],
                          size: 30,
                          color: linked ? socialBrandColors[item] : colors.ink400,
                          semanticLabel: label,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
