import 'package:dual_clash/core/localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Metadata for external support links rendered in [SupportLinksBar].
class SupportLink {
  final String label;
  final IconData icon;
  final Uri url;

  const SupportLink({
    required this.label,
    required this.icon,
    required this.url,
  });
}

/// Bottom-bar fallback that encourages supporters when ads are unavailable.
class SupportLinksBar extends StatelessWidget {
  /// Default list of support platforms displayed in the bar.
  static final List<SupportLink> defaultLinks = [
    SupportLink(
      label: 'Patreon',
      icon: Icons.favorite,
      url: Uri.parse('https://www.patreon.com'),
    ),
    SupportLink(
      label: 'Boosty',
      icon: Icons.volunteer_activism,
      url: Uri.parse('https://boosty.to'),
    ),
    SupportLink(
      label: 'Ko-fi',
      icon: Icons.coffee,
      url: Uri.parse('https://ko-fi.com'),
    ),
  ];

  final List<SupportLink> links;
  final double? height;

  SupportLinksBar({super.key, List<SupportLink>? links, this.height})
      : links = links ?? defaultLinks;

  @override
  Widget build(BuildContext context) {
    final barHeight = height ?? 100;
    final bool isCompact = barHeight < 80;
    return SafeArea(
      bottom: true,
      top: false,
      child: SizedBox(
        height: barHeight,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 12,
                  vertical: isCompact ? 4 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.supportTheDevLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: isCompact ? 12 : 14,
                      ),
                    ),
                    SizedBox(height: isCompact ? 4 : 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: links
                          .map(
                            (link) => OutlinedButton.icon(
                              onPressed: () async {
                                await launchUrl(
                                  link.url,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              icon: Icon(link.icon, size: isCompact ? 14 : 18),
                              label: Text(link.label),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 6 : 10,
                                  vertical: isCompact ? 4 : 8,
                                ),
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: isCompact ? 10 : 12,
                                ),
                                visualDensity: isCompact
                                    ? VisualDensity.compact
                                    : VisualDensity.standard,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
