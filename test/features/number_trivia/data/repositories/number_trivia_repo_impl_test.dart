import 'package:clean_architecture_tutorial/core/platform/network_info.dart';
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

class MockLocalDataSource extends Mock implements NumberTriviaLocalDatasource {}

// @GenerateMocks([NumberTriviaRemoteDatasource])
@GenerateMocks([NetworkInfo])
@GenerateMocks([
  NumberTriviaRemoteDatasource
], customMocks: [
  MockSpec<NumberTriviaRemoteDatasource>(
      as: #MockNumberTriviaRemoteDataSourceForTest),
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

  // void runTestsOnline(Function body) {
  //   group('device is online', () {
  //     setUp(() {
  //       when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
  //     });

  //     body();
  //   });
  // }

  // void runTestsOffline(Function body) {
  //   group('device is online', () {
  //     setUp(() {
  //       when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
  //     });

  //     body();
  //   });
  // }

  // group('getConcreteNumberTrivia', () {
  //   final tNumber = 1; // test number
  //   final tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: tNumber);
  //   final NumberTrivia tNumberTrivia = tNumberTriviaModel;
  //   test('should check if the device is online', () async {
  //     //arange
  //     when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
  //     //act
  //     repository.getConcreteNumberTrivia(tNumber);
  //     //assert
  //     verify(mockNetworkInfo.isConnected);
  //   });

  //   runTestsOnline(() {
  //     test('should return remote data when the call to remote data source is successful', () async {
  //       //arrange
  //       when(mockRemoteDatasource.getConcreteNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
  //       //act
  //       final result = await repository.getConcreteNumberTrivia(tNumber);
  //       //assert
  //       verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
  //       verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
  //     });
  //   });
  // });
  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check if the device is online',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        // act
        repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockNetworkInfo
            .isConnected); // verify that the getter has been called
      },
    );

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
          'should Return remote data when the call to remote data source succeeded',
          () async {
        // arrange
        when(mockRemoteDatasource.getConcreteNumberTrivia(any)).thenAnswer(
            (realInvocation) async =>
                tNumberTriviaModel); // that is what should be returned from the remote data source
        // act
        final result = await repository.getConcreteNumberTrivia(
            tNumber); //* needs await because getConcreteNumberTrivia returns Future
        // assert
        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should cache the data locally when the call to remote data source succeeded',
          () async {
        // arrange
        when(mockRemoteDatasource.getConcreteNumberTrivia(any)).thenAnswer(
            (realInvocation) async =>
                tNumberTriviaModel); // that is what should be returned from the remote data source
        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
    });
  });
}
