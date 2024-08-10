import 'package:dio/dio.dart';

import 'package:fraseapp/config/config.dart';
import 'package:fraseapp/shared/shared.dart';

class Images {

  final dio = Dio(BaseOptions(
    baseUrl: Environments.urlApiImages
  ));  

  Future<String> getRandomImage() async {

    try {

      final response = await dio.get('/700');
      final image = response.realUri.toString();
      return image;

      
    } on DioException catch (e) {

      if ( e.type == DioExceptionType.connectionTimeout ) {
        throw CustomError(Errors.failedConnection);
      }

      throw CustomError(Errors.serverError);
      
    } catch (e) {
      throw CustomError(Errors.serverError);
      
    }

  }

}