import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'memory_controller.dart';
import 'widgets/memory_card_widget.dart';
import 'widgets/memory_empty_state.dart';
import 'widgets/create_memory_modal.dart';
import 'widgets/all_photos_view.dart';
import '../../core/theme/app_color.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';

class MemoriesPage extends StatefulWidget {
  const MemoriesPage({super.key});

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryController>().loadMemories();
      _checkTodayMemories();
    });
  }

  Future<void> _checkTodayMemories() async {
    final controller = context.read<MemoryController>();
    final todayMemories = await controller.getTodayMemories();

    if (mounted && todayMemories.isNotEmpty) {
      _showMemoryReminder(todayMemories);
    }
  }

  void _showMemoryReminder(List<dynamic> memories) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primary),
            SizedBox(width: context.space(8)),
            Text(
              'Memory Anniversary!',
              style: TextStyle(fontSize: context.sp(AppDimensions.fontM)),
            ),
          ],
        ),
        content: Text(
          'You have ${memories.length} memory anniversar${memories.length > 1 ? "ies" : "y"} today! 🎉',
          style: TextStyle(fontSize: context.sp(AppDimensions.fontM)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'View Memories',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: context.sp(AppDimensions.fontM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateMemoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateMemoryModal(isEditing: false),
    );
  }

  void _showEditMemoryModal(dynamic memory) {
    final controller = context.read<MemoryController>();
    controller.setEditingMemory(memory);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateMemoryModal(isEditing: true),
    );
  }

  void _showAllPhotos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllPhotosView()),
    );
  }

  void _showMemoryActions(dynamic memory, MemoryController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Memory'),
              onTap: () {
                Navigator.pop(context);
                _showEditMemoryModal(memory);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Memory'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(memory, controller);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(dynamic memory, MemoryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Memory?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteMemory(memory.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Memory deleted' : 'Failed to delete memory',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildMemoriesList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateMemoryModal,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_a_photo),
        // label: const Text(''),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(context.space(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Our Memories',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontXXL),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            onPressed: _showAllPhotos,
            icon: Icon(
              Icons.grid_view_rounded,
              size: context.space(AppDimensions.iconL),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoriesList() {
    return Consumer<MemoryController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.memories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.memories.isEmpty) {
          return const MemoryEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.loadMemories,
          child: ListView.builder(
            padding: EdgeInsets.all(context.space(16)),
            itemCount: controller.memories.length,
            itemBuilder: (context, index) {
              final memory = controller.memories[index];
              return MemoryCard(
                memory: memory,
                onMoreTap: () => _showMemoryActions(memory, controller),
              );
            },
          ),
        );
      },
    );
  }
}
