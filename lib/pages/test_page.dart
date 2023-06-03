import 'package:flutter/material.dart';
import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/widgets/app_scaffold.dart';

class TestPage extends StatefulWidget implements AbstractPage {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
  
  @override
  IconData get icon => Icons.bug_report;
  
  @override
  String get title => "Test Page";
}

class _TestPageState extends State<TestPage> {
  late TextEditingController _controller;

  Future<void> onSave() async {
    TagModel tag = TagModel(_controller.text, Colors.red);

    await tag.save();

    TransactionModel transactionModel = TransactionModel(DateTime.now(), 35, TransactionModel.typeDebit, "Hi", [tag]);

    transactionModel.save();

    _controller.clear();

  }

  Future<void> onLoad() async {

    print(await TransactionModel.get());

  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      icon: widget.icon,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                    child: TextField(
                  controller: _controller,
                )),
                TextButton(onPressed: () => {onSave()}, child: const Text("SAVE"))
              ],
            ),
            TextButton(onPressed: ()=>{DatabaseUtils.wipeData()}, child: const Text("WIPE")),
            TextButton(onPressed: ()=>(onLoad()), child: const Text("LOAD"))
          ],
        ),
      ),
    );
  }
}