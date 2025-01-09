import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:qiot_admin/models/steroid_dose_model/steroid_dose_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class SteroidReportChart extends StatefulWidget {
  List<SteroidDoseChartModel>? steroidReportChartData;
  bool hasData;
  SteroidReportChart(
      {super.key, required this.steroidReportChartData, required this.hasData});

  @override
  State<SteroidReportChart> createState() => _SteroidReportChartState();
}

class _SteroidReportChartState extends State<SteroidReportChart> {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM - hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    logger.d('SteroidReportChart: ${widget.hasData}');
    return !widget.hasData
        ? Center(
            child: Text(
              'No steroid data available',
              style: GoogleFonts.manrope(
                color: WebColors.primaryBlue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : SfCartesianChart(
            zoomPanBehavior: ZoomPanBehavior(
              enablePanning: true,
            ),
            enableAxisAnimation: true,
            primaryXAxis: CategoryAxis(
              autoScrollingDelta: 7,
              autoScrollingMode: AutoScrollingMode.end,
              labelRotation: 300,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              labelStyle: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            primaryYAxis: const NumericAxis(
              // Assuming fitness is represented as numeric value
              minimum: 0,
              maximum: 120,
              interval: 10,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Steroid Dosage',
            ),
            series: <CartesianSeries<SteroidDoseChartModel, String>>[
              // Renders column chart
              ColumnSeries<SteroidDoseChartModel, String>(
                dataSource: widget.steroidReportChartData!,
                xValueMapper:
                    (SteroidDoseChartModel steroidReportChartData, _) =>
                        formatDate(steroidReportChartData.createdAt),
                yValueMapper:
                    (SteroidDoseChartModel steroidReportChartData, _) =>
                        steroidReportChartData.steroiddoseValue,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                ),
                // pointColorMapper: (SteroidDoseChartModel
                //         asthmacontroltestReportChartData,
                //     _) {
                //   if (asthmacontroltestReportChartData.asthmacontroltestValue <
                //       21) {
                //     return const Color(0xFFFD4646);
                //   } else if (asthmacontroltestReportChartData
                //           .asthmacontroltestValue <
                //       25) {
                //     return const Color(0xFFF2C94C);
                //   } else {
                //     return const Color(0xFF27AE60);
                //   }
                // },
              ),
            ],
          );
  }
}
