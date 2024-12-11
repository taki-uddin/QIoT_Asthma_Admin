class InhalerReportTableModel {
  final String createdAt;
  final int inhalerValue;
  final int highValue;
  final int lowValue;
  final double averageValue;
  final double dailyVariation;

  InhalerReportTableModel(
    this.createdAt,
    this.inhalerValue,
    this.highValue,
    this.lowValue,
    this.averageValue,
    this.dailyVariation,
  );
}
