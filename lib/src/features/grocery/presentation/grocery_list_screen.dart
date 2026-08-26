import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';
import 'package:friendly_meals/src/core/theme/app_radius.dart';
import 'package:friendly_meals/src/core/theme/app_shadows.dart';
import 'package:friendly_meals/src/core/theme/app_spacing.dart';
import 'package:friendly_meals/src/core/widgets/empty_state.dart';
import 'package:friendly_meals/src/core/widgets/page_heading.dart';
import 'package:friendly_meals/src/features/grocery/domain/grocery_item.dart';
import 'package:friendly_meals/src/features/recipes/application/friendly_meals_controller.dart';

class GroceryListScreen extends ConsumerStatefulWidget {
  const GroceryListScreen({super.key});

  @override
  ConsumerState<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends ConsumerState<GroceryListScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    await ref.read(friendlyMealsControllerProvider.notifier).addGrocery(value);
    _controller.clear();
  }

  Future<void> _showStoreFinder() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _StoreFinderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendlyMealsControllerProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Center(
        child: Text('Die Einkaufsliste konnte nicht geladen werden.'),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          PageHeading(
            eyebrow: 'Einkaufsbegleiter',
            title: 'Einkaufsliste',
            action: OutlinedButton.icon(
              onPressed: _showStoreFinder,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Händler finden'),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('groceryField'),
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(),
                  decoration: const InputDecoration(
                    hintText: 'Zutat hinzufügen …',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.filled(
                key: const Key('addGroceryButton'),
                tooltip: 'Hinzufügen',
                onPressed: _add,
                style: IconButton.styleFrom(
                  minimumSize: const Size(54, 54),
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (data.groceries.isEmpty)
            const EmptyState(
              title: 'Deine Einkaufsliste ist leer',
              message:
                  'Füge oben eine Zutat hinzu oder übernimm Zutaten aus einem Rezept.',
            )
          else
            for (final item in data.groceries) ...[
              _GroceryCard(item: item),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}

class _GroceryCard extends ConsumerWidget {
  const _GroceryCard({required this.item});

  final GroceryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(color: const Color(0x0D000000)),
      boxShadow: AppShadows.card,
    ),
    child: ListTile(
      onTap: () => ref
          .read(friendlyMealsControllerProvider.notifier)
          .toggleGrocery(item.id),
      leading: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.checked ? AppColors.teal : AppColors.tealSoft,
        ),
        child: item.checked
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
      title: Text(
        item.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: item.checked ? AppColors.muted : AppColors.ink,
          decoration: item.checked ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        tooltip: '${item.name} löschen',
        onPressed: () => ref
            .read(friendlyMealsControllerProvider.notifier)
            .deleteGrocery(item.id),
        icon: const Icon(Icons.close),
      ),
    ),
  );
}

class _StoreFinderSheet extends StatelessWidget {
  const _StoreFinderSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ZUTATEN-ZU-HÄNDLER-SUCHE',
              style: TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Händler in der Nähe finden',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Finde Geschäfte in deiner Nähe, die deine Zutaten anbieten.',
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Standort wird ermittelt …',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text('Nächste Händler werden gesucht …'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Keine passenden Händler in der Nähe gefunden.',
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }
}
