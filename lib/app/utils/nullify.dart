class Nullify {
  static final List<dynamic> _trueValues = ['true', true, '1', 1];

  static DateTime? parseDate(value) {
    return value != null ? (value is DateTime ? value : DateTime.parse(value).toLocal()) : null;
  }

  static double? parseDouble(value) {
    if (value == '') return null;
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    return double.parse(value);
  }

  static bool? parseBool(value) {
    return value != null ? (_trueValues.contains(value) ? true : false) : null;
  }
}
