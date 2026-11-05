import 'package:flutter/material.dart';

class AppColors {
  // Agricultural Palette matching generated HTML
  static const Color primaryGreen = Color(0xFF1E4D2B);    // Exact #1E4D2B
  static const Color primaryDark = Color(0xFF123320);     // Exact #123320 3D shadow
  static const Color tactileGreenShadow = Color(0xFF123320); // Tactile 3D bottom shadow
  static const Color primaryLight = Color(0xFF2B6A3E);    // Exact #2B6A3E hill shade
  static const Color mintTint = Color(0xFFE2EFDF);        // Exact #E2EFDF nav pill & squircle
  static const Color mintAccent = Color(0xFFDDEFD9);      // Exact #DDEFD9 active pill
  static const Color lightGreen = Color(0xFFE2EFDF);       // Compatibility alias
  static const Color softMutedGreen = Color(0xFFDDEFD9);  // Compatibility alias
  
  static const Color creamBg = Color(0xFFF6F2E9);         // Exact #F6F2E9 canvas background
  static const Color companionCard = Color(0xFFE2EFDF);   // Sage card wash
  static const Color cardWhite = Colors.white;            // Pure white card face
  
  static const Color textDark = Color(0xFF1B2A21);        // Exact #1B2A21 primary text
  static const Color textMuted = Color(0xFF55655A);       // Exact #55655A secondary text
  static const Color textLight = Color(0xFF7A877E);       // Exact #7A877E subtle chevrons
  
  static const Color accentGold = Color(0xFFF2B134);      // Exact #F2B134 harvest gold
  static const Color cardGold = Color(0xFFF2B134);        // Exact #F2B134 harvest gold alias
  static const Color accentGoldLight = Color(0xFFFCEFD0); // Exact #FCEFD0 amber squircle
  static const Color alertSoft = Color(0xFFFCEFD0);       // Compatibility alias
  static const Color borderLight = Color(0xFFE6E0D2);     // Exact #E6E0D2 card border
  static const Color cardShadow = Color(0xFFE9E2D1);      // Exact #E9E2D1 card bottom shadow
  static const Color dividerLight = Color(0xFFEEE8DA);    // Exact #EEE8DA card divider
}

class AppStyles {
  // Safe cross-platform font family fallback list for Apple (iOS), Android, and Web
  static const List<String> fontFallbacks = [
    'Mukta',
    'Noto Sans Devanagari',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'sans-serif',
  ];

  // Uniform Page Kicker / Section Category Label
  static const TextStyle kicker = TextStyle(
    fontFamily: 'Mukta',
    fontFamilyFallback: fontFallbacks,
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: Color(0xFF3A6B4A),
  );

  // Uniform Main Screen Title
  static const TextStyle pageTitle = TextStyle(
    fontFamily: 'Mukta',
    fontFamilyFallback: fontFallbacks,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.1,
  );

  // Uniform Screen Subtitle
  static const TextStyle pageSubtitle = TextStyle(
    fontFamily: 'Mukta',
    fontFamilyFallback: fontFallbacks,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Uniform Section Header
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: 'Mukta',
    fontFamilyFallback: fontFallbacks,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Uniform White Card Box Decoration (.c from HTML design)
  static final BoxDecoration cardBox = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: AppColors.borderLight, width: 1.0),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadow,
        offset: Offset(0, 3),
        blurRadius: 0,
      ),
    ],
  );

  // Uniform Primary Button Decoration (Green with 3D tactile bottom shadow)
  static final BoxDecoration primaryButtonBox = BoxDecoration(
    color: AppColors.primaryGreen,
    borderRadius: BorderRadius.circular(26),
    boxShadow: const [
      BoxShadow(
        color: AppColors.primaryDark,
        offset: Offset(0, 4),
        blurRadius: 0,
      ),
    ],
  );

  // Uniform Secondary / Outline Button Decoration
  static final BoxDecoration outlineButtonBox = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    border: Border.all(color: AppColors.primaryGreen, width: 1.5),
  );

  // Uniform Gold Accent Button Decoration (+ Add crop, etc.)
  static final BoxDecoration goldButtonBox = BoxDecoration(
    color: AppColors.accentGold,
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(
        color: Color(0xFFC98F1C),
        offset: Offset(0, 3),
        blurRadius: 0,
      ),
    ],
  );

  // Uniform Circular Back Button Decoration
  static final BoxDecoration backButtonBox = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: const Color(0xFFDDD6C4), width: 1.0),
  );

  // Responsive padding helper for seamless safe area on iPhone (Dynamic Island / Home Indicator) and Android
  static EdgeInsets pagePadding(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset);
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.creamBg,
      primaryColor: AppColors.primaryGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        background: AppColors.creamBg,
        surface: AppColors.cardWhite,
      ),
      fontFamily: 'Mukta',
      fontFamilyFallback: AppStyles.fontFallbacks,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.creamBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textDark, size: 22),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Mukta',
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
