import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Renders text with highlighted query matches for search results.
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    this.highlightStyle,
    super.key,
  });

  final String text;
  final String query;
  final TextStyle style;
  final TextStyle? highlightStyle;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lowerText.indexOf(normalizedQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + normalizedQuery.length),
          style: (highlightStyle ?? style).copyWith(
            color: AppColorPalette.primaryLight,
            fontWeight: FontWeight.w800,
            backgroundColor: AppColorPalette.primary.withValues(alpha: 0.18),
          ),
        ),
      );

      start = index + normalizedQuery.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }
}
