import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:clean_architecture_tutorial/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tutorial/features/number_trivia/domain/repositories/number_trivia_repo.dart';

import 'get_concrete_number_trivia_test.mocks.dart';

// class MockNumberTriviaRepository extends Mock implements NumberTriviaRepo {}
@GenerateMocks([NumberTriviaRepo])
void main() {
  late MockNumberTriviaRepo mockNumberTriviaRepository;
  late GetConcreteNumberTrivia usecase;
  late int tNumber;
  late NumberTrivia tNumberTrivia;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepo();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
    tNumberTrivia = NumberTrivia(number: 1, text: 'test');
    tNumber = 1;
  });

  test('should get trivia for the number from the repository', () async {
    when(mockNumberTriviaRepository.getConcreteNumberTrivia(any)).thenAnswer((_) async => Right(tNumberTrivia));

    // runs the call function of the usecase
    final result = await usecase(Params(number: tNumber));

    expect(result, Right(tNumberTrivia));
    verify(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber));
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
