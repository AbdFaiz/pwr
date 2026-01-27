import 'package:flutter/material.dart';
import 'dashboard_content.dart';
import './invoice_history_screen.dart';
import './rewards_screen.dart';
import './profile_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardContent(),
    const InvoiceHistoryScreen(),
    const RewardsScreen(),
    const ProfileScreen(),
  ];

  // Public method untuk switch tab
  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(theme),
      floatingActionButton: _currentIndex == 1 ? _buildUploadFAB() : null,
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.grid_24_regular, size: 22),
          activeIcon: Icon(FluentIcons.grid_24_filled, size: 22),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.receipt_24_regular, size: 22),
          activeIcon: Icon(FluentIcons.receipt_24_filled, size: 22),
          label: 'Invoice',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.gift_24_regular, size: 22),
          activeIcon: Icon(FluentIcons.gift_24_filled, size: 22),
          label: 'Rewards',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.person_24_regular, size: 22),
          activeIcon: Icon(FluentIcons.person_24_filled, size: 22),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildUploadFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/upload_invoice');
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
