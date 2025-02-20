import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_table_model.dart';
import 'package:qiot_admin/utils/convertToCustomFormat.dart';

class AsthmaControlTestReportTable extends StatefulWidget {
  final List<AsthmaControlTestReportTableModel>
      asthmacontroltestReportTableData;
  const AsthmaControlTestReportTable(
      {Key? key, required this.asthmacontroltestReportTableData})
      : super(key: key);

  @override
  _AsthmaControlTestReportTableState createState() =>
      _AsthmaControlTestReportTableState();
}

class _AsthmaControlTestReportTableState
    extends State<AsthmaControlTestReportTable> {
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
    final double asthmacontroltestObservedOnWidth =
        screenSize.width * 0.3; // Adjust as needed
    final double asthmacontroltestValueWidth =
        screenSize.width * 0.3; // Adjust as needed

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 2 * screenRatio, // Adjust as per your design
          columns: [
            DataColumn(
              label: SizedBox(
                width: asthmacontroltestObservedOnWidth, // Set width
                child: Text(
                  'ACT Observed On',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: asthmacontroltestValueWidth, // Set width
                child: Text(
                  'ACT Value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
          rows: widget.asthmacontroltestReportTableData.reversed
              .toList()
              .map((data) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: asthmacontroltestObservedOnWidth,
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
                  width: asthmacontroltestValueWidth,
                  child: Text(
                    data.asthmacontroltestValue.toString(),
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
