extension DateTimeExtension on DateTime {
  DateTime adjust({int hours = 1, int minutes = 0}) {
    return add(Duration(hours: hours, minutes: minutes));
  }
}
