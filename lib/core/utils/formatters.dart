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

  /// Time-of-day greeting.
  ///
  /// The doctor opens this app at the start of an evening clinic, so a fixed
  /// "Good Day" reads as an unfinished placeholder. Boundaries follow common
  /// Indian usage: morning to noon, afternoon to 5pm, evening to 9pm.
  static String greeting(DateTime now) {
    final h = now.hour;
    if (h < 5) return 'Good Night';
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    if (h < 21) return 'Good Evening';
    return 'Good Night';
  }

  /// "20 May 2025, Tuesday"
  static String formatFullDate(DateTime date) {
    return DateFormat('d MMM yyyy, EEEE').format(date);
  }

  /// Normalizes free-text disease/complaint strings: trims whitespace and capitalizes each word.
  static String toTitleCase(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    return trimmed
        .split(RegExp(r'\s+'))
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}

