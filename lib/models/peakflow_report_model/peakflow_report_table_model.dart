class PeakflowReportTableModel {
  final String createdAt;
  final int peakflowValue;
  final int highValue;
  final int lowValue;
  final double averageValue;
  final double dailyVariation;

  PeakflowReportTableModel(
    this.createdAt,
    this.peakflowValue,
    this.highValue,
    this.lowValue,
    this.averageValue,
    this.dailyVariation,
  );
}
