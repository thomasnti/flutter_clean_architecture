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
  NumberTriviaRemoteDataSource
], customMocks: [
  MockSpec<NumberTriviaRemoteDataSource>(as: #MockNumberTriviaRemoteDataSourceForTest),
])
void main() {
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late NumberTriviaRepoImpl repository;

  setUp(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepoImpl(
      remoteDataSource: mockRemoteDataSource,
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
    const tNumber = 1;
    const tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: tNumber);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check if the device is online',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getConcreteNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
        // act
        repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockNetworkInfo.isConnected); // verify that the getter has been called
      },
    );

    runTestsOnline(() {
      test('should Return remote data when the call to remote data source succeeded', () async {
        // arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any)).thenAnswer((realInvocation) async =>
            tNumberTriviaModel); // that is what should be returned from the remote data source
        // act
        final result = await repository
            .getConcreteNumberTrivia(tNumber); //* needs await because getConcreteNumberTrivia returns Future
        // assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should cache the data locally when the call to remote data source succeeded', () async {
        // arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => tNumberTriviaModel);
        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test('should return server failure when the call to remote data source is unsuccessful', () async {
        // arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any)).thenThrow(ServerException());
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
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
        verifyZeroInteractions(mockRemoteDataSource); //* den kaleitai tipota apo to Remote (API)
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return CacheFailure, when there is no cached data present', () async {
        //arange
        when(mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource); //* den kaleitai tipota apo to Remote (API)
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    const randomNumber = 2324;
    const tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: randomNumber);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check if the device is online',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        // act
        repository.getRandomNumberTrivia();
        // assert
        verify(mockNetworkInfo.isConnected); // verify that the getter has been called
      },
    );

    runTestsOnline(() {
      test('should Return remote data when the call to remote data source succeeded', () async {
        // arrange
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((realInvocation) async =>
            tNumberTriviaModel); // that is what should be returned from the remote data source
        // act
        final result =
            await repository.getRandomNumberTrivia(); //* needs await because getRandomNumberTrivia returns Future
        // assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should cache the data locally when the call to remote data source succeeded', () async {
        // arrange
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((realInvocation) async => tNumberTriviaModel);
        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test('should return server failure when the call to remote data source is unsuccessful', () async {
        // arrange
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenThrow(ServerException());
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
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
        verifyZeroInteractions(mockRemoteDataSource); //* den kaleitai tipota apo to Remote (API)
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return CacheFailure, when there is no cached data present', () async {
        //arange
        when(mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verifyZeroInteractions(mockRemoteDataSource); //* den kaleitai tipota apo to Remote (API)
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
