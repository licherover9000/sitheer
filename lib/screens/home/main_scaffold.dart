import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/providers/main_nav_provider.dart';
import 'package:sitheer/screens/prep/ask_tayari_screen.dart';
import 'package:sitheer/screens/prep/mock_tests_screen.dart';
import 'package:sitheer/screens/prep/progress_screen.dart';
import 'package:sitheer/screens/prep/roadmap_screen.dart';
import 'package:sitheer/screens/prep/planner_screen.dart';
import 'package:sitheer/screens/prep/vault_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  static Widget _screenForIndex(int index) {
    return switch (index) {
      0 => const AskTayariScreen(),
      1 => const RoadmapScreen(),
      2 => const VaultScreen(),
      3 => const MockTestsScreen(),
      4 => const ProgressScreen(),
      5 => const PlannerScreen(),
      _ => const AskTayariScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<MainNavProvider>();
    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.auto_awesome_outlined),
        selectedIcon: Icon(Icons.auto_awesome),
        label: 'Ask',
      ),
      NavigationDestination(
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map),
        label: 'Roadmap',
      ),
      NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: 'Vault',
      ),
      NavigationDestination(
        icon: Icon(Icons.timer_outlined),
        selectedIcon: Icon(Icons.timer),
        label: 'Mocks',
      ),
      NavigationDestination(
        icon: Icon(Icons.trending_up_outlined),
        selectedIcon: Icon(Icons.trending_up),
        label: 'Progress',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Planner',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 980) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: nav.currentIndex,
                  onDestinationSelected: (i) =>
                      context.read<MainNavProvider>().setIndex(i),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: _BrandMark(),
                  ),
                  destinations: destinations
                      .map(
                        (destination) => NavigationRailDestination(
                          icon: destination.icon,
                          selectedIcon: destination.selectedIcon,
                          label: Text(destination.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _screenForIndex(nav.currentIndex)),
              ],
            ),
          );
        }

        return Scaffold(
          body: _screenForIndex(nav.currentIndex),
          bottomNavigationBar: NavigationBar(
            selectedIndex: nav.currentIndex,
            onDestinationSelected: (i) =>
                context.read<MainNavProvider>().setIndex(i),
            destinations: destinations,
          ),
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'myTayari',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
