String convertToCustomFormat(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  String formattedDate =
      '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year} ${_formatTime(dateTime)}';
  return formattedDate;
}

String _getMonthName(int month) {
  List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return monthNames[month - 1];
}

String _formatTime(DateTime dateTime) {
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');
  String second = dateTime.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}
