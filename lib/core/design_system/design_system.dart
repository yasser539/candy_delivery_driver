import 'package:flutter/material.dart';
import 'platform_ui_standards.dart';
// Consolidated palette and gradients live below in this file under AppColors

/// DesignSystem acts as a façade over AppColors to preserve the existing API
/// used across the app. It maps all references like DesignSystem.primary,
/// DesignSystem.primaryGradient, typography, and helpers to the new
/// centralized palette and gradients defined in `AppColors`.
class DesignSystem {
  // Colors and gradients
  static LinearGradient get primaryGradient => AppColors.primaryGradient;
  static LinearGradient get secondaryGradient => AppColors.waterGradient;
  static LinearGradient get accentGradient => AppColors.accentGradient;

  static Color get primary => AppColors.primary;
  static Color get success => AppColors.success;
  static Color get warning => AppColors.warning;
  static Color get error => AppColors.error;
  static Color get info => AppColors.info;

  static Color get surface => AppColors.surface;
  static Color get background => AppColors.background;
  static Color get darkSurface => AppColors.darkSurface;
  static Color get darkBackground => AppColors.darkBackground;

  static Color get textPrimary => AppColors.textPrimary;
  static Color get textSecondary => AppColors.textSecondary;
  static Color get textInverse => AppColors.textInverse;

  // Typography (kept same sizing to avoid layout shifts)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.25,
  );
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.1,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.1,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0.25,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0.4,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Shadows bridged to AppColors shadow system
  static List<BoxShadow> getBrandShadow(String type) {
    switch (type.toLowerCase()) {
      case 'light':
        return [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case 'medium':
        return [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      case 'heavy':
        return [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
    }
  }

  // Common decorations bridged to PlatformUIStandards
  static BoxDecoration get gradientCardDecoration => BoxDecoration(
        borderRadius: PlatformUIStandards.getBorderRadius('card'),
        gradient: primaryGradient,
        boxShadow: getBrandShadow('medium'),
      );

  static BoxDecoration get primaryDialogDecoration => BoxDecoration(
        color: surface,
        borderRadius: PlatformUIStandards.getBorderRadius('dialog'),
        boxShadow: getBrandShadow('heavy'),
      );

  static BoxDecoration get gradientDialogDecoration => BoxDecoration(
        borderRadius: PlatformUIStandards.getBorderRadius('dialog'),
        gradient: primaryGradient,
        boxShadow: getBrandShadow('heavy'),
      );

  // Buttons
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        // Use the brand button color so buttons are visible and accessible by default
        backgroundColor: AppColors.buttonPrimary,
        shadowColor: AppColors.buttonPrimary.withOpacity(0.24),
        elevation: 2,
        padding: PlatformUIStandards.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: PlatformUIStandards.getBorderRadius('button'),
        ),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary, width: 1.5),
        padding: PlatformUIStandards.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: PlatformUIStandards.getBorderRadius('button'),
        ),
      );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
        foregroundColor: primary,
        padding: PlatformUIStandards.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: PlatformUIStandards.getBorderRadius('button'),
        ),
      );

  // Form field with gradient frame (used in Login)
  static Widget gradientTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            labelText,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 14,
              color: DesignSystem.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: primaryGradient,
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              onTap: onTap,
              readOnly: readOnly,
              maxLines: maxLines,
              style: const TextStyle(fontFamily: 'Rubik', fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: '',
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 14,
                  color: Colors.grey,
                ),
                prefixIcon: Icon(
                  prefixIcon,
                  color: primary,
                  size: 20,
                ),
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: error, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppColors {
  // 2025 CANDY Brand Color Palette - Purple & Blue Theme
  static const Color primary = Color(0xFF6B46C1); // Deep Purple (CANDY Brand)
  static const Color primaryLight = Color(0xFF8B5CF6); // Light Purple
  static const Color primaryDark = Color(0xFF4C1D95); // Dark Purple
  static const Color primaryVibrant = Color(0xFF7C3AED); // Vibrant Purple

  // Secondary Water Colors - Blue & Cyan Theme
  static const Color secondary = Color(0xFF0EA5E9); // Sky Blue (Water Drop)
  static const Color secondaryLight = Color(0xFF7DD3FC); // Light Sky Blue
  static const Color secondaryDark = Color(0xFF0369A1); // Deep Sky Blue
  static const Color secondaryVibrant = Color(
    0xFF06B6D4,
  ); // Cyan (Water Essence)

  // Accent Colors - Mountain & Lightning Theme
  static const Color accent = Color(0xFF8B5CF6); // Purple Accent
  static const Color accentLight = Color(0xFFA78BFA); // Light Purple
  static const Color accentDark = Color(0xFF6D28D9); // Dark Purple
  static const Color accentVibrant = Color(0xFF7C3AED); // Vibrant Purple

  // 2025 Glassmorphism Colors
  static const Color glassBackground = Color(0x80FFFFFF);
  static const Color glassBackgroundDark = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x1A0EA5E9);
  static const Color glassBorderDark = Color(0x1AFFFFFF);
  static const Color glassShadow = Color(0x0A000000);
  static const Color glassShadowDark = Color(0x0AFFFFFF);

  // Background Colors - Soft & Calming
  static const Color background = Color(0xFFF0F9FF); // Soft Blue
  static const Color backgroundVariant = Color(0xFFE0F2FE); // Lighter Blue
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceVariant = Color(0xFFF8FAFC); // Soft White

  // Text Colors - Enhanced Contrast
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF); // White

  // Status Colors - Meaningful & Accessible
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFF34D399); // Emerald 400
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFCD34D); // Amber 400
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFF87171); // Red 400
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFF60A5FA); // Blue 400

  // Water Tracking Colors - CANDY Water Theme
  static const Color waterBlue = Color(0xFF0EA5E9); // Sky Blue (Water Drop)
  static const Color waterLight = Color(0xFF7DD3FC); // Light Sky Blue
  static const Color waterDark = Color(0xFF0369A1); // Deep Sky Blue
  static const Color waterAccent = Color(0xFF06B6D4); // Cyan (Water Essence)
  static const Color waterVibrant = Color(0xFF00D4FF); // Bright Cyan

  // Rating Colors - CANDY Purple Theme
  static const Color rating = Color(0xFF8B5CF6); // Purple Rating
  static const Color ratingLight = Color(0xFFA78BFA); // Light Purple
  static const Color ratingVibrant = Color(0xFF7C3AED); // Vibrant Purple

  // 2025 Advanced Shadow System
  static const Color shadowLight = Color(0x0A0EA5E9);
  static const Color shadowMedium = Color(0x1A0EA5E9);
  static const Color shadowDark = Color(0x330EA5E9);
  static const Color shadowVibrant = Color(0x1A06B6D4);

  // 2025 CANDY Dynamic Gradients - Purple & Blue Theme
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVibrant, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient waterGradient = LinearGradient(
    colors: [waterBlue, waterVibrant, waterAccent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.7, 1.0],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, primaryVibrant, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentVibrant, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // 2025 Radial Gradients for Depth
  static const RadialGradient primaryRadial = RadialGradient(
    colors: [primaryLight, primary, primaryDark],
    center: Alignment.center,
    radius: 1.0,
  );

  static const RadialGradient waterRadial = RadialGradient(
    colors: [waterLight, waterBlue, waterDark],
    center: Alignment.center,
    radius: 1.0,
  );

  // 2025 Conic Gradients for Dynamic Effects
  static const SweepGradient primarySweep = SweepGradient(
    colors: [primary, primaryVibrant, secondaryVibrant, primary],
    center: Alignment.center,
    startAngle: 0.0,
    endAngle: 2 * 3.14159,
  );

  // Card Colors - Enhanced Glassmorphism
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundGlass = Color(0xCCFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardBorderGlass = Color(0x1A0EA5E9);
  static const Color cardShadow = Color(0x0A0EA5E9);

  // Button Colors - Enhanced States
  static const Color buttonPrimary = Color(0xFF0EA5E9);
  static const Color buttonPrimaryHover = Color(0xFF0284C7);
  static const Color buttonSecondary = Color(0xFF10B981);
  static const Color buttonSecondaryHover = Color(0xFF059669);
  static const Color buttonAccent = Color(0xFFF59E0B);
  static const Color buttonAccentHover = Color(0xFFD97706);
  static const Color buttonDisabled = Color(0xFFCBD5E1);

  // Input Colors - Enhanced Focus States
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBackgroundGlass = Color(0xCCFFFFFF);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputFocus = Color(0xFF0EA5E9);
  static const Color inputFocusVibrant = Color(0xFF06B6D4);
  static const Color inputError = Color(0xFFEF4444);

  // Navigation Colors - Enhanced Selection
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navBackgroundGlass = Color(0xCCFFFFFF);
  static const Color navSelected = Color(0xFF0EA5E9);
  static const Color navSelectedVibrant = Color(0xFF06B6D4);
  static const Color navUnselected = Color(0xFF94A3B8);

  // 2025 Neumorphism Colors (Subtle)
  static const Color neumorphismLight = Color(0xFFFFFFFF);
  static const Color neumorphismDark = Color(0xFFE2E8F0);
  static const Color neumorphismShadowLight = Color(0x1A000000);
  static const Color neumorphismShadowDark = Color(0x1A000000);

  // 2025 CANDY Organic Shape Colors
  static const Color organicPrimary = Color(0xFF6B46C1); // Deep Purple
  static const Color organicSecondary = Color(0xFF0EA5E9); // Sky Blue
  static const Color organicAccent = Color(0xFF8B5CF6); // Purple Accent

  // 2025 CANDY Micro-interaction Colors
  static const Color microInteractionSuccess = Color(0xFF10B981);
  static const Color microInteractionWarning = Color(
    0xFF8B5CF6,
  ); // Purple Warning
  static const Color microInteractionError = Color(0xFFEF4444);
  static const Color microInteractionInfo = Color(0xFF0EA5E9); // Blue Info

  // 2025 Accessibility Colors (High Contrast)
  static const Color accessibilityHighContrast = Color(0xFF000000);
  static const Color accessibilityLowContrast = Color(0xFF6B7280);
  static const Color accessibilityFocus = Color(0xFF06B6D4);

  // 2025 Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // 2025 CANDY Animation Colors
  static const Color animationPrimary = Color(0xFF6B46C1); // Deep Purple
  static const Color animationSecondary = Color(0xFF0EA5E9); // Sky Blue
  static const Color animationAccent = Color(0xFF8B5CF6); // Purple Accent
  static const Color animationSuccess = Color(0xFF10B981);
  static const Color animationError = Color(0xFFEF4444);
}
