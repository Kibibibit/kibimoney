import 'package:flutter/material.dart';
import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/pages/home_page.dart';
import 'package:kibimoney/pages/test_page.dart';

void main() async {

  await DatabaseUtils.loadDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const TestPage(),
    );
  }
}

