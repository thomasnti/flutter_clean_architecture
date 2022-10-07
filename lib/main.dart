import 'package:flutter/material.dart';

import 'features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'injection_container.dart' as di; // dependency injection

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Dependency injection setup
  await di.setup();

  // FlutterError.onError = (details) {
  //   FlutterError.presentError(details);
  //   if (kDebugMode) exit(1);
  // };

  runApp(const NumberTriviaApp());
}

class NumberTriviaApp extends StatelessWidget {
  const NumberTriviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const NumberTriviaPage(),
    );
  }
}
