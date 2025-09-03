import 'dart:math' as math;
import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {
  final bool isValid; // [던지기] 활성 여부
  final VoidCallback onSubmit; // [던지기] 콜백
  final VoidCallback? onTempSave; // [임시저장] 콜백(없으면 비활성)
  final bool isEditMode;

  const BottomButtons({
    super.key,
    required this.isValid,
    required this.onSubmit,
    this.onTempSave,
    this.isEditMode = false,
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
                  // ✅ 수정 모드가 아닐 때만 임시저장 버튼 표시
                  // -----------------------
                  if (!isEditMode)
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
                            return cs.onSurface;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.disabled)) {
                              return cs.onSurface.withValues(alpha: 0.38);
                            }
                            return Colors.white;
                          }),
                        ),
                        child: const Text('임시저장'),
                      ),
                    ),
                  // -----------------------
                  // ✅ 수정 모드가 아닐 때만 SizedBox 표시
                  // -----------------------
                  if (!isEditMode) const SizedBox(width: 16),

                  // -----------------------
                  // ✅ [던지기] 버튼 텍스트 동적 변경
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
                          return cs.onPrimary;
                        }),
                      ),
                      // ✅ 텍스트 변경: 수정 모드면 '수정하기', 아니면 '던지기'
                      child: Text(isEditMode ? '수정하기' : '던지기'),
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
