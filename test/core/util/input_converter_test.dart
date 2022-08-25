import 'package:clean_architecture_tutorial/core/util/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInteger', () {
    test('should return an integer when the string represents an unsigned integer', () {
      //arange
      const str = '1234';
      //act
      final result = inputConverter.stringToUnsignedInteger(str);
      //assert
      expect(result, equals(const Right(1234)));
    });

    test('should return a Failure when the string is not an integer', () {
      //arange
      const str = 'abc';
      //act
      final result = inputConverter.stringToUnsignedInteger(str);
      //assert
      expect(result, equals(Left(InvalidInputFailure())));
    });

    test('should return a Failure when the string is a negative integer', () {
      //arange
      const str = '-123';
      //act
      final result = inputConverter.stringToUnsignedInteger(str);
      //assert
      expect(result, equals(Left(InvalidInputFailure())));
    });
  });
}
