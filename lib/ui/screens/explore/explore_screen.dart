import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fraseapp/config/config.dart';
import 'package:fraseapp/core/core.dart';
import '../../ui.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends ConsumerState<ExploreScreen> {

  PhraseEntitie? phrase;
  bool isLoading = false;

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
      
    } catch (e) {

      //TODO: HANDLE ERROR

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

  @override
  void initState() {
    super.initState();
    getImageAndPhraseInitial();
    LocalNotifications.scheduleDailyNotification();
  }

  @override
  Widget build(BuildContext context) {

    return isLoading 
    ? const Center(
        child:  CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)
      )
    : PhraseScreen(favorite: phrase!);
  }

}
