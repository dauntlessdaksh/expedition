import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Displays in-app legal documents for store compliance.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    required this.title,
    required this.sections,
    super.key,
  });

  final String title;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPalette.darkBackground,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xl),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Semantics(
            header: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.heading,
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  section.body,
                  style: const TextStyle(
                    color: AppColorPalette.grey400,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LegalSection {
  const LegalSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

abstract final class LegalDocuments {
  static const privacyPolicy = [
    LegalSection(
      heading: 'Overview',
      body:
          'Expedition stores your fitness profile, workout history, goals, and achievements locally on your device. We do not sell personal data.',
    ),
    LegalSection(
      heading: 'Data We Collect',
      body:
          'Activity routes, duration, distance, calories, profile details, and app preferences are saved offline in your local database.',
    ),
    LegalSection(
      heading: 'Location Data',
      body:
          'GPS location is used only while tracking activities. Location data remains on your device unless you export workouts manually.',
    ),
    LegalSection(
      heading: 'Your Controls',
      body:
          'You can export or delete workouts from Profile > Data Management at any time.',
    ),
  ];

  static const termsOfService = [
    LegalSection(
      heading: 'Acceptance',
      body:
          'By using Expedition, you agree to track activities responsibly and comply with local laws while exercising outdoors.',
    ),
    LegalSection(
      heading: 'Health Disclaimer',
      body:
          'Expedition provides fitness tracking tools, not medical advice. Consult a professional before starting a new training program.',
    ),
    LegalSection(
      heading: 'Accuracy',
      body:
          'GPS, calorie, and pace estimates may vary based on device sensors and environmental conditions.',
    ),
    LegalSection(
      heading: 'Availability',
      body:
          'Core features are designed to work offline. Some device permissions are required for activity tracking.',
    ),
  ];
}
