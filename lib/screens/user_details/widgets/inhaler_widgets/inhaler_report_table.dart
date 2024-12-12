import 'package:flutter/material.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_table_model.dart';
import 'package:qiot_admin/utils/convertToCustomFormat.dart';

class InhalerReportTable extends StatefulWidget {
  final List<InhalerReportTableModel> inhalerReportTableData;
  const InhalerReportTable({
    super.key,
    required this.inhalerReportTableData,
  });

  @override
  _InhalerReportTableState createState() => _InhalerReportTableState();
}

class _InhalerReportTableState extends State<InhalerReportTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;

    // Define column widths
    final double peakflowObservedOnWidth =
        screenSize.width * 0.12; // Adjust as needed
    final double peakflowHighWidth =
        screenSize.width * 0.12; // Adjust as needed
    final double peakflowLowWidth = screenSize.width * 0.12; // Adjust as needed
    final double peakflowValueWidth =
        screenSize.width * 0.12; // Adjust as needed
    final double dailyVariationWidth =
        screenSize.width * 0.12; // Adjust as needed

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 2 * screenRatio, // Adjust as per your design
          columns: [
            DataColumn(
              label: SizedBox(
                width: peakflowObservedOnWidth, // Set width
                child: Text(
                  'Inhaler Observed On',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: peakflowHighWidth, // Set width
                child: Text(
                  'Inhaler High',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                     fontSize: 14,
                      fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: peakflowLowWidth, // Set width
                child: Text(
                  'Inhaler Low',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: peakflowValueWidth, // Set width
                child: Text(
                  'Inhaler Value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                     fontSize: 14,
                      fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: dailyVariationWidth, // Set width
                child: Text(
                  'Daily Variation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
          rows: widget.inhalerReportTableData.reversed.toList().map((data) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: peakflowObservedOnWidth, // Set width
                  child: Text(
                    convertToCustomFormat(data.createdAt.toString()),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: peakflowHighWidth, // Set width
                  child: Text(
                    data.highValue.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: peakflowLowWidth, // Set width
                  child: Text(
                    data.lowValue.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: peakflowValueWidth, // Set width
                  child: Text(
                    data.inhalerValue.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: dailyVariationWidth, // Set width
                  child: Text(
                    data.dailyVariation.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: data.dailyVariation >= 80
                          ? const Color(0xFF27AE60)
                          : data.dailyVariation < 80 &&
                                  data.dailyVariation >= 60
                              ? const Color(0xFFFF8500)
                              : data.dailyVariation < 60 &&
                                      data.dailyVariation >= 50
                                  ? const Color(0xFFFD4646)
                                  : const Color(0xFFD10000),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
