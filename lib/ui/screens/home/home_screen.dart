import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('FraseAPP', style: TextStyle( color: Colors.white )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon( (isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined), color: Colors.white, ),
            onPressed: (){
              ref.read( themeNotifierProvider.notifier ).toggleDarkMode();
            }, 
          )
        ],
        backgroundColor: isDarkMode ? colorsTheme.surface : colorsTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(child: childView),
      bottomNavigationBar: const CustomBottomNavigation(),
      drawer: const SideMenu()
    );
  }
}