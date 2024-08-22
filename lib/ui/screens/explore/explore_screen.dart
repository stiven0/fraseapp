import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:fraseapp/config/config.dart';
import 'package:fraseapp/core/core.dart';
import 'package:fraseapp/shared/shared.dart';
import 'package:fraseapp/ui/ui.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends ConsumerState<ExploreScreen> {

  PhraseEntitie? phrase;
  bool isLoading = false;
  Errors error = Errors.none;

  /// application quick actions are initialized
  initializeQuickActions() {  
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'action_favorites') context.go('/favorites');
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(type: 'action_favorites', localizedTitle: 'favoritos', icon: 'app_icon' ),
    ]);
  }

  getImageAndPhraseInitial() async {

    try {

      isLoading = true;
      final phraseData = await Phrase().getPhraseOfDay();
      final image = await Images().getRandomImage();
      final Map<String, dynamic> phraseToJson = {
        'phrase': phraseData['phrase'],
        'author': phraseData['author'],
        'image': image
      };
      phrase = PhraseMapper.jsonToEntity(phraseToJson);
      isLoading = false;
      setState(() {});
      
    } on CustomError catch (e) {

      isLoading = false;
      error = e.message;
      setState(() {});

    } catch (e) {

      isLoading = false;
      error = Errors.serverError;
      setState(() {});

    }
  }

  /// view notifications in snackbar
  void showSnackbarNotification( String messsage, BuildContext context ) {

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messsage),
        duration: const Duration(seconds: 2),
      )
    );

  }

  /// reload data every time it is invoked
  void reloadData({delayed = true}) async {

    isLoading = true;
    setState(() {});
    if ( delayed ) await Future.delayed(const Duration(seconds: 2));
    getImageAndPhraseInitial();
    error = Errors.none;
    
  }

  @override
  void initState() {
    super.initState();
    initializeQuickActions();
    getImageAndPhraseInitial();
    LocalNotifications.scheduleDailyNotification();
  }

  @override
  Widget build(BuildContext context) {

    final colorsTheme = Theme.of(context).colorScheme;
    final bool isDarkMode = ref.watch( themeNotifierProvider ).isDarkMode;
    final size = MediaQuery.of(context).size;

    return isLoading 
    ? Center(
        child:  CircularProgressIndicator(
          strokeWidth: 2, 
          color: isDarkMode ? colorsTheme.surface : colorsTheme.primary
        )
      )
    : error == Errors.none 
    ? Scaffold(
      body: PhraseScreen(favorite: phrase!),
      floatingActionButton: FloatingActionButton(
        onPressed: () => reloadData(delayed: false),
        backgroundColor: colorsTheme.primary,
        child: Icon( Icons.refresh_outlined, color: isDarkMode ? Colors.black : Colors.white ),
      ),
    ) 
    : Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon( Icons.error_outline, size: 70, color: colorsTheme.primary ),
          const SizedBox(height: 20),
          SizedBox(
            width: size.width * 0.9,
            child: Text(
              'Ha ocurrido un error, verifica tu conexión e inténtalo nuevamente', 
              style: TextStyle(fontSize: 20, color: isDarkMode ? colorsTheme.surface : Colors.black45),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => reloadData(), 
            icon: const Icon( Icons.restart_alt_outlined ), 
            label: const Text('Intentar'),
            iconAlignment: IconAlignment.start,
            style: ButtonStyle( 
              backgroundColor: WidgetStateProperty.all( isDarkMode ? Colors.black87 : colorsTheme.primary ),
              foregroundColor:  WidgetStateProperty.all( isDarkMode ? Colors.white : Colors.white ), 
            ),
          )
        ],
      ),
    );
  }

}