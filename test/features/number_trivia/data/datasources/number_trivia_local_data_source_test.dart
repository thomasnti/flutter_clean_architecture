import 'dart:convert';

import 'package:clean_architecture_tutorial/core/error/exceptions.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

// @GenerateMocks([SharedPreferences])
@GenerateMocks([
  SharedPreferences
], customMocks: [
  // ignore: deprecated_member_use
  MockSpec<SharedPreferences>(as: #MockSharedPreferencesForTest, returnNullOnMissingStub: true),
])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia_cache.json')));
    test('should return NumberTrivia from SharedPreferences when there is one in the cache', () async {
      //! ThenReturn because getString returns a string
      when(mockSharedPreferences.getString(any)).thenReturn(fixture('trivia_cache.json'));

      final result = await dataSource.getLastNumberTrivia();

      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, tNumberTriviaModel);
    });

    test('should throw a CacheException when there is not a cached value', () {
      //arange
      when(mockSharedPreferences.getString(any))
          .thenReturn(null); // when there is no cached data shared preferences returns null
      //act
      final call = dataSource.getLastNumberTrivia; // Function
      //assert
      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(text: 'Test trivia', number: 1);
    test('should call SharedPreferences to cache the data ', () async {
      //arrange
      when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);
      //act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      //assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}
