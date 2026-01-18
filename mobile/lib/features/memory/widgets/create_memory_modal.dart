import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/memory_controller.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class CreateMemoryModal extends StatefulWidget {
  final bool isEditing;

  const CreateMemoryModal({super.key, required this.isEditing});

  @override
  State<CreateMemoryModal> createState() => _CreateMemoryModalState();
}

class _CreateMemoryModalState extends State<CreateMemoryModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = context.read<MemoryController>();
        final memory = controller.editingMemory;
        if (memory != null) {
          _titleController.text = memory.title;
          _descriptionController.text = memory.description;
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickImageSource() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                context.read<MemoryController>().pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                context.read<MemoryController>().pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final controller = context.read<MemoryController>();

    bool success;
    if (widget.isEditing && controller.editingMemory != null) {
      String? imageBase64;
      if (controller.selectedImage != null) {
        final bytes = await controller.selectedImage!.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      success = await controller.updateMemory(
        memoryId: controller.editingMemory!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageBase64: imageBase64,
      );
    } else {
      success = await controller.createMemory(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    }

    if (mounted) {
      if (success) {
        controller.clearSelectedImage();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Memory updated successfully!'
                  : 'Memory created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.errorMessage ??
                  (widget.isEditing
                      ? 'Failed to update memory'
                      : 'Failed to create memory'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.space(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandleBar(context),
              SizedBox(height: context.space(20)),
              _buildTitle(context),
              SizedBox(height: context.space(24)),
              _buildImagePicker(context),
              SizedBox(height: context.space(20)),
              _buildTitleField(context),
              SizedBox(height: context.space(16)),
              _buildDescriptionField(context),
              SizedBox(height: context.space(24)),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandleBar(BuildContext context) {
    return Center(
      child: Container(
        width: context.space(40),
        height: context.space(4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.isEditing ? 'Edit Memory' : 'Create New Memory',
      style: TextStyle(
        fontSize: context.sp(AppDimensions.fontXL),
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Consumer<MemoryController>(
      builder: (context, controller, child) {
        final showExistingImage =
            widget.isEditing &&
            controller.selectedImage == null &&
            controller.editingMemory != null;

        return GestureDetector(
          onTap: _pickImageSource,
          child: Container(
            height: context.height * 0.25,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: controller.selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      controller.selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : showExistingImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      controller.editingMemory!.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: context.space(50),
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: context.space(8)),
                      Text(
                        widget.isEditing ? 'Change Photo' : 'Add Photo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: context.sp(AppDimensions.fontM),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'e.g., First Date',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return TextField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Tell us about this special moment...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Consumer<MemoryController>(
      builder: (context, controller, child) {
        return ElevatedButton(
          onPressed: controller.isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: context.space(16)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.isEditing ? 'Edit Memory' : 'Create Memory',
                  style: TextStyle(
                    fontSize: context.sp(AppDimensions.fontL),
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      },
    );
  }
}
