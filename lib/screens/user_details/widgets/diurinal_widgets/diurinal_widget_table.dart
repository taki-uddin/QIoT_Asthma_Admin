import 'package:flutter/material.dart';
import 'package:qiot_admin/models/diurinal_model.dart/diurinal_table.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_table_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_table_model.dart';
import 'package:qiot_admin/utils/convertToCustomFormat.dart';

class DiurinalReportTable extends StatefulWidget {
  final List<DiurinalTableModel> diurinalReportTableData;
  const DiurinalReportTable({
    super.key,
    required this.diurinalReportTableData,
  });

  @override
  _DiurinalReportTableState createState() => _DiurinalReportTableState();
}

class _DiurinalReportTableState extends State<DiurinalReportTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;

    // Define column widths
    final double diurinalObservedOnWidth =
        screenSize.width * 0.12; // Adjust as needed
    final double diurinalHighWidth =
        screenSize.width * 0.12; // Adjust as needed
    final double diurinalLowWidth = screenSize.width * 0.12; // Adjust as needed
    final double diurinalValueWidth =
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
              label: Container(
                child: SizedBox(
                  width: diurinalObservedOnWidth, // Set width
                  child: Text(
                    'diurinal Observed On',
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
            ),
            DataColumn(
              label: SizedBox(
                width: diurinalHighWidth, // Set width
                child: Text(
                  'Diurinal High',
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
                width: diurinalLowWidth, // Set width
                child: Text(
                  'Diurinal Low',
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
                width: diurinalValueWidth, // Set width
                child: Text(
                  'Daily Mean Value',
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
          rows: widget.diurinalReportTableData.reversed.toList().map((data) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: diurinalObservedOnWidth, // Set width
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
                  width: diurinalHighWidth, // Set width
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
                  width: diurinalLowWidth, // Set width
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
                  width: diurinalValueWidth, // Set width
                  child: Text(
                    data.dailyMean.toString(),
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
                      color: data.dailyVariation! >= 80
                          ? const Color(0xFF27AE60)
                          : data.dailyVariation! < 80 &&
                                  data.dailyVariation! >= 60
                              ? const Color(0xFFFF8500)
                              : data.dailyVariation! < 60 &&
                                      data.dailyVariation! >= 50
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

