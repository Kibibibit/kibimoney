import 'package:flutter/material.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/utils/formatters.dart';
import 'package:kibimoney/widgets/date_picker.dart';
import 'package:kibimoney/widgets/tag_selector.dart';
import 'package:kibimoney/widgets/transaction_type_select.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionModel? transactionModel;

  const EditTransactionPage({super.key, this.transactionModel});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late FocusNode amountFocus;

  late List<int> tags;
  late bool editMode;
  late String name;
  late String transactionType;
  late DateTime date;
  late double amount;

  @override
  void initState() {
    super.initState();
    if (widget.transactionModel != null) {
      editMode = true;
      name = widget.transactionModel!.name;
      transactionType = widget.transactionModel!.transactionType;
      date = widget.transactionModel!.date;
      amount = widget.transactionModel!.amount;
      tags = widget.transactionModel!.tags.map((e) => e.id!).toList();
    } else {
      editMode = false;
      name = "";
      transactionType = TransactionModel.typeDebit;
      date = DateTime.now();
      amount = 0;
      tags = [];
    }
    nameController = TextEditingController(text: name);
    amountController = TextEditingController(text: Formatters.formatMoney(amount));
    amountFocus = FocusNode();
  }

  void setName(String newName) {
    setState(() {
      name = newName;
    });
  }

  void setAmount(String newAmount) {
    if (newAmount.isEmpty) {
      newAmount = Formatters.formatMoney(0);
    }
    setState(() {
      amount = double.parse(newAmount.replaceAll(",", ""));
    });
  }

  void setDate(DateTime newDate) {
    setState(() {
      date = newDate;
    });
  }

  void setTransactionType(String newType) {
    setState(() {
      transactionType = newType;
    });
  }

  void setTags(List<int> newTags) {
    setState(() {
      tags = newTags;
    });
  }

  Future<TransactionModel> onSave() async {
   
    List<TagModel> tagModels = [];
    for (int tagId in tags) {
      TagModel? tagModel = await TagModel.getById(tagId);
      if (tagModel != null) {
        tagModels.add(tagModel);
      }
    }
    String newName = name;
    if (name.isEmpty) {
      newName = "New Transaction";
    }

     return TransactionModel(date, amount, transactionType, newName, tagModels);

      
  }

  @override
  void dispose() {
    super.dispose();
    amountFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editMode
            ? widget.transactionModel!.name
            : "Create new transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DatePicker(date: date, onChange: setDate),
            TextField(
              controller: nameController,
              onChanged: setName,
              decoration:
                  const InputDecoration(label: Text("Transaction Name")),
            ),
            TextField(
              focusNode: amountFocus,
              controller: amountController,
              onChanged: setAmount,
              onTap: () {
                if (amount == 0) {
                  amountController.text = "";
                }
              },
              onSubmitted: (_) {
                amountController.text = Formatters.formatMoney(amount);
              },
              onTapOutside: (_) {
                amountController.text = Formatters.formatMoney(amount);
                amountController.selection = TextSelection(baseOffset: amountController.text.length, extentOffset: amountController.text.length);
                amountFocus.unfocus();
              },
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                label: Text("Amount"),
                icon: Icon(Icons.attach_money)
              ),
            ),
            const Padding(padding: EdgeInsets.all(8.0)),
            const Text("Transaction Type"),
            TransactionTypeSelect(
                onChange: setTransactionType, value: transactionType),
              TagSelector(selected: tags, onChange: setTags,),
            Expanded(child: Center(
              child: TextButton.icon(onPressed: () async {
                Navigator.of(context).pop(await onSave());
              }, label: const Text("SAVE"), icon: const Icon(Icons.save),),
            ))
          ],
        ),
      ),
    );
  }
}
