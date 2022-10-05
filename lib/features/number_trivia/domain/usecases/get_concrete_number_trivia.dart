import 'package:dartz/dartz.dart';

import 'package:clean_architecture_tutorial/core/error/failures.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/domain/repositories/number_trivia_repo.dart';
import 'package:equatable/equatable.dart';
import '../entities/number_trivia.dart';
import 'package:clean_architecture_tutorial/core/usecases/usecase.dart';

class GetConcreteNumberTrivia implements Usecase<NumberTrivia, Params> {
  final NumberTriviaRepo repository;

  GetConcreteNumberTrivia(this.repository);
  // Callable Class (https://www.javatpoint.com/dart-callable-classes)
  @override
  Future<Either<Failure, NumberTrivia>?> call(Params params) async {
    return await repository.getConcreteNumberTrivia(params.number);
  }
}

class Params extends Equatable {
  final int number;

  const Params({required this.number});

  @override
  List<Object?> get props => [number];
}
