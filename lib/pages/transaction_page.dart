import 'package:flutter/material.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/pages/abstract_page.dart';
import 'package:kibimoney/pages/edit_transaction_page.dart';
import 'package:kibimoney/utils/formatters.dart';
import 'package:kibimoney/widgets/app_scaffold.dart';
import 'package:kibimoney/widgets/dialogs/confirm_dialog.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';
import 'package:kibimoney/widgets/transaction_widget.dart';

class TransactionPage extends StatefulWidget implements AbstractPage {
  final bool canEdit;
  final TagModel? tag;
  final DateTime? from;

  @override
  IconData get icon => Icons.attach_money;

  @override
  String get title => "Transactions";

  const TransactionPage({super.key, this.canEdit = true, this.tag, this.from});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int transactionCount = 0;
  bool loading = true;
  double money = 0.0;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    int count = await TransactionModel.countWithTag(widget.tag, from: widget.from);
    if (widget.tag != null) {
      double m = await TransactionModel.sumOfTagDedit(widget.tag!, "date > ?", [widget.from!.toIso8601String()]);
      setState(() {
        money = m;
      });
    }
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
    bool doDelete = await showDialog(
            context: context,
            builder: (context) => const ConfirmDialog(
                bodyText:
                    "Are you sure you want to delete this transaction?")) ??
        false;

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
    return AppScaffold(
      title: widget.tag != null
          ? "${widget.tag!.name} - \$${Formatters.formatMoney(money)} "
          : widget.title,
      icon: widget.tag != null ? Icons.label : widget.icon,
      actions: [
        IconButton(
          onPressed: () {
            if (widget.canEdit) {
              editTransaction();
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: widget.canEdit
              ? const Icon(Icons.payments)
              : const Icon(Icons.close),
        )
      ],
      body: loading
          ? LoadingSpinner.centered()
          : ListView.builder(
              itemCount: transactionCount,
              itemBuilder: (context, index) => TransactionWidget(
                transactionId:
                    TransactionModel.getNthIdWithTag(widget.tag, index, from: widget.from),
                onTap: widget.canEdit ? editTransaction : null,
                onDelete: widget.canEdit ? deleteTransaction : null,
              ),
            ),
    );
  }
}
