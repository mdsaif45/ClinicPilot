import 'package:intl/intl.dart';

// Utility class for formatting currency and dates
class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹ ',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  // Format currency amount with INR symbol ₹
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  // Format date as 20 May 2026
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // Format month and year as May 2026
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }
}
