import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_table_model.dart';
import 'package:qiot_admin/utils/convertToCustomFormat.dart';

class InhalerReportTable extends StatefulWidget {
  final List<InhalerReportTableModel> inhalerReportTableData;
  final int salbutomalDosage;
  const InhalerReportTable({
    super.key,
    required this.inhalerReportTableData,
    required this.salbutomalDosage,
    
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

    String convertToCustomFormat(String dateTime) {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd/MM/yyyy hh:mm a').format(parsedDate);
    }
    // Define column widths
    final double inhalerObservedOnWidth =
        screenSize.width * 0.2; // Adjust as needed
    final double inhalerHighWidth = screenSize.width * 0.2; // Adjust as needed
    final double inhalerLowWidth = screenSize.width * 0.2; // Adjust as needed
    final double inhalerValueWidth = screenSize.width * 0.2; // Adjust as needed
    final double dailyVariationWidth =
        screenSize.width * 0.2; // Adjust as needed

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 2 * screenRatio, // Adjust as per your design
          columns: [
            DataColumn(
              label: SizedBox(
                width: inhalerObservedOnWidth, // Set width
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
                width: inhalerHighWidth, // Set width
                child: Text(
                  'Salbutamol Dosage',
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
                width: inhalerValueWidth, // Set width
                child: Text(
                  'Compression',
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

            // print('the value isssssssssssssssssssss');
            // print(data.inhalerValue);
            double  sal_dosage = double.parse(data.inhalerValue.toString()) * widget.salbutomalDosage;
            print(widget.salbutomalDosage);
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: inhalerObservedOnWidth, // Set width
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
                  width: inhalerHighWidth, // Set width
                  child: Text(
                    sal_dosage.toString(),
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
                  width: inhalerValueWidth, // Set width
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
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
