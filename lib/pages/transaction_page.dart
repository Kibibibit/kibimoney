import 'package:flutter/material.dart';
import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/pages/edit_transaction_page.dart';
import 'package:kibimoney/widgets/app_scaffold.dart';
import 'package:kibimoney/widgets/dialogs/confirm_dialog.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';
import 'package:kibimoney/widgets/transaction_widget.dart';

class TransactionPage extends StatefulWidget implements AbstractPage {
  @override
  IconData get icon => Icons.attach_money;

  @override
  String get title => "Transactions";

  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int transactionCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    int count = await DatabaseUtils.countTable(TransactionModel.tableName);
    setState(() {
      transactionCount = count;
      loading = false;
    });
  }

  Future<void> editTransaction([TransactionModel? transactionModel]) async {
    TransactionModel? newModel =
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditTransactionPage(
                  transactionModel: transactionModel,
                )));
    if (newModel == null) {
      return;
    }

    if (transactionModel != null) {
      newModel.id = transactionModel.id;
    }
    setState(() {
      loading = true;
    });
    await newModel.save();
    loadTransactions();

    
  }

  Future<void> deleteTransaction(TransactionModel model) async {

    bool doDelete = await showDialog(context: context, builder: (context) => const ConfirmDialog(bodyText: "Are you sure you want to delete this transaction?")) ?? false;

    if (doDelete) {
      setState(() {
        loading = true;
      });
      await model.delete();
      loadTransactions();
    }

  }

  @override
  Widget build(BuildContext context) {
    DatabaseUtils.getNthItemId(TransactionModel.tableName, 0, "date DESC, id DESC");
    return AppScaffold(
      title: widget.title,
      icon: widget.icon,
      actions: [
        IconButton(
            onPressed: () {
              editTransaction();
            },
            icon: const Icon(Icons.payments))
      ],
      body: loading
          ? LoadingSpinner.centered()
          : ListView.builder(
              itemCount: transactionCount,
              itemBuilder: (context, index) =>
                  TransactionWidget(transactionId: TransactionModel.getNthId(index), onTap: editTransaction, onDelete: deleteTransaction,)),
    );
  }
}
