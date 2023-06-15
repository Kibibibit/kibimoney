import 'package:flutter/material.dart';
import 'package:kibimoney/utils/formatters.dart';

class DatePicker extends StatelessWidget {
  final DateTime? date;
  final Function(DateTime date) onChange;

  const DatePicker({super.key, this.date, required this.onChange});



  Future<void> _onTap(BuildContext context) async {
    DateTime? newDate = await showDatePicker(context: context, initialDate: date ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day), firstDate: DateTime.fromMicrosecondsSinceEpoch(0), lastDate: DateTime.now());
    if (newDate != null) {
      onChange(newDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () {_onTap(context);},
        icon: Icon(
          Icons.date_range,
          color: date == null ? Colors.grey : null,
        ),
        label: Text(Formatters.formatDate(date, "Select Date")));
  }
}
