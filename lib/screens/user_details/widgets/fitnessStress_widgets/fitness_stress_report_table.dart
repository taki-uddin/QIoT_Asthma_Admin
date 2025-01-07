import 'package:flutter/material.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_table_model.dart';
import 'package:qiot_admin/models/fitness_stress_report_model/stress_fitness_report_model.dart';
import 'package:qiot_admin/utils/convertToCustomFormat.dart';

class FitnessStressReportTable extends StatefulWidget {
  final List<FitnessStressReportModel>
      fitnessstressReportTableData;
  const FitnessStressReportTable(
      {Key? key, required this.fitnessstressReportTableData})
      : super(key: key);

  @override
  _FitnessStressReportTableState createState() =>
      _FitnessStressReportTableState();
}

class _FitnessStressReportTableState
    extends State<FitnessStressReportTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;

    // Define column widths
    final double asthmacontroltestObservedOnWidth =
        screenSize.width * 0.2; // Adjust as needed
    final double asthmacontroltestValueWidth =
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
                width: asthmacontroltestObservedOnWidth, // Set width
                child: Text(
                  'Fitness and Stress Observed On',
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
                  'Fitness Value',
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
                  'Stress Value',
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
          rows: widget.fitnessstressReportTableData.reversed
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
                    data.fitnessValue.toString(),
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
                    data.stressValue.toString(),
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
