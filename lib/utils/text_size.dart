
import 'package:flutter/material.dart';

abstract class TextSize {

  static final Map<String,double> _cache = {};


  static double get(String string, [TextStyle? style]) {

    if (_cache.containsKey(string)) {
      return _cache[string]!;
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text:string, style: style), maxLines: 1, textDirection: TextDirection.ltr
    )..layout(minWidth: 0, maxWidth: double.infinity);

    _cache[string] = textPainter.size.width;

    return get(string, style);

  }


}