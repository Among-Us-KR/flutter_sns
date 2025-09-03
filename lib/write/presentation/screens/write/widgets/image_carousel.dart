import 'dart:io';
import 'package:flutter/material.dart';

// 상수 정의
class ImageCarouselConstants {
  static const int maxImages = 5;
  static const Duration animationDuration = Duration(milliseconds: 250);
}

/// 페이지 스냅 없이 좌우로 자유 스크롤하는 카루셀
class ImageCarouselFreeScroll extends StatelessWidget {
  // ✅ List<File> 대신 List<dynamic>으로 변경하여 String도 받을 수 있도록 합니다.
  final List<dynamic> images;
  final VoidCallback onAdd;
  final Function(int) onReplace;
  final Function(int) onRemove;

  const ImageCarouselFreeScroll({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onReplace,
    required this.onRemove,
  });

  static const _gap = 3.0;
  static const _aspect = 617 / 375; // 높이 = 너비 * 이 비율

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = (constraints.maxWidth - 2) * 0.7;
        final cardH = cardW * _aspect;

        final hasAdd = images.length < ImageCarouselConstants.maxImages;
        final itemCount = images.length + (hasAdd ? 1 : 0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '사진 ${images.length}/${ImageCarouselConstants.maxImages}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),

            SizedBox(
              height: cardH,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(width: _gap),
                itemBuilder: (context, i) {
                  if (hasAdd && i == images.length) {
                    return SizedBox(
                      width: cardW,
                      height: cardH,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ImageAddTile(onTap: onAdd),
                      ),
                    );
                  }

                  // ✅ SafeImageCard를 사용하여 이미지 타입에 따라 다르게 처리합니다.
                  return SizedBox(
                    width: cardW,
                    height: cardH,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SafeImageCard(
                        // ✅ image 객체를 직접 전달합니다.
                        image: images[i],
                        indexLabel: '${i + 1}/${images.length}',
                        onReplace: () => onReplace(i),
                        onRemove: () => onRemove(i),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ✅ SafeImageCard 위젯의 image 매개변수 타입을 dynamic으로 변경합니다.
class SafeImageCard extends StatelessWidget {
  final dynamic image;
  final String indexLabel;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  const SafeImageCard({
    super.key,
    required this.image,
    required this.indexLabel,
    required this.onReplace,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ FutureBuilder를 제거하고 즉시 이미지 위젯을 사용합니다.
          // 타입에 따라 다른 로더를 사용합니다.
          GestureDetector(
            onTap: onReplace,
            child: image is File
                ? Image.file(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorPlaceholder(context);
                    },
                  )
                : Image.network(
                    image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingPlaceholder(context);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorPlaceholder(context);
                    },
                  ),
          ),

          // 좌측 상단 순번 배지
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                indexLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // 우측 상단 삭제 버튼
          Positioned(
            top: 8,
            right: 8,
            child: ImageRemoveButton(onTap: onRemove),
          ),
        ],
      ),
    );
  }

  // ✅ _checkFileExists 메서드는 더 이상 필요하지 않습니다.
  // ✅ NetworkImage 로딩을 위해 _buildLoadingPlaceholder를 사용합니다.
  Widget _buildErrorPlaceholder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.errorContainer,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, size: 48, color: cs.onErrorContainer),
            const SizedBox(height: 8),
            Text(
              '이미지 로딩 실패',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// 이미지 추가 타일
class ImageAddTile extends StatelessWidget {
  final VoidCallback onTap;
  const ImageAddTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 36,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                '이미지 추가',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 이미지 삭제 버튼
class ImageRemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  const ImageRemoveButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
