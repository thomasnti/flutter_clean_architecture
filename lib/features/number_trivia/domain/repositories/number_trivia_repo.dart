// Here we define our contracts
import 'package:dartz/dartz.dart';

import '/core/error/failures.dart';
import '/features/number_trivia/domain/entities/number_trivia.dart';

abstract class NumberTriviaRepo {
  // * Either class comes from dartz package
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}
