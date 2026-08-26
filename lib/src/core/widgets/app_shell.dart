import 'package:flutter/material.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';
import 'package:friendly_meals/src/core/theme/app_radius.dart';
import 'package:friendly_meals/src/core/theme/app_spacing.dart';
import 'package:friendly_meals/src/core/widgets/radiant_background.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  static const destinations = [
    _Destination('/generate', 'Erstellen', Icons.auto_awesome_outlined),
    _Destination('/recipes', 'Rezepte', Icons.menu_book_outlined),
    _Destination('/scan-meal', 'Mahlzeit', Icons.center_focus_strong),
    _Destination('/grocery-list', 'Einkauf', Icons.checklist_outlined),
  ];

  int get selectedIndex {
    if (location.startsWith('/recipes')) return 1;
    if (location.startsWith('/scan-meal')) return 2;
    if (location.startsWith('/grocery-list')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return RadiantBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: desktop ? _desktopHeader(context) : _mobileHeader(context),
            body: Row(
              children: [
                if (desktop)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                    ),
                    child: NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) =>
                          context.go(destinations[index].path),
                      backgroundColor: Colors.white.withValues(alpha: 0.88),
                      indicatorColor: AppColors.ink,
                      selectedIconTheme:
                          const IconThemeData(color: Colors.white),
                      selectedLabelTextStyle: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedIconTheme:
                          const IconThemeData(color: AppColors.muted),
                      labelType: NavigationRailLabelType.all,
                      groupAlignment: -0.72,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                  ),
                Expanded(child: child),
              ],
            ),
            bottomNavigationBar: desktop
                ? null
                : SafeArea(
                    minimum: const EdgeInsets.all(AppSpacing.md),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: NavigationBar(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (index) =>
                            context.go(destinations[index].path),
                        backgroundColor: Colors.white.withValues(alpha: 0.96),
                        indicatorColor: AppColors.ink,
                        destinations: [
                          for (final destination in destinations)
                            NavigationDestination(
                              icon: Icon(destination.icon),
                              selectedIcon: Icon(
                                destination.icon,
                                color: Colors.white,
                              ),
                              label: destination.label,
                            ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _mobileHeader(BuildContext context) => AppBar(
    backgroundColor: Colors.white.withValues(alpha: 0.88),
    surfaceTintColor: Colors.transparent,
    titleSpacing: AppSpacing.lg,
    title: const _Brand(),
  );

  PreferredSizeWidget _desktopHeader(BuildContext context) => AppBar(
    backgroundColor: Colors.white.withValues(alpha: 0.88),
    surfaceTintColor: Colors.transparent,
    titleSpacing: AppSpacing.xl,
    title: const _Brand(),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: AppSpacing.xl),
        child: Center(
          child: Text(
            'Koche mit dem, was du hast.',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      ),
    ],
  );
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [AppColors.tealBright, AppColors.indigo],
          ),
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      const SizedBox(width: AppSpacing.md),
      const Text(
        'Friendly Meals',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _Destination {
  const _Destination(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}
