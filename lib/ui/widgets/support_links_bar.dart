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

  const SupportLinksBar({super.key, this.links = defaultLinks});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: SizedBox(
        height: 100,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Support the dev',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                            icon: Icon(link.icon, size: 18),
                            label: Text(link.label),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.w700),
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
    );
  }
}
