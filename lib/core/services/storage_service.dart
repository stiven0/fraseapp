import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fraseapp/core/core.dart';

class StorageService {

  Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<String> getModeDarkOrClear() async {

    final prefs = await getSharedPrefs();
    return prefs.getString('mode') as String;
  
  }

  Future<bool> setModeDarkOrClear(String mode) async {

    final prefs = await getSharedPrefs();
    return prefs.setString('mode', mode);

  }

  /// Get favorites
  Future<List<dynamic>> getPhrasesFavorites() async {

    final prefs = await getSharedPrefs();
    final favorites = prefs.getString('favorites');
    if ( favorites != null ) {
      return json.decode(favorites);
    }
    return [];

  }

  /// Save o remove favorite phrase
  Future<void> tooglePhraseFavorite( PhraseEntitie phrase ) async {

    final prefs = await getSharedPrefs();
    final favorites = prefs.getString('favorites');

    if ( favorites != null ) {

      final List<dynamic> listFavorites = json.decode(favorites);
      if ( listFavorites.isNotEmpty ) {

        final existPhrase = listFavorites.any( (element) => element['phrase'].toString().trim() == phrase.phrase.trim() );
        if ( !existPhrase ) {

          listFavorites.add( phrase.toJson() );
          final dataToSave = json.encode( listFavorites );
          prefs.setString('favorites', dataToSave);
          return;

        } else {

          final dataToSave = listFavorites
                                          .where( (element) => element['phrase'].toString().trim() != phrase.phrase.trim() )
                                          .toList();       
          prefs.setString('favorites', json.encode(dataToSave));
          return;

        }

      }

    } 
    
    final dataToSave = json.encode([ phrase.toJson() ]);
    prefs.setString('favorites', dataToSave);
    return;

  }

  Future<bool> isPhraseFavorite( String phrase ) async {

    final prefs = await getSharedPrefs();
    final favorites = prefs.getString('favorites');

    if ( favorites != null ) {

      final List<dynamic> listFavorites = json.decode(favorites);
      return listFavorites.any( (element) => element['phrase'].toString().trim() == phrase.trim() );

    }

    return false;

  }

}