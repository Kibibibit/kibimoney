import 'package:flutter/material.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/widgets/app_scaffold.dart';

class TransactionPage extends StatelessWidget implements AbstractPage {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: title, icon: icon);
  }

  @override
  IconData get icon => Icons.attach_money;

  @override
  String get title => "Transactions";

}