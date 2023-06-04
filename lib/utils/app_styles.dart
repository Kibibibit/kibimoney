import 'package:flutter/material.dart';
import 'package:kibimoney/utils/text_size.dart';

abstract class AppStyles {
  
 
  static AppPaddings paddings = AppPaddings();
  static AppColors colors = AppColors();
  static AppSizes sizes = AppSizes();



}

class AppSizes {
  final double moneyWidth = TextSize.get("+\$99,999.99")+4.0;
}

class AppPaddings {
  final EdgeInsetsGeometry titlePadding = const EdgeInsets.only(left:5.0);
  final EdgeInsetsGeometry amountPadding = const EdgeInsets.all(4.0);

}


class AppColors {

  final Color debitColor = Colors.red;
  final Color creditColor = Colors.green;

}