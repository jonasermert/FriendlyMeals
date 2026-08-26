import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friendly_meals/src/core/routing/app_router.dart';
import 'package:friendly_meals/src/core/theme/app_theme.dart';

class FriendlyMealsApp extends ConsumerWidget {
  const FriendlyMealsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Friendly Meals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
