import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fraseapp/core/core.dart';

enum TypeOrder {
  defect,
  date
}

final isPhraseFavoriteProvider = FutureProvider.autoDispose.family<bool, String>((ref, String phrase) async {

  final favoritesProvider = ref.watch( favoritesPhrasesProvider.notifier );
  return favoritesProvider.isPhraseFavorite(phrase);

});

final typeOrderPhraseProvider = StateProvider<TypeOrder>((ref) => TypeOrder.defect);

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
    if ( toDelay ) await Future.delayed(const Duration(milliseconds: 1800));
    final phrases = await storageService.getPhrasesFavorites();
    state = phrases;
    return phrases;
  }

  Future<bool> isPhraseFavorite( String phrase ) async {
    return await storageService.isPhraseFavorite( phrase );
  }

  Future<String> getTimeToRequestNotification() async {
    return await storageService.getTimeToRequestNotification();
  }

  Future<bool> setOrDeleteWaitingTimeToRequestNotification( RequestNotification action ) async {
    return await storageService.setOrDeleteWaitingTimeToRequestNotification( action );
  }

}