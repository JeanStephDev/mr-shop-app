import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../cart/cart_screen.dart';
import '../orders/order_history_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Coquille de navigation principale (bottom nav), affichée une fois connecté.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    CartScreen(),
    OrderHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.orange.withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.orange), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag, color: AppColors.orange), label: 'Panier'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long, color: AppColors.orange), label: 'Commandes'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.orange), label: 'Profil'),
        ],
      ),
    );
  }
}
