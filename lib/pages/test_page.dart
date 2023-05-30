import 'package:flutter/material.dart';
import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/models/transaction_model.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late TextEditingController _controller;

  Future<void> onSave() async {
    TagModel tag = TagModel(_controller.text);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Page"),
      ),
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
