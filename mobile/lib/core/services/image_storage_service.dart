import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../theme/theme_constants.dart';

class ImageStorageService {
  /// Get the theme images directory
  Future<Directory> _getThemeImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final themeDir = Directory(
      path.join(appDir.path, ThemeConstants.themeImagesDir),
    );

    if (!await themeDir.exists()) {
      await themeDir.create(recursive: true);
    }

    return themeDir;
  }

  /// Save couple background image
  /// Returns the relative path to the saved image
  Future<String> saveCoupleBackground(File imageFile) async {
    try {
      // Validate image
      await _validateImage(imageFile);

      // Process and save image
      final processedImage = await _processImage(imageFile);
      final themeDir = await _getThemeImagesDirectory();
      final targetPath = path.join(
        themeDir.path,
        ThemeConstants.coupleBackgroundFileName,
      );

      // Save processed image
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(processedImage);

      // Return relative path
      return path.join(
        ThemeConstants.themeImagesDir,
        ThemeConstants.coupleBackgroundFileName,
      );
    } catch (e) {
      throw ImageStorageException(
        'Failed to save couple background: ${e.toString()}',
      );
    }
  }

  /// Load image from relative path
  Future<File?> loadImage(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      return null;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = path.join(appDir.path, relativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }

  /// Delete image at relative path
  Future<void> deleteImage(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      return;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = path.join(appDir.path, relativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  /// Delete all theme images
  Future<void> deleteAllThemeImages() async {
    try {
      final themeDir = await _getThemeImagesDirectory();
      if (await themeDir.exists()) {
        await themeDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error deleting theme images: $e');
    }
  }

  /// Validate image file
  Future<void> _validateImage(File imageFile) async {
    // Check if file exists
    if (!await imageFile.exists()) {
      throw ImageStorageException(ThemeConstants.imageLoadError);
    }

    // Check file size (max 10MB)
    final fileSize = await imageFile.length();
    if (fileSize > 10 * 1024 * 1024) {
      throw ImageStorageException(ThemeConstants.imageTooLarge);
    }

    // Check file extension
    final ext = path.extension(imageFile.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
      throw ImageStorageException(ThemeConstants.invalidImageFormat);
    }
  }

  /// Process image: resize and compress
  Future<Uint8List> _processImage(
    File imageFile, {
    bool isAvatar = false,
  }) async {
    // Read image bytes
    final bytes = await imageFile.readAsBytes();

    // Decode image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw ImageStorageException('Failed to decode image');
    }

    // Resize if needed
    int maxWidth = isAvatar ? 512 : ThemeConstants.maxImageWidth;
    int maxHeight = isAvatar ? 512 : ThemeConstants.maxImageHeight;

    if (image.width > maxWidth || image.height > maxHeight) {
      image = img.copyResize(
        image,
        width: image.width > maxWidth ? maxWidth : null,
        height: image.height > maxHeight ? maxHeight : null,
        interpolation: img.Interpolation.linear,
      );
    }

    // For avatars, crop to square and make circular
    if (isAvatar) {
      final size = image.width < image.height ? image.width : image.height;
      image = img.copyCrop(
        image,
        x: (image.width - size) ~/ 2,
        y: (image.height - size) ~/ 2,
        width: size,
        height: size,
      );
    }

    // Encode to JPEG with quality setting
    final encoded = img.encodeJpg(image, quality: ThemeConstants.imageQuality);

    return Uint8List.fromList(encoded);
  }

  /// Get file size in MB
  Future<double> getImageSizeMB(String? relativePath) async {
    if (relativePath == null) return 0.0;

    final file = await loadImage(relativePath);
    if (file == null) return 0.0;

    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Check if image exists
  Future<bool> imageExists(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      return false;
    }

    final file = await loadImage(relativePath);
    return file != null;
  }
}

class ImageStorageException implements Exception {
  final String message;
  ImageStorageException(this.message);

  @override
  String toString() => message;
}
