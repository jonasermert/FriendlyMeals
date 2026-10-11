import 'package:flutter/material.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';
import 'package:friendly_meals/src/features/recipes/presentation/recipe_filter_screen.dart';

/// Keeps filter actions anchored while the form scrolls and the sheet resizes.
Future<void> showRecipeFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    constraints: const BoxConstraints(maxWidth: 760),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 1,
        snap: true,
        snapSizes: const [0.5, 0.7, 1],
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: SizedBox(
                width: 40,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RecipeFilterScreen(
                scrollController: scrollController,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
