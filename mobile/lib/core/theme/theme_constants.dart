class ThemeConstants {
  // Storage keys
  static const String themeStorageKey = 'dashboard_theme';
  static const String customThemeKey = 'custom_dashboard_theme';

  // Image storage paths
  static const String themeImagesDir = 'theme_images';
  static const String coupleBackgroundFileName = 'couple_background.jpg';
  static const String partnerAvatarFileName = 'partner_avatar.jpg';
  static const String yourAvatarFileName = 'your_avatar.jpg';

  // Image quality settings
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;

  // Validation constants
  static const double minContrastRatio = 4.5; // WCAG AA standard
  static const double minBrightnessDifference = 125;

  // Default asset paths (fallbacks)
  static const String defaultCoupleBackground = 'assets/images/couple_img.jpg';
  static const String defaultAvatar = 'assets/images/logo_login.png';

  // Theme customization options
  static const List<String> customizableProperties = [
    'primaryColor',
    'accentColor',
    'cardBackground',
    'heartIconColor',
    'partnerBorderColor',
    'yourBorderColor',
    'textPrimaryColor',
    'textSecondaryColor',
  ];

  // Error messages
  static const String imageLoadError = 'Failed to load image';
  static const String imageSaveError = 'Failed to save image';
  static const String themeLoadError = 'Failed to load theme';
  static const String themeSaveError = 'Failed to save theme';
  static const String invalidImageFormat = 'Invalid image format';
  static const String imageTooLarge = 'Image size exceeds limit';
}
