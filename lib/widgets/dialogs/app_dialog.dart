import 'package:flutter/material.dart';

class AppDialog<T> extends StatelessWidget {

  final Widget? title;
  final Widget? body;
  final List<Widget> actions;

  const AppDialog({super.key, this.title, this.body, this.actions = const []});

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DefaultTextStyle(style:  DialogTheme.of(context).titleTextStyle ?? theme.textTheme.titleLarge! , child: title ?? Container()),
          ),
          body??Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
          )
        ],
      ),

    );
  }




}