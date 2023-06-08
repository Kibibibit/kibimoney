abstract class Formatters {

  static String formatMoney(double amount) {
    int s = amount.sign.round();
    double a = amount.abs();
    int f = a.floor();
    int d = ((a - f) * 100).round();

    String cent = d.abs().toString().padLeft(2, "0");

    return "${f*s}.$cent";
  }

  static const List<String> _weekdays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun"
  ];

  static String formatDate(DateTime? date, [String nullValue = ""]) {
    if (date == null) {
      return nullValue;
    }
    String weekday = _weekdays[date.weekday - 1];
    return "$weekday, ${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
  }
}
