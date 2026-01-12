/// Response từ Cloudinary API
class CloudinaryUploadResponse {
  final String secureUrl;
  final String publicId;
  final int width;
  final int height;
  final int bytes;
  final String format;
  final String resourceType;
  final DateTime createdAt;
  final String? thumbnail;

  CloudinaryUploadResponse({
    required this.secureUrl,
    required this.publicId,
    required this.width,
    required this.height,
    required this.bytes,
    required this.format,
    required this.resourceType,
    required this.createdAt,
    this.thumbnail,
  });

  factory CloudinaryUploadResponse.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResponse(
      secureUrl: json['secure_url'] as String,
      publicId: json['public_id'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      bytes: json['bytes'] as int,
      format: json['format'] as String,
      resourceType: json['resource_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      thumbnail: json['thumbnail_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'secure_url': secureUrl,
    'public_id': publicId,
    'width': width,
    'height': height,
    'bytes': bytes,
    'format': format,
    'resource_type': resourceType,
    'created_at': createdAt.toIso8601String(),
    'thumbnail_url': thumbnail,
  };
}

/// Upload options
class CloudinaryUploadOptions {
  final String folder;
  final String? publicId;
  final int? maxWidth;
  final int? maxHeight;
  final int quality;
  final bool generateThumbnail;

  CloudinaryUploadOptions({
    this.folder = '',
    this.publicId,
    this.maxWidth,
    this.maxHeight,
    this.quality = 85,
    this.generateThumbnail = false,
  });
}

/// Error types
enum CloudinaryErrorType {
  networkError,
  fileTooLarge,
  invalidFormat,
  uploadFailed,
  compressionFailed,
  unknown,
}

/// Custom exception
class CloudinaryException implements Exception {
  final CloudinaryErrorType type;
  final String message;

  CloudinaryException(this.type, this.message);

  @override
  String toString() => 'CloudinaryException: $message';
}
