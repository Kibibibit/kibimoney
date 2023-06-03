import 'package:flutter/material.dart';

abstract class AbstractPage extends Widget {
  const AbstractPage({super.key});


  String get title;
  IconData get icon;


}