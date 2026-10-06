import 'package:flutter/material.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

import 'screens.dart';

void main() => runApp(const TripamiGalleryApp());

class TripamiGalleryApp extends StatelessWidget {
  const TripamiGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripami',
      debugShowCheckedModeBanner: false,
      theme: TripamiTheme.light(),
      darkTheme: TripamiTheme.dark(),
      home: const GalleryShell(),
    );
  }
}

class GalleryShell extends StatefulWidget {
  const GalleryShell({super.key});

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  int _index = 0;

  static const _items = [
    TPTabItem(label: 'Trips', icon: TPIcons.suitcase, activeIcon: TPIconsFill.suitcase),
    TPTabItem(label: 'Trip', icon: TPIcons.house, activeIcon: TPIconsFill.house),
    TPTabItem(
      label: 'Plan',
      icon: TPIcons.calendarBlank,
      activeIcon: TPIconsFill.calendarBlank,
      hasActivity: true,
    ),
    TPTabItem(label: 'System', icon: TPIcons.notebook, activeIcon: TPIconsFill.notebook),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [TripsScreen(), TripHomeScreen(), PlanScreen(), FoundationsScreen()],
      ),
      bottomNavigationBar: TPTabBar(
        items: _items,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
