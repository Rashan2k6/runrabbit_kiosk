import 'package:flutter/material.dart';

/// RunRabbit Brand Design System
///
/// Derived from the official RunRabbit K-Beauty store aesthetic:
/// - Clean, high-fashion typography with wide tracking
/// - Crisp, warm-white editorial background with deep charcoal black accents
/// - Vivid promotional terracotta and sale red badges (matching website clearance tags)
/// - Eco-friendly botanical greens for nature-based formulations
/// - Rounded pill buttons and modern product presentation cards
class Brand {
  static const name = 'RUNRABBIT';
  static const tagline = 'K-BEAUTY & SKINCARE';
  static const storeLocation = 'COLOMBO FLAGSHIP STORE';

  // Primary Obsidian / Charcoal Black (Website header, buttons, headings)
  static const primary = Color(0xFF141414);
  static const onPrimary = Color(0xFFFFFFFF);

  // Secondary Accents (Clearance terracotta and vibrant sale price)
  static const accent = Color(0xFFD8582B); // Clearance badge: "UP TO 50% OFF"
  static const saleRed = Color(0xFFE53935); // Price highlight: "Rs 490"
  static const strikethroughPrice = Color(0xFF8E8E93);

  // Surfaces & Backgrounds
  static const background = Color(0xFFFAFAFA); // Crisp, bright store backdrop
  static const surface = Color(0xFFFFFFFF); // Pure white card surface
  static const surfaceSubtle =
      Color(0xFFF5F5F7); // Image container / Pill tab bg
  static const surfaceSelected = Color(0xFF1A1A1A); // Active pill background

  // Borders & Dividers
  static const outline = Color(0xFFE8E8ED); // Subtle hairline card borders
  static const outlineLight = Color(0xFFF0F0F2);
  static const outlineActive = Color(0xFF141414);

  // Typography Colors
  static const textPrimary = Color(0xFF141414);
  static const mutedText = Color(0xFF6E6E73); // High readability neutral
  static const brandLabel = Color(0xFF8E8E93); // Uppercase brand tracking

  // Badges & Statuses
  static const natureTagBg = Color(0xFFEFF8F2);
  static const natureTagText = Color(0xFF236E3B);
  static const soldOutBg = Color(0xFF1C1C1E);
  static const soldOutText = Color(0xFFFFFFFF);
  static const discountBadgeBg = Color(0xFFD8582B);
  static const discountBadgeText = Color(0xFFFFFFFF);

  // Caution & Advice Notes
  static const caution = Color(0xFF92400E);
  static const cautionBackground = Color(0xFFFEF3C7);

  // Radii
  static const radius = 16.0;
  static const cardRadius = 18.0;
  static const pillRadius = 99.0;

  // Typography
  static const String? fontFamily = null;
}
