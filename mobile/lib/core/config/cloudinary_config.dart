class CloudinaryConfig {
  // ============ CLOUDINARY CREDENTIALS ============
  static const String cloudName = 'dlm42p9vi';
  static const String uploadPreset = 'duo_date_app';

  // ============ UPLOAD ENDPOINTS ============
  static String get imageUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  static String get videoUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/video/upload';

  static String get rawUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/raw/upload';

  // ============ FOLDER STRUCTURE ============
  static const String avatarFolder = 'avatars';
  static const String chatFolder = 'chat_images';
  static const String memoryFolder = 'memories';
  static const String momentFolder = 'moments';

  // ============ IMAGE CONSTRAINTS ============
  // Avatar settings
  static const int avatarSize = 512;
  static const int avatarQuality = 90;

  // Chat image settings
  static const int chatImageMaxWidth = 1920;
  static const int chatImageMaxHeight = 1920;
  static const int chatImageQuality = 85;

  // Memory/Moment image settings
  static const int memoryImageMaxWidth = 2048;
  static const int memoryImageMaxHeight = 2048;
  static const int memoryImageQuality = 90;

  // Thumbnail settings
  static const int thumbnailSize = 300;
  static const int thumbnailQuality = 80;

  // ============ FILE CONSTRAINTS ============
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
  ];

  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi', 'webm'];

  // ============ TRANSFORMATION PRESETS ============
  static String avatarTransformation(String publicId) {
    return 'https://res.cloudinary.com/$cloudName/image/upload/'
        'c_fill,w_$avatarSize,h_$avatarSize,g_face,q_$avatarQuality,f_auto/'
        '$publicId';
  }

  static String thumbnailTransformation(String publicId) {
    return 'https://res.cloudinary.com/$cloudName/image/upload/'
        'c_fill,w_$thumbnailSize,h_$thumbnailSize,q_$thumbnailQuality,f_auto/'
        '$publicId';
  }

  static String chatImageTransformation(String publicId) {
    return 'https://res.cloudinary.com/$cloudName/image/upload/'
        'w_$chatImageMaxWidth,h_$chatImageMaxHeight,c_limit,q_$chatImageQuality,f_auto/'
        '$publicId';
  }

  // ============ HELPER METHODS ============
  /// Validate file size
  static bool isFileSizeValid(int bytes) {
    return bytes <= maxFileSizeBytes;
  }

  /// Get file size in MB
  static double getFileSizeMB(int bytes) {
    return bytes / (1024 * 1024);
  }

  /// Validate image format
  static bool isImageFormatValid(String extension) {
    return allowedImageFormats.contains(extension.toLowerCase());
  }

  /// Validate video format
  static bool isVideoFormatValid(String extension) {
    return allowedVideoFormats.contains(extension.toLowerCase());
  }

  /// Generate unique public ID
  static String generatePublicId(String folder, String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$folder/${prefix}_$timestamp';
  }
}
