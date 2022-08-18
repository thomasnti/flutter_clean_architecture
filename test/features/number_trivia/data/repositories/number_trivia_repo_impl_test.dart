import 'package:clean_architecture_tutorial/core/platform/network_info.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/repositories/number_trivia_repo_impl.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';

import 'number_trivia_repo_impl_test.mocks.dart';

class MockLocalDataSource extends Mock implements NumberTriviaLocalDatasource {}

// @GenerateMocks([NumberTriviaRemoteDatasource])
@GenerateMocks([
  NumberTriviaRemoteDatasource
], customMocks: [
  MockSpec<NumberTriviaRemoteDatasource>(as: #MockNumberTriviaRemoteDataSourceForTest),
])
@GenerateMocks([NetworkInfo])
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
      remoteDatasource: mockRemoteDatasource,
      localDatasource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1; // test number
    final tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the device is online', () async {
      //arange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      //act
      repository.getConcreteNumberTrivia(tNumber);
      //assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test('should return remote data when the call to remote data source is successful', () async {
        //arrange
        when(mockRemoteDatasource.getConcreteNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });
    });
  });
}