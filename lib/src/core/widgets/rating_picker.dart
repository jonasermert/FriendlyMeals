import 'package:flutter/material.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';

class RatingPicker extends StatelessWidget {
  const RatingPicker({
    required this.value,
    required this.onChanged,
    this.compact = false,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        for (var rating = 1; rating <= 5; rating++)
          IconButton(
            tooltip: '$rating Sterne',
            onPressed: () => onChanged(rating),
            style: compact
                ? IconButton.styleFrom(
                    backgroundColor: rating <= value
                        ? const Color(0xFFFFFBEB)
                        : Colors.transparent,
                    side: BorderSide(
                      color: rating <= value
                          ? const Color(0xFFFDE68A)
                          : AppColors.line,
                    ),
                  )
                : null,
            icon: Icon(
              rating <= value ? Icons.star_rounded : Icons.star_border_rounded,
              color: rating <= value ? AppColors.amber : AppColors.line,
              size: compact ? 24 : 34,
            ),
          ),
      ],
    );
  }
}
