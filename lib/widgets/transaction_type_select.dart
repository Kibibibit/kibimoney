import 'package:flutter/material.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/utils/app_styles.dart';

class TransactionTypeSelect extends StatelessWidget {
  final String? value;
  final Function(String) onChange;

  const TransactionTypeSelect({super.key, this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TypeChip(label: TransactionModel.typeCredit, value: value, onChange: onChange, color: AppStyles.colors.creditColor,),
        _TypeChip(label: TransactionModel.typeDebit, value: value, onChange: onChange, color: AppStyles.colors.debitColor,)
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String? value;
  final Function(String) onChange;
  final Color color;

  const _TypeChip(
      {required this.label, this.value, required this.onChange, required this.color});

  @override
  Widget build(BuildContext context) {
    bool selected = label==value;
    Color fontColor = selected ? Colors.white : Colors.grey;
    return InputChip(
      label: Text(label, style: TextStyle(color: fontColor),),
      onPressed: (){onChange(label);},
      selected: selected,
      selectedColor: color,
      checkmarkColor: fontColor,
    );
  }
}
