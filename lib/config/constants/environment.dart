import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environments {

  static initEnvironment() async {
    await dotenv.load(fileName: ".env");
  }

  static String urlApiPhrase = dotenv.env['URL_API_PRHASE'] ?? 'null';
  static String urlApiImages = dotenv.env['URL_API_IMAGES'] ?? 'null';
  static String urlWikipedia = 'https://es.wikipedia.org/wiki';

}