import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';

/// 여러 이미지를 좌우로 스와이프하여 보여주는 위젯
class ImagePageView extends StatefulWidget {
  final List<String> imagePaths;
  final BoxFit fit;
  final bool showIndicator;

  const ImagePageView({
    super.key,
    required this.imagePaths,
    this.fit = BoxFit.cover,
    this.showIndicator = true,
  });

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool hasMultipleImages = widget.imagePaths.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          physics: hasMultipleImages
              ? const PageScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemCount: widget.imagePaths.length,
          itemBuilder: (context, index) {
            return Image.network(
              widget.imagePaths[index],
              fit: widget.fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            );
          },
        ),
        if (widget.showIndicator && hasMultipleImages)
          Positioned(
            top: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.imagePaths.length}',
                style: AppTypography.caption(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
