import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/domain/entities/category.dart';
import 'package:flutter_sns/write/presentation/screens/home/home_page.dart';

class TopTabBar extends ConsumerWidget {
  const TopTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 카테고리와 카테고리 목록
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categories = Category.values;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () {
              // 탭을 누르면 선택된 카테고리 상태를 업데이트
              ref.read(selectedCategoryProvider.notifier).state = category;
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brand : AppColors.n100,
                borderRadius: BorderRadius.circular(100),
              ),
              alignment: Alignment.center,
              child: Text(
                category.displayName,
                // AppTypography.s14는 TextStyle이 아닌 double(숫자) 타입이므로,
                // .copyWith를 직접 사용할 수 없습니다.
                // 다른 위젯에서 사용하는 AppTypography.style 헬퍼 메서드를 사용하도록 수정합니다.
                style: AppTypography.style(
                  AppTypography.s14,
                  weight: isSelected
                      ? AppTypography.bold
                      : AppTypography.regular,
                  color: isSelected ? Colors.white : AppColors.n800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
