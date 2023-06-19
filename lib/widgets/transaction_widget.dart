import 'package:flutter/material.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/utils/app_styles.dart';
import 'package:kibimoney/utils/formatters.dart';
import 'package:kibimoney/widgets/loading_spinner.dart';

class TransactionWidget extends StatefulWidget {
  final Future<int> transactionId;
  final Widget? trailing;
  final void Function(TransactionModel)? onDelete;
  final void Function(TransactionModel)? onTap;
  const TransactionWidget(
      {super.key,
      required this.transactionId,
      this.trailing,
      this.onDelete,
      this.onTap});

  @override
  State<TransactionWidget> createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  late TransactionModel transactionModel;
  late int transactionId;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    loadTransaction();
  }

  Future<void> loadTransaction() async {
    
    int newTransactionId = await widget.transactionId;
    setState(() {
      transactionId = newTransactionId;
    });
    TransactionModel? model =
        await TransactionModel.getById(newTransactionId);
    if (mounted) {
      if (model != null) {
        setState(() {
          transactionModel = model;
          loading = false;
        });
      } else {
        setState(() {
          error = true;
        });
      }
    }
  }

  Widget leading(TransactionModel model) {
    Color color = AppStyles.colors.debitColor;
    String leadString = "-";
    if (model.transactionType == TransactionModel.typeCredit) {
      color = AppStyles.colors.creditColor;
      leadString = "+";
    }

    String string = "$leadString\$${Formatters.formatMoney(model.amount)}";

    return Container(
      width: AppStyles.sizes.moneyWidth,
      padding: AppStyles.paddings.amountPadding,
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Text(
        string,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? ListTile(
            title: LoadingSpinner.centered(),
          )
        : ListTile(
            title: error
                ? Text("Could not get transaction ${widget.transactionId}!")
                : Text(transactionModel.name),
            leading: leading(transactionModel),
            subtitle: Text(Formatters.formatDate(transactionModel.date)),
            trailing: widget.trailing ??
                (widget.onDelete != null
                    ? IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          if (!loading && !error && widget.onDelete != null) {
                            widget.onDelete!(transactionModel);
                          }
                        },
                      )
                    : null),
            onTap: () {
              if (!loading && !error && widget.onTap != null) {
                widget.onTap!(transactionModel);
              }
            },
          );
  }
}
