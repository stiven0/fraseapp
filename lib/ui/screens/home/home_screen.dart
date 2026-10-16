import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:fraseapp/ui/ui.dart';
import 'package:fraseapp/core/core.dart';

class HomeScreen extends ConsumerWidget {

  final Widget childView;

  const HomeScreen({
    super.key, 
    required this.childView
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final colorsTheme = Theme.of(context).colorScheme;
    final bool isDarkMode = ref.watch( themeNotifierProvider ).isDarkMode;
    final InAppReview inAppReview = InAppReview.instance;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Calificar app',
            onPressed: () => inAppReview.openStoreListing(), 
            icon: const Icon(Icons.star_border_outlined)
          )
        ),
        title: Text(
          'FraseAPP',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
            icon: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: Colors.white,
            ),
            onPressed: (){
              ref.read( themeNotifierProvider.notifier ).toggleDarkMode();
            }, 
          )
        ],
        backgroundColor: isDarkMode ? colorsTheme.surface : colorsTheme.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(child: childView),
      bottomNavigationBar: const CustomBottomNavigation()
      // drawer: const SideMenu()
    );
  }
}
