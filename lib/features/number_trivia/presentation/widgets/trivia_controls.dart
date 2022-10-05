// import 'dart:js';

// ignore_for_file: depend_on_referenced_packages

import '../bloc/number_trivia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final textController = TextEditingController();
  String? userInput;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: ((value) {
            userInput = value;
          }),
          onSubmitted: (_) {
            // To send the request and from the keyboard's checkmark
            addConcrete();
          },
        ),
        const SizedBox(height: 15),
        Row(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: addConcrete,
                child: const Text('Search'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange.shade400),
                ),
                onPressed: addRandom,
                child: const Text('Get Random Trivia'),
              ),
            ),
          ],
        )
      ],
    );
  }

  void addConcrete() {
    textController.clear();
    context.read<NumberTriviaBloc>().add(GetTriviaForConcreteNumber(userInput ?? ''));
  }

  void addRandom() {
    context.read<NumberTriviaBloc>().add(GetTriviaForRandomNumber());
  }
}
