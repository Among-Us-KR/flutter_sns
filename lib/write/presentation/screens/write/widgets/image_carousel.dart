import 'dart:io';
import 'package:flutter/material.dart';

// 상수 정의
class ImageCarouselConstants {
  static const int maxImages = 5;
  static const Duration animationDuration = Duration(milliseconds: 250);
}

/// 페이지 스냅 없이 좌우로 자유 스크롤하는 카루셀
class ImageCarouselFreeScroll extends StatelessWidget {
  final List<File> images;
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
        // 카드 폭
        final cardW = (constraints.maxWidth - 2) * 0.7; // 꽉 채우고 싶으면 -2 대신 0
        final cardH = cardW * _aspect;

        final hasAdd = images.length < ImageCarouselConstants.maxImages;
        final itemCount = images.length + (hasAdd ? 1 : 0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목: "사진 n/5"
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
                  // 마지막에 "추가" 타일
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

                  // 실제 이미지 카드
                  return SizedBox(
                    width: cardW,
                    height: cardH,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SafeImageCard(
                        key: ValueKey(images[i].path),
                        image: images[i],
                        indexLabel: '${i + 1}/${images.length}', // 좌상단 순번
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

// 이미지 카드
class SafeImageCard extends StatelessWidget {
  // 매개변수 타입을 XFile에서 File로 변경
  final File image;
  final String indexLabel; // "n/total"
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
          // 안전한 이미지 로딩
          FutureBuilder<bool>(
            future: _checkFileExists(),
            builder: (context, snapshot) {
              if (snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
                return _buildErrorPlaceholder(context);
              }
              if (!snapshot.hasData) {
                return _buildLoadingPlaceholder(context);
              }
              return GestureDetector(
                onTap: onReplace,
                child: Image.file(
                  // image 객체를 직접 사용
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildErrorPlaceholder(context);
                  },
                ),
              );
            },
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

  Future<bool> _checkFileExists() async {
    try {
      // image 객체를 직접 사용
      return await image.exists();
    } catch (_) {
      return false;
    }
  }

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
