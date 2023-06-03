import 'package:flutter/material.dart';
import 'package:kibimoney/widgets/dialogs/app_dialog.dart';

class ConfirmDialog extends StatelessWidget {

  final String bodyText;
  const ConfirmDialog({super.key, required this.bodyText});

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: const Text("Are you sure?"),
      body: Text(bodyText),
      actions: [
        TextButton(onPressed: (){Navigator.of(context).pop(true);}, child: const Text("YES")),
        TextButton(onPressed: (){Navigator.of(context).pop(false);}, child: const Text("NO")),
        
      ],
    );
  }

}