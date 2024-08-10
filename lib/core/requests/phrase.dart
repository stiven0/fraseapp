import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:fraseapp/config/config.dart';
import 'package:fraseapp/shared/shared.dart';

class Phrase {

  final dio = Dio(BaseOptions(
    baseUrl: Environments.urlApiPhrase
  ));

  Future<Map<String, dynamic>> getPhraseOfDay() async {

    try {

      final response = await dio.get('/phrase');
      final phrase = json.decode(response.data);
      return phrase;

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