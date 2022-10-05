import 'dart:convert';

import 'package:clean_architecture_tutorial/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(text: 'Test trivia', number: 1);

  test('should be a subclass of NumberTrivia entity', () {
    //assert
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJSON', () {
    test('should return a valid model when the JSON number (property) is an integer', () {
      //arange
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));
      //act
      final result = NumberTriviaModel.fromJson(jsonMap);
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should return a valid model when the JSON number is regarded as a double', () {
      //arange
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia_double.json'));
      //act
      final result = NumberTriviaModel.fromJson(jsonMap);
      //assert
      expect(result, equals(tNumberTriviaModel));
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      //act
      final result = tNumberTriviaModel.toJson();
      //assert
      final expectedMap = {'text': 'Test trivia', 'number': 1};
      expect(result, equals(expectedMap));
    });
  });
}
