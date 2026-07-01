/// Clinical / plot time: when the measurement happened on device or at manual entry.
String effectiveRecordedAt(Map<String, dynamic> record) {
  final deviceTs = record['deviceRecordedTimestamp'];
  if (deviceTs != null && deviceTs.toString().isNotEmpty) {
    return deviceTs.toString();
  }
  return record['createdAt']?.toString() ?? '';
}

DateTime parseRecordedAt(String recordedAt) {
  if (recordedAt.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.parse(recordedAt);
}

int compareRecordedAt(String a, String b) =>
    parseRecordedAt(a).compareTo(parseRecordedAt(b));
