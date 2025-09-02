import 'dart:math' as math;
import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {
  final bool isValid; // [던지기] 활성 여부
  final VoidCallback onSubmit; // [던지기] 콜백
  final VoidCallback? onTempSave; // [임시저장] 콜백(없으면 비활성)

  const BottomButtons({
    super.key,
    required this.isValid,
    required this.onSubmit,
    this.onTempSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final kb = MediaQuery.of(context).viewInsets.bottom;

    // ✅ 모든 버튼 텍스트 기본 세미볼드
    final semibold = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Material(
      color: cs.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + math.max(0.0, kb)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 1,
                color: cs.outline.withValues(alpha: 0.12),
                margin: const EdgeInsets.only(bottom: 12),
              ),
              Row(
                children: [
                  // -----------------------
                  // 임시저장 버튼
                  // - 활성: 거의 검정 배경 + 흰 텍스트
                  // - 비활성: 회색 배경(0.12) + 회색 텍스트(0.38)
                  // -----------------------
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onTempSave,
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(
                          const Size.fromHeight(56),
                        ),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(semibold),
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.disabled)) {
                            return cs.onSurface.withValues(alpha: 0.12);
                          }
                          // 활성 시 거의 검정 느낌
                          return cs.onSurface; // 필요하면 withValues(alpha: 0.9)
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.disabled)) {
                            return cs.onSurface.withValues(alpha: 0.38);
                          }
                          return Colors.white; // 활성 시 흰 텍스트
                        }),
                      ),
                      child: const Text('임시저장'),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // -----------------------
                  // 던지기 버튼 (FilledButton)
                  // - 활성: primary 배경 + onPrimary(흰) 텍스트
                  // - 비활성: 회색 배경(0.12) + 회색 텍스트(0.38)
                  // -----------------------
                  Expanded(
                    child: FilledButton(
                      onPressed: isValid ? onSubmit : null,
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(
                          const Size.fromHeight(56),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(semibold),
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.disabled)) {
                            return cs.onSurface.withValues(alpha: 0.12);
                          }
                          return cs.primary;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.disabled)) {
                            return cs.onSurface.withValues(alpha: 0.38);
                          }
                          return cs.onPrimary; // 활성 시 흰 텍스트
                        }),
                      ),
                      child: const Text('던지기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
