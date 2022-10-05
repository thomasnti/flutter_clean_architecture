import 'package:clean_architecture_tutorial/features/number_trivia/domain/entities/number_trivia.dart';

//* The model class should extend the entity class
class NumberTriviaModel extends NumberTrivia {
  const NumberTriviaModel({required String text, required int number}) : super(text: text, number: number);

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) {
    return NumberTriviaModel(
      text: json['text'],
      number: (json['number'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'number': number};
  }
}
