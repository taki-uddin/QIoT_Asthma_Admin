import 'package:flutter/material.dart';
import 'package:qiot_admin/models/steroid_dose_model/steroid_dose_table.dart';
import 'package:qiot_admin/utils/convertToCustomFormat.dart';

class SteroidReportTable extends StatefulWidget {
  final List<SteroidDoseTableModel>
      steroidReportTableData;
  const SteroidReportTable(
      {Key? key, required this.steroidReportTableData})
      : super(key: key);

  @override
  _SteroidtReportTableState createState() =>
      _SteroidtReportTableState();
}

class _SteroidtReportTableState
    extends State<SteroidReportTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;

    // Define column widths
    final double steoridObservedOnWidth =
        screenSize.width * 0.3; // Adjust as needed
    final double steroidValueWidth =
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
                width: steoridObservedOnWidth, // Set width
                child: Text(
                  'Steroid Dosage Observed On',
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
                width: steroidValueWidth, // Set width
                child: Text(
                  'Steroid Dosage Value',
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
          rows: widget.steroidReportTableData.reversed
              .toList()
              .map((data) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: steoridObservedOnWidth,
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
                  width: steroidValueWidth,
                  child: Text(
                    data.steroiddoseValue.toString(),
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
