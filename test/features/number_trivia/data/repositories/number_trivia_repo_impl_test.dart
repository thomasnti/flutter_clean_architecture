import 'package:clean_architecture_tutorial/core/error/exceptions.dart';
import 'package:clean_architecture_tutorial/core/error/failures.dart';
import 'package:clean_architecture_tutorial/core/network/network_info.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/repositories/number_trivia_repo_impl.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';

import 'number_trivia_repo_impl_test.mocks.dart';

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

// @GenerateMocks([NumberTriviaRemoteDatasource])
@GenerateMocks([NetworkInfo])
@GenerateMocks([
  NumberTriviaRemoteDatasource
], customMocks: [
  MockSpec<NumberTriviaRemoteDatasource>(as: #MockNumberTriviaRemoteDataSourceForTest),
])
void main() {
  late MockNumberTriviaRemoteDatasource mockRemoteDatasource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late NumberTriviaRepoImpl repository;

  setUp(() {
    mockRemoteDatasource = MockNumberTriviaRemoteDatasource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepoImpl(
      remoteDataSource: mockRemoteDatasource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body(); //* We call the body function
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body(); //* We call the body function
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check if the device is online',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        // act
        repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockNetworkInfo.isConnected); // verify that the getter has been called
      },
    );

    runTestsOnline(() {
      test('should Return remote data when the call to remote data source succeeded', () async {
        // arrange
        when(mockRemoteDatasource.getConcreteNumberTrivia(any)).thenAnswer((realInvocation) async =>
            tNumberTriviaModel); // that is what should be returned from the remote data source
        // act
        final result = await repository
            .getConcreteNumberTrivia(tNumber); //* needs await because getConcreteNumberTrivia returns Future
        // assert
        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should cache the data locally when the call to remote data source succeeded', () async {
        // arrange
        when(mockRemoteDatasource.getConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => tNumberTriviaModel);
        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test('should return server failure when the call to remote data source is unsuccessful', () async {
        // arrange
        when(mockRemoteDatasource.getConcreteNumberTrivia(any)).thenThrow(ServerException());
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      //* When the device is offline we want to return the cached data

      test('should return last locally cached data, when we have the cached data', () async {
        //arange
        when(mockLocalDataSource.getLastNumberTrivia()).thenAnswer((realInvocation) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDatasource); //* den kaleitai tipota apo to Remote (API)
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return CacheFailure, when there is no cached data present', () async {
        //arange
        when(mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDatasource); //* den kaleitai tipota apo to Remote (API)
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    final randomNumber = 2324;
    final tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: randomNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check if the device is online',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        // act
        repository.getRandomNumberTrivia();
        // assert
        verify(mockNetworkInfo.isConnected); // verify that the getter has been called
      },
    );

    runTestsOnline(() {
      test('should Return remote data when the call to remote data source succeeded', () async {
        // arrange
        when(mockRemoteDatasource.getRandomNumberTrivia()).thenAnswer((realInvocation) async =>
            tNumberTriviaModel); // that is what should be returned from the remote data source
        // act
        final result =
            await repository.getRandomNumberTrivia(); //* needs await because getRandomNumberTrivia returns Future
        // assert
        verify(mockRemoteDatasource.getRandomNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should cache the data locally when the call to remote data source succeeded', () async {
        // arrange
        when(mockRemoteDatasource.getRandomNumberTrivia()).thenAnswer((realInvocation) async => tNumberTriviaModel);
        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(mockRemoteDatasource.getRandomNumberTrivia());
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test('should return server failure when the call to remote data source is unsuccessful', () async {
        // arrange
        when(mockRemoteDatasource.getRandomNumberTrivia()).thenThrow(ServerException());
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verify(mockRemoteDatasource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      //* When the device is offline we want to return the cached data

      test('should return last locally cached data, when we have the cached data', () async {
        //arange
        when(mockLocalDataSource.getLastNumberTrivia()).thenAnswer((realInvocation) async => tNumberTriviaModel);
        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verifyZeroInteractions(mockRemoteDatasource); //* den kaleitai tipota apo to Remote (API)
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return CacheFailure, when there is no cached data present', () async {
        //arange
        when(mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verifyZeroInteractions(mockRemoteDatasource); //* den kaleitai tipota apo to Remote (API)
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
