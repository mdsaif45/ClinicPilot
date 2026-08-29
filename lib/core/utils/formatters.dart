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
  static final DateFormat _ddMmYyyyFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dbDateFormat = DateFormat('yyyyMMdd');

  // Format currency amount with INR symbol ₹
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  // Format date as 20 May 2026
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  // Format date as DD/MM/YYYY (e.g. 23/08/2026)
  static String formatDdMmYyyy(DateTime? date) {
    if (date == null) return '';
    return _ddMmYyyyFormat.format(date);
  }

  // Format month and year as May 2026
  static String formatMonthYear(DateTime? date) {
    if (date == null) return '';
    return _monthYearFormat.format(date);
  }

  /// Formats a DateTime as YYYYMMDD for database storage (e.g. 20260823)
  static String toDbDate(DateTime? date) {
    if (date == null) return '';
    return _dbDateFormat.format(date);
  }

  /// Converts any date string (DD/MM/YYYY, YYYY-MM-DD, ISO, or YYYYMMDD) into standard database YYYYMMDD string.
  static String toDbDateString(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    final parsed = parseDateString(trimmed);
    if (parsed != null) {
      return _dbDateFormat.format(parsed);
    }
    final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 8) {
      return digits;
    }
    return trimmed;
  }

  /// Converts a database date string (YYYYMMDD or ISO) into human display format (DD/MM/YYYY).
  static String displayFromDbDate(String? dbDate) {
    if (dbDate == null || dbDate.trim().isEmpty) return '';
    final trimmed = dbDate.trim();
    final parsed = parseDateString(trimmed);
    if (parsed != null) {
      return _ddMmYyyyFormat.format(parsed);
    }
    return trimmed;
  }

  /// Parses date from various standard formats: DD/MM/YYYY, YYYYMMDD, YYYY-MM-DD, ISO.
  static DateTime? parseDateString(String? text) {
    if (text == null) return null;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    // 1. DD/MM/YYYY or DD-MM-YYYY
    final slashRegex = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$');
    final match = slashRegex.firstMatch(trimmed);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      final year = int.tryParse(match.group(3)!);
      if (day != null &&
          month != null &&
          year != null &&
          day >= 1 &&
          day <= 31 &&
          month >= 1 &&
          month <= 12 &&
          year >= 1900 &&
          year <= 2100) {
        try {
          return DateTime(year, month, day);
        } catch (_) {}
      }
    }

    // 2. YYYYMMDD (8 digits)
    if (RegExp(r'^\d{8}$').hasMatch(trimmed)) {
      final year = int.tryParse(trimmed.substring(0, 4));
      final month = int.tryParse(trimmed.substring(4, 6));
      final day = int.tryParse(trimmed.substring(6, 8));
      if (year != null &&
          month != null &&
          day != null &&
          month >= 1 &&
          month <= 12 &&
          day >= 1 &&
          day <= 31) {
        try {
          return DateTime(year, month, day);
        } catch (_) {}
      }
    }

    // 3. Standard ISO8601 (e.g. 2026-08-23 or 2026-08-23T...)
    return DateTime.tryParse(trimmed);
  }

  /// Time-of-day greeting.
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
