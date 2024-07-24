import 'package:dio/dio.dart';

import 'package:fraseapp/config/config.dart';

class Images {

  final dio = Dio(BaseOptions(
    baseUrl: Environments.urlApiImages
  ));  

  Future<String> getRandomImage() async {

    try {

      final response = await dio.get('/700');
      final image = response.realUri.toString();
      return image;

      
    } catch (e) {
      throw Exception();
    }

  }

}