// ignore_for_file: constant_identifier_names

import 'package:bloc/bloc.dart';
import 'package:clean_architecture_tutorial/core/error/failures.dart';
import 'package:clean_architecture_tutorial/core/usecases/usecase.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/presentation/widgets/trivia_controls.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  // Bloc dependencies
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaState get initialState => Empty();

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>(((event, emit) async {
      final inputConverterEither = inputConverter.stringToUnsignedInteger(event.numberString);

      await inputConverterEither.fold((failure) async => emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE)),
          (integer) async {
        emit(Loading());
        final failureOrTrivia = await getConcreteNumberTrivia(Params(number: integer));

        await failureOrTrivia!.fold(
          (failure) async => emit(Error(message: _mapFailureToMessage(failure))),
          (trivia) async => emit(Loaded(trivia: trivia)),
        );
      });
    }));

    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(Loading());

      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      failureOrTrivia!.fold(
        (failure) => emit(Error(message: _mapFailureToMessage(failure))),
        (trivia) => emit(Loaded(trivia: trivia)),
      );
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error !!';
    }
  }
}
