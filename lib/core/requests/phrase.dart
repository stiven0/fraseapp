import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:fraseapp/config/config.dart';

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

      throw Exception(e.message);

    } catch (e) {
      throw Exception();
    }

  }

}