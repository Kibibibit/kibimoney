import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  static Widget centered() {
    return const Center(child:LoadingSpinner());
  }

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }

}