import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import '../config/cloudinary_config.dart';
import '../models/cloudinary_models.dart';

class CloudinaryService {
  final Dio _dio;

  CloudinaryService()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      ) {
    // Add interceptor for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('CLOUDINARY REQUEST: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('CLOUDINARY RESPONSE: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('CLOUDINARY ERROR: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // ============ MAIN UPLOAD METHOD ============
  /// Upload image to Cloudinary với full options
  Future<CloudinaryUploadResponse> uploadImage(
    File imageFile, {
    CloudinaryUploadOptions? options,
  }) async {
    try {
      // 1. Validate file
      await _validateFile(imageFile);

      // 2. Compress and resize image
      final processedFile = await _processImage(
        imageFile,
        maxWidth: options?.maxWidth,
        maxHeight: options?.maxHeight,
        quality: options?.quality ?? 85,
      );

      // 3. Prepare upload data
      final formData = await _prepareFormData(processedFile, options: options);

      // 4. Upload to Cloudinary
      final response = await _dio.post(
        CloudinaryConfig.imageUploadUrl,
        data: formData,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
          debugPrint('Upload progress: $progress%');
        },
      );

      // 5. Parse response
      if (response.statusCode == 200 && response.data != null) {
        return CloudinaryUploadResponse.fromJson(response.data);
      } else {
        throw CloudinaryException(
          CloudinaryErrorType.uploadFailed,
          'Upload failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw CloudinaryException(
        CloudinaryErrorType.unknown,
        'Upload failed: ${e.toString()}',
      );
    }
  }

  // ============ SPECIALIZED UPLOAD METHODS ============

  /// Upload avatar (512x512, optimized for faces)
  Future<CloudinaryUploadResponse> uploadAvatar(
    File imageFile,
    int userId,
  ) async {
    final options = CloudinaryUploadOptions(
      folder: CloudinaryConfig.avatarFolder,
      publicId:
          'user_${userId}_avatar_${DateTime.now().millisecondsSinceEpoch}',
      maxWidth: CloudinaryConfig.avatarSize,
      maxHeight: CloudinaryConfig.avatarSize,
      quality: CloudinaryConfig.avatarQuality,
      generateThumbnail: false,
    );

    return await uploadImage(imageFile, options: options);
  }

  /// Upload chat image
  Future<CloudinaryUploadResponse> uploadChatImage(
    File imageFile,
    int coupleId,
  ) async {
    final options = CloudinaryUploadOptions(
      folder: CloudinaryConfig.chatFolder,
      publicId:
          'couple_${coupleId}_chat_${DateTime.now().millisecondsSinceEpoch}',
      maxWidth: CloudinaryConfig.chatImageMaxWidth,
      maxHeight: CloudinaryConfig.chatImageMaxHeight,
      quality: CloudinaryConfig.chatImageQuality,
      generateThumbnail: true,
    );

    return await uploadImage(imageFile, options: options);
  }

  /// Upload memory image
  Future<CloudinaryUploadResponse> uploadMemoryImage(
    File imageFile,
    int coupleId,
  ) async {
    final options = CloudinaryUploadOptions(
      folder: CloudinaryConfig.memoryFolder,
      publicId:
          'couple_${coupleId}_memory_${DateTime.now().millisecondsSinceEpoch}',
      maxWidth: CloudinaryConfig.memoryImageMaxWidth,
      maxHeight: CloudinaryConfig.memoryImageMaxHeight,
      quality: CloudinaryConfig.memoryImageQuality,
      generateThumbnail: true,
    );

    return await uploadImage(imageFile, options: options);
  }

  /// Upload moment image
  Future<CloudinaryUploadResponse> uploadMomentImage(
    File imageFile,
    int coupleId,
  ) async {
    final options = CloudinaryUploadOptions(
      folder: CloudinaryConfig.momentFolder,
      publicId:
          'couple_${coupleId}_moment_${DateTime.now().millisecondsSinceEpoch}',
      maxWidth: CloudinaryConfig.memoryImageMaxWidth,
      maxHeight: CloudinaryConfig.memoryImageMaxHeight,
      quality: CloudinaryConfig.memoryImageQuality,
      generateThumbnail: true,
    );

    return await uploadImage(imageFile, options: options);
  }

  // ============ HELPER METHODS ============

  /// Validate file trước khi upload
  Future<void> _validateFile(File file) async {
    // Check if file exists
    if (!await file.exists()) {
      throw CloudinaryException(
        CloudinaryErrorType.invalidFormat,
        'File does not exist',
      );
    }

    // Check file size
    final fileSize = await file.length();
    if (!CloudinaryConfig.isFileSizeValid(fileSize)) {
      throw CloudinaryException(
        CloudinaryErrorType.fileTooLarge,
        'File size (${CloudinaryConfig.getFileSizeMB(fileSize).toStringAsFixed(2)}MB) '
        'exceeds limit (${CloudinaryConfig.getFileSizeMB(CloudinaryConfig.maxFileSizeBytes).toStringAsFixed(2)}MB)',
      );
    }

    // Check file extension
    final extension = path.extension(file.path).replaceFirst('.', '');
    if (!CloudinaryConfig.isImageFormatValid(extension)) {
      throw CloudinaryException(
        CloudinaryErrorType.invalidFormat,
        'Invalid image format: $extension',
      );
    }
  }

  /// Process image: compress and resize
  Future<File> _processImage(
    File imageFile, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();

      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw CloudinaryException(
          CloudinaryErrorType.compressionFailed,
          'Failed to decode image',
        );
      }

      // Resize GIỮ NGUYÊN TỶ LỆ
      if (maxWidth != null && maxHeight != null) {
        // Tính aspect ratio
        final aspectRatio = image.width / image.height;

        int targetWidth;
        int targetHeight;

        // Resize theo cạnh nhỏ hơn để fit vào maxWidth x maxHeight
        if (aspectRatio > 1) {
          // Ảnh ngang: resize theo width
          targetWidth = maxWidth;
          targetHeight = (maxWidth / aspectRatio).round();
          // Ensure không vượt quá maxHeight
          if (targetHeight > maxHeight) {
            targetHeight = maxHeight;
            targetWidth = (maxHeight * aspectRatio).round();
          }
        } else {
          // Ảnh dọc hoặc vuông: resize theo height
          targetHeight = maxHeight;
          targetWidth = (maxHeight * aspectRatio).round();
          // Ensure không vượt quá maxWidth
          if (targetWidth > maxWidth) {
            targetWidth = maxWidth;
            targetHeight = (maxWidth / aspectRatio).round();
          }
        }

        // Chỉ resize nếu ảnh lớn hơn target
        if (image.width > targetWidth || image.height > targetHeight) {
          image = img.copyResize(
            image,
            width: targetWidth,
            height: targetHeight,
            interpolation: img.Interpolation.linear,
          );
        }
      } else if (maxWidth != null) {
        // Chỉ có maxWidth: resize theo width, height tự scale
        if (image.width > maxWidth) {
          image = img.copyResize(
            image,
            width: maxWidth,
            interpolation: img.Interpolation.linear,
          );
        }
      } else if (maxHeight != null) {
        // Chỉ có maxHeight: resize theo height, width tự scale
        if (image.height > maxHeight) {
          image = img.copyResize(
            image,
            height: maxHeight,
            interpolation: img.Interpolation.linear,
          );
        }
      }

      // Encode to JPEG with quality
      final compressedBytes = img.encodeJpg(image, quality: quality);

      // Save to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(compressedBytes);

      debugPrint(
        'Image processed: ${imageFile.lengthSync()} → ${tempFile.lengthSync()} bytes '
        '(${image.width}x${image.height})',
      );

      return tempFile;
    } catch (e) {
      debugPrint('Image processing error: $e');
      throw CloudinaryException(
        CloudinaryErrorType.compressionFailed,
        'Failed to process image: ${e.toString()}',
      );
    }
  }

  /// Prepare FormData for upload
  Future<FormData> _prepareFormData(
    File file, {
    CloudinaryUploadOptions? options,
  }) async {
    final fileName = path.basename(file.path);

    final Map<String, dynamic> data = {
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      'upload_preset': CloudinaryConfig.uploadPreset,
    };

    // Add optional parameters
    if (options != null) {
      if (options.folder.isNotEmpty) {
        data['folder'] = options.folder;
      }
      if (options.publicId != null) {
        data['public_id'] = options.publicId;
      }
    }

    return FormData.fromMap(data);
  }

  /// Handle Dio errors
  CloudinaryException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return CloudinaryException(
          CloudinaryErrorType.networkError,
          'Connection timeout. Please check your internet.',
        );

      case DioExceptionType.connectionError:
        return CloudinaryException(
          CloudinaryErrorType.networkError,
          'No internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['error']?['message'] ?? 'Upload failed';
        return CloudinaryException(
          CloudinaryErrorType.uploadFailed,
          'Upload failed ($statusCode): $message',
        );

      default:
        return CloudinaryException(
          CloudinaryErrorType.unknown,
          'Upload failed: ${error.message}',
        );
    }
  }

  // ============ DELETE METHOD (Optional) ============
  /// Delete image from Cloudinary
  /// Note: Requires API key and secret for signed requests
  Future<bool> deleteImage(String publicId) async {
    // TODO: Implement if needed (requires signed API)
    // This would need API key and signature generation
    debugPrint('Delete not implemented yet: $publicId');
    return false;
  }
}
