import 'package:dio/dio.dart';

import 'package:fraseapp/config/config.dart';

class Images {

  final dio = Dio(BaseOptions(
    baseUrl: Environments.urlApiImages
  ));  

  Future<String> getRandomImage() async {

    try {
      // Picsum caches /{size}; a changing query forces a new redirect each call.
      final cacheBuster = DateTime.now().microsecondsSinceEpoch;
      final response = await dio.get(
        '/700',
        queryParameters: {'random': cacheBuster},
      );
      final image = response.realUri.toString();
      return image;
      
    } catch (e) {
      return 'assets/images/default_image.jpg';
    }

  }

}
