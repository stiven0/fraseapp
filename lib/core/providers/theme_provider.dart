import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fraseapp/config/config.dart';
import 'package:fraseapp/core/core.dart';

final darkModeProvider = StateProvider<bool>((ref) => false);

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  
  final bool darkMode = ref.watch( darkModeProvider );
  return ThemeNotifier( darkMode );

}); 

class ThemeNotifier extends StateNotifier<AppTheme> {

  final StorageService storageService = StorageService();
  final bool defaultDarkModeValue;

  // STATE - ESTADO = nueva instancia de AppTheme()
  ThemeNotifier( this.defaultDarkModeValue ): super( AppTheme( isDarkMode: defaultDarkModeValue ) );

  void toggleDarkMode() async {

    state = state.copyWith( isDarkMode: !state.isDarkMode );
    storageService.setModeDarkOrClear( state.isDarkMode ? 'dark' : 'clear' );

  }

}