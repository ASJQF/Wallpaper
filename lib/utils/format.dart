import 'package:intl/intl.dart';

String formatCount(int value, String locale) {
  if (value < 1000) return '$value';
  return NumberFormat.compact(locale: locale).format(value);
}
