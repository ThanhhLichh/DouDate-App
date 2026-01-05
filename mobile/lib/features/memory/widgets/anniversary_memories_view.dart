import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import '../models/memory_models.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class AnniversaryMemoriesView extends StatefulWidget {
  final List<Memory> memories;

  const AnniversaryMemoriesView({super.key, required this.memories});

  @override
  State<AnniversaryMemoriesView> createState() =>
      _AnniversaryMemoriesViewState();
}

class _AnniversaryMemoriesViewState extends State<AnniversaryMemoriesView> {
  late PageController _pageController;
  late ConfettiController _confettiController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Trigger confetti when page loads
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Play confetti when changing to new memory
    _confettiController.play();
  }

  int _getYearsAgo(DateTime date) {
    final now = DateTime.now();
    return now.year - date.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.memories.length,
            itemBuilder: (context, index) {
              return _buildMemoryPage(widget.memories[index]);
            },
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.pink,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),

          // Top bar with close button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(context.space(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.space(16),
                      vertical: context.space(8),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.memories.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Page indicators (dots)
          if (widget.memories.length > 1)
            Positioned(
              bottom: context.space(120),
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.memories.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: context.space(4)),
                    width: _currentIndex == index
                        ? context.space(24)
                        : context.space(8),
                    height: context.space(8),
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemoryPage(Memory memory) {
    final yearsAgo = _getYearsAgo(memory.createdAt);

    return Column(
      children: [
        // Image section
        Expanded(
          flex: 2,
          child: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: context.space(16)),
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black,
                  //     blurRadius: 30,
                  //     spreadRadius: 5,
                  //   ),
                  // ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    memory.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: Icon(
                          Icons.image_not_supported,
                          size: context.space(80),
                          color: Colors.grey[700],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        // Anniversary celebration message
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            // padding: EdgeInsets.all(context.space(10)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87, Colors.black],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Celebration icon
                Icon(
                  Icons.celebration,
                  size: context.space(60),
                  color: Colors.amber,
                ),
                SizedBox(height: context.space(16)),

                // Anniversary title
                Text(
                  yearsAgo == 0
                      ? 'Happy Memory Day! 🎉'
                      : '$yearsAgo Year${yearsAgo > 1 ? "s" : ""} Anniversary! 🎊',
                  style: TextStyle(
                    fontSize: context.sp(AppDimensions.fontXL),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.space(12)),

                // Memory title
                Text(
                  memory.title,
                  style: TextStyle(
                    fontSize: context.sp(AppDimensions.fontXL),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.space(8)),

                // Date
                Text(
                  DateFormat('MMMM dd, yyyy').format(memory.createdAt),
                  style: TextStyle(
                    fontSize: context.sp(AppDimensions.fontM),
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.space(16)),

                // Description
                Container(
                  constraints: BoxConstraints(maxHeight: context.space(100)),
                  child: SingleChildScrollView(
                    child: Text(
                      memory.description,
                      style: TextStyle(
                        fontSize: context.sp(AppDimensions.fontM),
                        color: Colors.white60,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
