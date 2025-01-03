import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class AsthmaControlTestReportChart extends StatefulWidget {
  List<AsthmaControlTestReportChartModel>? asthmacontroltestReportChartData;
  bool hasData;
  AsthmaControlTestReportChart(
      {super.key,
      required this.asthmacontroltestReportChartData,
      required this.hasData});

  @override
  State<AsthmaControlTestReportChart> createState() =>
      _AsthmaControlTestReportChartState();
}

class _AsthmaControlTestReportChartState
    extends State<AsthmaControlTestReportChart> {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM - hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    logger.d('AsthmaControlTestReportChart: ${widget.hasData}');
    return !widget.hasData
        ? Center(
            child: Text(
              'No asthma control test data available',
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
              maximum: 30,
              interval: 5,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Asthma Control Test',
            ),
            series: <CartesianSeries<AsthmaControlTestReportChartModel,
                String>>[
              // Renders column chart
              ColumnSeries<AsthmaControlTestReportChartModel, String>(
                dataSource: widget.asthmacontroltestReportChartData!,
                xValueMapper: (AsthmaControlTestReportChartModel
                            asthmacontroltestReportChartData,
                        _) =>
                    formatDate(asthmacontroltestReportChartData.createdAt),
                yValueMapper: (AsthmaControlTestReportChartModel
                            asthmacontroltestReportChartData,
                        _) =>
                    asthmacontroltestReportChartData.asthmacontroltestValue,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                ),
                pointColorMapper: (AsthmaControlTestReportChartModel
                        asthmacontroltestReportChartData,
                    _) {
                  if (asthmacontroltestReportChartData.asthmacontroltestValue <
                      21) {
                    return const Color(0xFFFD4646);
                  } else if (asthmacontroltestReportChartData
                          .asthmacontroltestValue <
                      25) {
                    return const Color(0xFFF2C94C);
                  } else {
                    return const Color(0xFF27AE60);
                  }
                },
              ),
            ],
          );
  }
}
