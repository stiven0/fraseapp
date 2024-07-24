import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  int getCurrentIndexTab( BuildContext context ) {

    final String location = GoRouterState.of(context).matchedLocation;

    switch (location) {

      case '/':
        return 0;

      case '/favorites':
        return 1;

      default: return 0;

    }
    
  }

  void onItemTap( BuildContext context, int index ) {

    switch( index ) {

      case 0:
        context.go('/');
      break;

      case 1: 
        context.go('/favorites');
      break;

      default: context.go('/');      

    }

  }

  @override
  Widget build(BuildContext context) {

    final colorsTheme = Theme.of(context).colorScheme;

    return NavigationBar(
        elevation: 0,
        selectedIndex: getCurrentIndexTab(context),
        onDestinationSelected: (index) => onItemTap( context, index ),
        destinations: [

          NavigationDestination(
            icon: Icon( Icons.explore_outlined, color: colorsTheme.primary ), 
            label: 'Explorar',
            selectedIcon: Icon( Icons.explore, color: colorsTheme.primary )
          ),

          NavigationDestination(
            icon: Icon( Icons.favorite_border_outlined, color: colorsTheme.primary ), 
            label: 'Favoritos',
            selectedIcon: Icon( Icons.favorite, color: colorsTheme.primary, )
          ),

        ],
    );
  }

}