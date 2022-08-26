import 'package:clean_architecture_tutorial/core/util/input_converter.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia])
@GenerateMocks([GetRandomNumberTrivia])
@GenerateMocks([InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test('initialState should be Empty', () {
    //assert
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test('should call the InputConverter to validate and convert the string to an unsigned integer', () async {
      //arange
      when(mockInputConverter.stringToUnsignedInteger(tNumberString)).thenReturn(const Right(tNumberParsed));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter
          .stringToUnsignedInteger(tNumberString)); // Bloc uses streams so it take some time to add the event
      //assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid.', () async* {
      //! Important : needs async* in order to pass the test (να το ψάξω περισσότερο)
      //arange
      when(mockInputConverter.stringToUnsignedInteger(tNumberString)).thenReturn(Left(InvalidInputFailure()));

      final expectedStateOrder = [Empty(), Error(message: INVALID_INPUT_FAILURE_MESSAGE)];
      //assert later
      // To eksigei sto telos toy video 11 giati allazei thn seira
      expectLater(bloc, emitsInOrder(expectedStateOrder));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
  });
}
