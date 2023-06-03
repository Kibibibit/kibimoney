import 'package:flutter/material.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/widgets/app_scaffold.dart';

class HomePage extends StatelessWidget implements AbstractPage{

  const HomePage({super.key});

  @override
  IconData get icon => Icons.home;
  
  @override
  String get title => "Home";
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: title, icon: icon);
  }
  
  


  
}