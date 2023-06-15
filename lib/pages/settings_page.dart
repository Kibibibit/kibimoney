import 'package:flutter/material.dart';
import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/db/sheet_utils.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/widgets/app_scaffold.dart';
import 'package:kibimoney/widgets/dialogs/confirm_dialog.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';

class SettingsPage extends StatefulWidget implements AbstractPage {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  @override
  IconData get icon => Icons.settings;

  @override
  String get title => "Settings";
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> onWipe() async {
    bool delete = await showDialog(
        context: context,
        builder: (context) => const ConfirmDialog(
            bodyText:
                "Are you sure you want to wipe your data? This cannot be undone")) ?? false;
    if (delete) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              DatabaseUtils.wipeData()
                  .then((value) => Navigator.of(context).pop());
              return Dialog(
                child: LoadingSpinner.centered(),
              );
            });
      }
    }
  }

  Future<void> onImport() async {
    showDialog(
        context: context,
        builder: (context) {
          SheetUtils.getTags().then((value) => SheetUtils.getTransactions()
              .then((value) => DatabaseUtils.getTotal()
                  .then((value) => Navigator.of(context).pop())));
          return Dialog(
            child: LoadingSpinner.centered(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      icon: widget.icon,
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                onWipe();
              },
              child: const Text("Wipe data")),
          SheetUtils.hasEnv
              ? TextButton(
                  onPressed: () {
                    onImport();
                  },
                  child: const Text("Import data"))
              : Container(),
        ],
      ),
    );
  }
}
