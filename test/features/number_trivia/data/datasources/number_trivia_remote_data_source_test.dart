import 'dart:convert';

import 'package:clean_architecture_tutorial/core/error/exceptions.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttpClient;
  late NumberTriviaRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((realInvocation) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((realInvocation) async => http.Response('Something whent wrong !!', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('should preform a GET request on a URL with number being the endpoint and with application/json header', () {
      //arange
      setUpMockHttpClientSuccess();
      //act
      dataSource.getConcreteNumberTrivia(tNumber);
      //assert
      verify(mockHttpClient
          .get(Uri.parse('http://numbersapi.com/$tNumber'), headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response code is 200 (success)', () async {
      //arange
      setUpMockHttpClientSuccess();
      //act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the response code is not 200', () async {
      //arange
      setUpMockHttpClientFailure();
      //act
      final functionCall = dataSource.getConcreteNumberTrivia;
      //assert
      expect(() => functionCall(tNumber),
          throwsA(const TypeMatcher<ServerException>())); //! <ServerException>() NOT <ServerException>
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('should preform a GET request on a URL with *random* endpoint with application/json header', () {
      //arange
      setUpMockHttpClientSuccess();
      //act
      dataSource.getRandomNumberTrivia();
      //assert
      verify(
          mockHttpClient.get(Uri.parse('http://numbersapi.com/random'), headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response code is 200 (success)', () async {
      //arange
      setUpMockHttpClientSuccess();
      //act
      final result = await dataSource.getRandomNumberTrivia();
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the response code is not 200', () async {
      //arange
      setUpMockHttpClientFailure();
      //act
      final functionCall = dataSource.getRandomNumberTrivia;
      //assert
      expect(() => functionCall(),
          throwsA(const TypeMatcher<ServerException>())); //! <ServerException>() NOT <ServerException>
    });
  });
}
