extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime dateTime) {
    if (this.year == dateTime.year && this.month == dateTime.month && this.day == dateTime.day) {
      return true;
    }
    return false;
  }

  DateTime toSimpleDateTime() {
    return DateTime(this.year, this.month, this.day);
  }

  String toSimpleString() {
    return "${this.year}-${this.month.toString().padLeft(2, '0')}-${this.day.toString().padLeft(2, '0')}";
  }
}
