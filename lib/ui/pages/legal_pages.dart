import 'package:flutter/material.dart';

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
              'Dual Clash respects your privacy. This policy explains what data is collected and how it is used when you play in the web experience.',
        ),
        InfoSection(
          heading: 'Data we collect',
          bullets: [
            'Gameplay progress, settings, and preferences stored on your device or browser.',
            'Basic analytics about feature usage and performance to improve stability.',
          ],
        ),
        InfoSection(
          heading: 'What we do not collect',
          bullets: [
            'No precise location data.',
            'No contacts or personal address book information.',
            'No sensitive personal information.',
          ],
        ),
        InfoSection(
          heading: 'How data is used',
          bullets: [
            'To provide core gameplay features and restore your preferences.',
            'To improve reliability, fix bugs, and balance gameplay.',
          ],
        ),
        InfoSection(
          heading: 'Contact',
          body: 'Questions? Email support@dualclash.app.',
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
            'Do not disrupt gameplay or attempt to reverse engineer the app.',
          ],
        ),
        InfoSection(
          heading: 'Content and updates',
          body:
              'Game content may change over time to improve quality, balance, or performance.',
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
          body: 'Email us at support@dualclash.app and we will get back to you.',
        ),
        InfoSection(
          heading: 'FAQ',
          bullets: [
            'How do I reset my settings? Use Settings > Reset within the app.',
            'Does the web version save progress? Progress and preferences are stored in your browser.',
            'I found a bug. What should I include? Tell us your device, browser, and steps to reproduce.',
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
          heading: 'Data collection summary',
          body:
              'The mobile version of Dual Clash may collect the following data to support gameplay and app quality.',
        ),
        InfoSection(
          heading: 'Data linked to you',
          bullets: [
            'Identifiers (such as device identifiers) for analytics and app functionality.',
            'Usage data to understand feature engagement and improve performance.',
          ],
        ),
        InfoSection(
          heading: 'Data not linked to you',
          bullets: [
            'Diagnostics to monitor crashes and app stability.',
          ],
        ),
        InfoSection(
          heading: 'Data usage',
          bullets: [
            'Analytics and product improvement.',
            'App functionality such as restoring preferences.',
          ],
        ),
      ],
    );
  }
}
