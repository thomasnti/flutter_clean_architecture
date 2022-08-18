import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/platform/network_info.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/repositories/number_trivia_repo.dart';
import '../datasources/number_trivia_local_datasource.dart';
import '../datasources/number_trivia_remote_datasource.dart';

class NumberTriviaRepoImpl implements NumberTriviaRepo {
  final NumberTriviaRemoteDatasource remoteDatasource;
  final NumberTriviaLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  NumberTriviaRepoImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number) async {
    // TODO: implement getConcreteNumberTrivia
    networkInfo.isConnected;
    return Right(await remoteDatasource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() {
    // TODO: implement getRandomNumberTrivia
    throw UnimplementedError();
  }
}
