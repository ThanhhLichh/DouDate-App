import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'cloudinary_service.dart';
import '../models/cloudinary_models.dart';

/// High-level wrapper cho image picking và uploading
class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinary = CloudinaryService();

  // ============ AVATAR METHODS WITH CROPPER ============

  /// Pick và upload avatar với cropping
  Future<String?> pickAndUploadAvatar(int userId) async {
    try {
      // 1. Pick image từ gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Chất lượng max trước khi crop
      );

      if (image == null) {
        debugPrint('No image selected');
        return null;
      }

      // 2. Crop thành hình vuông
      final croppedFile = await _cropImageToSquare(image.path);

      if (croppedFile == null) {
        debugPrint('Crop cancelled');
        return null;
      }

      // 3. Upload to Cloudinary
      final response = await _cloudinary.uploadAvatar(
        File(croppedFile.path),
        userId,
      );

      // 4. Clean up cropped file
      await _deleteTempFile(croppedFile.path);

      debugPrint('Avatar uploaded: ${response.secureUrl}');
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      debugPrint('Cloudinary error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return null;
    }
  }

  /// Take photo và upload avatar với cropping
  Future<String?> takePhotoAndUploadAvatar(int userId) async {
    try {
      // 1. Take photo
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image == null) {
        debugPrint('No photo taken');
        return null;
      }

      // 2. Crop thành hình vuông
      final croppedFile = await _cropImageToSquare(image.path);

      if (croppedFile == null) {
        debugPrint('Crop cancelled');
        return null;
      }

      // 3. Upload to Cloudinary
      final response = await _cloudinary.uploadAvatar(
        File(croppedFile.path),
        userId,
      );

      // 4. Clean up temp files
      await _deleteTempFile(image.path);
      await _deleteTempFile(croppedFile.path);

      debugPrint('Avatar uploaded: ${response.secureUrl}');
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      debugPrint('Cloudinary error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return null;
    }
  }

  // ============ HELPER: IMAGE CROPPER ============

  /// Crop image to square (1:1 aspect ratio)
  Future<CroppedFile?> _cropImageToSquare(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
        uiSettings: [
          // ================= ANDROID =================
          AndroidUiSettings(
            toolbarTitle: 'Crop Avatar',
            toolbarColor: const Color(0xFF0084FF),
            toolbarWidgetColor: Colors.white,
            statusBarColor: const Color(0xFF0084FF),
            backgroundColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFF0084FF),
            lockAspectRatio: true,
            hideBottomControls: false,
            initAspectRatio: CropAspectRatioPreset.square,
          ),

          // ================= IOS =================
          IOSUiSettings(
            title: 'Crop Avatar',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            rotateButtonsHidden: false,
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      return croppedFile;
    } catch (e) {
      debugPrint('Crop error: $e');
      return null;
    }
  }

  /// Delete temporary file
  Future<void> _deleteTempFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete temp file: $e');
    }
  }

  // ============ CHAT IMAGE METHODS ============

  /// Pick và upload chat image (không crop)
  Future<CloudinaryUploadResponse?> pickAndUploadChatImage(int coupleId) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;

      final response = await _cloudinary.uploadChatImage(
        File(image.path),
        coupleId,
      );

      return response;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  /// Take photo và upload chat image
  Future<CloudinaryUploadResponse?> takePhotoAndUploadChatImage(
    int coupleId,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return null;

      final response = await _cloudinary.uploadChatImage(
        File(image.path),
        coupleId,
      );

      return response;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  // ============ MEMORY IMAGE METHODS ============

  /// Pick và upload memory image
  Future<CloudinaryUploadResponse?> pickAndUploadMemoryImage(
    int coupleId,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return null;

      final response = await _cloudinary.uploadMemoryImage(
        File(image.path),
        coupleId,
      );

      return response;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  /// Pick multiple images cho memory album
  Future<List<CloudinaryUploadResponse>> pickAndUploadMultipleMemoryImages(
    int coupleId,
  ) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);

      if (images.isEmpty) return [];

      final List<CloudinaryUploadResponse> uploadedImages = [];

      for (final image in images) {
        try {
          final response = await _cloudinary.uploadMemoryImage(
            File(image.path),
            coupleId,
          );
          uploadedImages.add(response);
        } catch (e) {
          debugPrint('Failed to upload image: ${image.path}');
          // Continue với images còn lại
        }
      }

      return uploadedImages;
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  // ============ MOMENT IMAGE METHODS ============

  /// Pick và upload moment image
  Future<CloudinaryUploadResponse?> pickAndUploadMomentImage(
    int coupleId,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return null;

      final response = await _cloudinary.uploadMomentImage(
        File(image.path),
        coupleId,
      );

      return response;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }
}
