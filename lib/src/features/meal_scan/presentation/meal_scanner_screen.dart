import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';
import 'package:friendly_meals/src/core/theme/app_radius.dart';
import 'package:friendly_meals/src/core/theme/app_shadows.dart';
import 'package:friendly_meals/src/core/theme/app_spacing.dart';
import 'package:friendly_meals/src/core/widgets/page_heading.dart';
import 'package:image_picker/image_picker.dart';

class MealScannerScreen extends StatefulWidget {
  const MealScannerScreen({super.key});

  @override
  State<MealScannerScreen> createState() => _MealScannerScreenState();
}

class _MealScannerScreenState extends State<MealScannerScreen> {
  XFile? _image;
  bool _loading = false;

  Future<void> _scan() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null || !mounted) return;
    setState(() {
      _image = image;
      _loading = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        PageHeading(
          eyebrow: 'Visuelle Ernährung',
          title: 'Mahlzeit scannen',
          action: FilledButton.icon(
            onPressed: _scan,
            style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Kamera'),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: const Color(0x0D000000)),
                boxShadow: AppShadows.card,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: _image == null
                        ? const ColoredBox(
                            color: Color(0xFFE5E7EB),
                            child: Center(
                              child: Text('Noch kein Bild aufgenommen'),
                            ),
                          )
                        : Image.file(File(_image!.path), fit: BoxFit.cover),
                  ),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: AppSpacing.md),
                          Text('Mahlzeit wird analysiert …'),
                        ],
                      ),
                    )
                  else if (_image != null)
                    const _NutritionResults(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NutritionResults extends StatelessWidget {
  const _NutritionResults();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nährwerte', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        const Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _NutritionCard(label: 'Eiweiß', value: '24 g'),
            _NutritionCard(label: 'Fett', value: '18 g'),
            _NutritionCard(label: 'Kohlenhydrate', value: '52 g'),
            _NutritionCard(label: 'Zucker', value: '8 g'),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Erkannte Zutaten',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        const Wrap(
          spacing: AppSpacing.sm,
          children: [
            Chip(label: Text('Gemüse')),
            Chip(label: Text('Getreide')),
            Chip(label: Text('Eiweißquelle')),
          ],
        ),
      ],
    ),
  );
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
