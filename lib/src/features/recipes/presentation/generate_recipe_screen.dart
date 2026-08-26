import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';
import 'package:friendly_meals/src/core/theme/app_radius.dart';
import 'package:friendly_meals/src/core/theme/app_shadows.dart';
import 'package:friendly_meals/src/core/theme/app_spacing.dart';
import 'package:friendly_meals/src/core/widgets/page_heading.dart';
import 'package:friendly_meals/src/features/recipes/application/friendly_meals_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class GenerateRecipeScreen extends ConsumerStatefulWidget {
  const GenerateRecipeScreen({super.key});

  @override
  ConsumerState<GenerateRecipeScreen> createState() =>
      _GenerateRecipeScreenState();
}

class _GenerateRecipeScreenState extends ConsumerState<GenerateRecipeScreen> {
  final _ingredientsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ingredientsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null || !mounted) return;
    setState(() => _loading = true);
    final ingredients =
        await ref.read(recipeServiceProvider).detectIngredients();
    if (!mounted) return;
    _ingredientsController.text = ingredients;
    setState(() => _loading = false);
  }

  Future<void> _generate() async {
    if (_ingredientsController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final recipe = await ref.read(recipeServiceProvider).generate(
      _ingredientsController.text,
      _notesController.text,
    );
    await ref
        .read(friendlyMealsControllerProvider.notifier)
        .saveRecipe(recipe);
    if (!mounted) return;
    context.go('/recipes/${recipe.id}');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const PageHeading(
          eyebrow: 'KI-Rezeptstudio',
          title: 'Neues Rezept',
          description:
              'Verwandle vorhandene Zutaten in ein vollständiges Gericht.',
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: const Color(0x0D000000)),
            boxShadow: AppShadows.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final form = _FormFields(
                ingredientsController: _ingredientsController,
                notesController: _notesController,
                loading: _loading,
              );
              final camera = _CameraPanel(onPressed: _takePicture);
              return Column(
                children: [
                  if (wide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: form),
                          SizedBox(width: 280, child: camera),
                        ],
                      ),
                    )
                  else ...[form, camera],
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    color: const Color(0xFFF9FAFB),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Das Rezept wird lokal auf deinem Gerät gespeichert.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _loading ? null : _generate,
                          icon: _loading
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _loading ? 'Wird erstellt …' : 'Rezept erstellen',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FormFields extends StatelessWidget {
  const _FormFields({
    required this.ingredientsController,
    required this.notesController,
    required this.loading,
  });

  final TextEditingController ingredientsController;
  final TextEditingController notesController;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liste deine Zutaten auf',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const Key('ingredientsField'),
            controller: ingredientsController,
            minLines: 4,
            maxLines: 6,
            enabled: !loading,
            decoration: const InputDecoration(
              hintText: 'z. B. Pasta, Tomaten, Knoblauch, Speck, Eier',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Besondere Wünsche oder Küchenrichtung?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: notesController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'z. B. vegetarisch, glutenfrei, italienisch',
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPanel extends StatelessWidget {
  const _CameraPanel({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 34),
                SizedBox(height: AppSpacing.xl),
                Text(
                  'Fotografiere deine Zutaten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Friendly Meals füllt anschließend die Zutatenliste aus.',
                  style: TextStyle(color: Color(0xFF9CA3AF), height: 1.5),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x55FFFFFF)),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Kamera öffnen'),
            ),
          ],
        ),
      ),
    );
  }
}
