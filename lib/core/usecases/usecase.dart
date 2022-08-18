import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

// Type is the class of the use case
abstract class Usecase<Type, Params> {
  Future<Either<Failure, Type>?> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
