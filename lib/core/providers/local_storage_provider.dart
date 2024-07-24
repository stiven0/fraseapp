import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fraseapp/core/core.dart';

final isPhraseFavoriteProvider = FutureProvider.autoDispose.family<bool, String>((ref, String phrase) async {

  final favoritesProvider = ref.watch( favoritesPhrasesProvider.notifier );
  return favoritesProvider.isPhraseFavorite(phrase);

});

final favoritesPhrasesProvider = StateNotifierProvider<LocalStoragePhrasesNotifier, List<dynamic>>((ref) {

  final storageService = StorageService();
  return LocalStoragePhrasesNotifier( storageService: storageService );

});

class LocalStoragePhrasesNotifier extends StateNotifier<List<dynamic>> {

  final StorageService storageService;

  LocalStoragePhrasesNotifier({
    required this.storageService
  }): super([]);

  Future<void> tooglePhraseFavorite( PhraseEntitie phrase ) async {
    await storageService.tooglePhraseFavorite( phrase );
  }

  Future<List<dynamic>> getPhrasesFavorites({ bool toDelay = true }) async {
    if ( toDelay ) await Future.delayed(const Duration(seconds: 2));
    final phrases = await storageService.getPhrasesFavorites();
    state = phrases;
    return phrases;
  }

  Future<bool> isPhraseFavorite( String phrase ) async {
    return await storageService.isPhraseFavorite( phrase );
  }

}