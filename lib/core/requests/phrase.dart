import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'package:fraseapp/shared/shared.dart';

class Phrase {
  static Map<String, dynamic>? _phrases;

  Future<Map<String, dynamic>> _loadPhrases() async {
    if (_phrases != null) return _phrases!;

    try {
      final raw = await rootBundle.loadString('assets/phrases/phrases.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      _phrases = decoded;
      return decoded;
    } catch (_) {
      throw CustomError(Errors.serverError);
    }
  }

  Map<String, dynamic> _asPhraseMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return {
        'phrase': value['phrase'],
        'author': value['author'],
      };
    }
    throw CustomError(Errors.serverError);
  }

  Future<Map<String, dynamic>> getPhraseOfDay() async {
    try {
      final phrases = await _loadPhrases();
      if (phrases.isEmpty) throw CustomError(Errors.serverError);

      final keys = phrases.keys.toList()
        ..sort((a, b) {
          return (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0);
        });

      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      final key = dayOfYear.toString();

      if (phrases.containsKey(key)) {
        return _asPhraseMap(phrases[key]);
      }

      // Partial dataset: map day-of-year onto available keys.
      final index = (dayOfYear - 1) % keys.length;
      return _asPhraseMap(phrases[keys[index]]);
    } on CustomError {
      rethrow;
    } catch (_) {
      throw CustomError(Errors.serverError);
    }
  }

  Future<Map<String, dynamic>> getRandomPhrase() async {
    try {
      final phrases = await _loadPhrases();
      if (phrases.isEmpty) throw CustomError(Errors.serverError);

      final keys = phrases.keys.toList();
      final key = keys[Random().nextInt(keys.length)];
      return _asPhraseMap(phrases[key]);
    } on CustomError {
      rethrow;
    } catch (_) {
      throw CustomError(Errors.serverError);
    }
  }
}
