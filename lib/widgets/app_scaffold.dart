import 'package:flutter/material.dart';
import 'package:kibimoney/utils/settings.dart';
import 'package:kibimoney/widgets/app_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? body;
  final List<Widget>? actions;
  const AppScaffold({super.key, required this.title, required this.icon, this.body, this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        actions: actions,
        centerTitle: true,
        title: Row(
          children: [
            Icon(icon),
            Padding(padding: Settings.appSettings.titlePadding),
            Text(title),
          ],
        ),
      ),
      body: body,
    );
  }
}
