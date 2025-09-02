import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/no_glow_scroll_behavior.dart';

class TopTabBar extends StatefulWidget {
  const TopTabBar({super.key});

  @override
  State<TopTabBar> createState() => _TopTabBarState();
}

class _TopTabBarState extends State<TopTabBar> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['전체', '멍청스', '고민스', '대박스', '행복'];

  Widget _buildTab(int index) {
    bool isSelected = _selectedIndex == index;
    final textStyle = AppTypography.h3(
      isSelected ? AppColors.n900 : AppColors.n600,
    );

    return InkWell(
      onTap: () {
        // TODO: 탭 변경 시 실제 피드 필터링 로직 연동
        setState(() => _selectedIndex = index);
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_tabs[index], style: textStyle),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 40,
            color: isSelected ? AppColors.brand : Colors.transparent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: List.generate(
              _tabs.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: _buildTab(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
