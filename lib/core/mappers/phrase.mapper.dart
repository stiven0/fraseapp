import 'package:fraseapp/core/core.dart';

class PhraseMapper { 

  static jsonToEntity( Map<String, dynamic> json ) => PhraseEntitie(
    phrase: json['phrase'],
    author: json['author'],
    image: json['image'],
    date: json['date']
  );

}