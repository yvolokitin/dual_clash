import 'package:flutter/material.dart';

import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/localization.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<InfoSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 24),
                for (final section in sections) ...[
                  Text(section.heading, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (section.body != null)
                    Text(section.body!, style: theme.textTheme.bodyMedium),
                  if (section.bullets.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _BulletList(items: section.bullets),
                  ],
                  const SizedBox(height: 24),
                ],
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGold,
                      foregroundColor: const Color(0xFF2B221D),
                      shadowColor: Colors.black54,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 0.2),
                    ),
                    child: Text(context.l10n.commonClose),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoSection {
  const InfoSection({
    required this.heading,
    this.body,
    this.bullets = const [],
  });

  final String heading;
  final String? body;
  final List<String> bullets;
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: theme.textTheme.bodyMedium),
                Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Privacy Policy',
      sections: [
        InfoSection(
          heading: 'Overview',
          body:
              'Dual Clash respects your privacy. This policy explains what data is collected and how it is used when you play the game.',
        ),
        InfoSection(
          heading: 'Data We Collect',
          bullets: [
            'Gameplay progress, settings, and preferences stored locally on your device or browser.',
          ],
        ),
        InfoSection(
          heading: 'Analytics',
          body:
              'Dual Clash does not use analytics, tracking technologies, cookies, or third-party measurement services.',
        ),
        InfoSection(
          heading: 'What We Do Not Collect',
          bullets: [
            'No precise location data.',
            'No contacts or address book information.',
            'No advertising identifiers.',
            'No sensitive personal information.',
            'No personal data used for tracking or profiling.',
          ],
        ),
        InfoSection(
          heading: 'Children',
          body: 'Dual Clash does not knowingly collect personal data from children.',
        ),
        InfoSection(
          heading: 'How Data Is Used',
          bullets: [
            'To provide core gameplay features.',
            'To save and restore your preferences.',
            'To ensure stability and correct functionality of the game.',
          ],
        ),
        InfoSection(
          heading: 'Data Sharing',
          body:
              'Dual Clash does not sell, share, or transfer user data to third parties.',
        ),
        InfoSection(
          heading: 'Changes to This Policy',
          body:
              'If this policy changes, the updated version will be made available within the game or on the official website.',
        ),
        InfoSection(
          heading: 'Contact',
          body:
              'If you have questions about this Privacy Policy, contact: support@dualclash.app',
        ),
      ],
    );
  }
}

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Terms of Use',
      sections: [
        InfoSection(
          heading: 'Acceptance',
          body:
              'By accessing Dual Clash, you agree to these terms and to play respectfully.',
        ),
        InfoSection(
          heading: 'Permitted use',
          bullets: [
            'Use the game for personal entertainment.',
            'Do not disrupt gameplay, misuse the service, or attempt to modify or interfere with the app.',
          ],
        ),
        InfoSection(
          heading: 'Content and updates',
          body:
              'Game content may change over time to improve quality, balance, or performance.',
        ),
        InfoSection(
          heading: 'Privacy',
          body:
              'Dual Clash does not knowingly collect, store, or share personal data.',
        ),
        InfoSection(
          heading: 'Access',
          body:
              'We reserve the right to restrict or terminate access if these terms are violated.',
        ),
        InfoSection(
          heading: 'Disclaimer',
          body:
              'The game is provided as-is without warranties. We are not liable for damages arising from use of the service.',
        ),
      ],
    );
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Support',
      sections: [
        InfoSection(
          heading: 'Contact support',
          body:
              'Need help with the web, mobile, or desktop version of Dual Clash?\nEmail us at support@dualclash.app and we will get back to you.\n\nWe usually respond within 1–2 business days.',
        ),
        InfoSection(
          heading: 'FAQ',
          bullets: [
            'How do I reset my settings? Use Settings → Reset within the app on any platform.',
            'Does Dual Clash save my progress? Yes. Progress and preferences are stored locally on your device or browser, depending on the platform you use.',
            'Which platforms are supported? Dual Clash is available on web, iOS, Android, and desktop. Core gameplay features are consistent across all versions.',
            'I found a bug. What should I include? Please include: Platform (web, iOS, Android, or desktop); device model or operating system; app version (if available); and steps to reproduce the issue.',
            'For the latest updates and fixes, please ensure you are using the most recent version of the app.',
          ],
        ),
      ],
    );
  }
}

class AppStorePrivacyPage extends StatelessWidget {
  const AppStorePrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'App Store Connect Privacy Declarations',
      sections: [
        InfoSection(
          heading: 'Data Collection Summary',
          body:
              'Dual Clash does not collect any user data.\nAll gameplay progress, settings, and preferences are stored locally on the user’s device or browser and are not transmitted off the device.',
        ),
        InfoSection(
          heading: 'Analytics',
          body:
              'The app does not use analytics, tracking technologies, advertising identifiers, or third-party measurement services.',
        ),
        InfoSection(
          heading: 'Data Sharing',
          body:
              'No personal data is collected, linked to the user, or shared with third parties.',
        ),
      ],
    );
  }
}
