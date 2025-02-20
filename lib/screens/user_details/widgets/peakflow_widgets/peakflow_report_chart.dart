import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class PeakflowReportChart extends StatefulWidget {
  final List<PeakflowReportChartModel>? peakflowReportChartData;
  final String baseLineScore;
  final bool hasData;

  const PeakflowReportChart({
    super.key,
    required this.peakflowReportChartData,
    required this.baseLineScore,
    required this.hasData,
  });

  @override
  State<PeakflowReportChart> createState() => _PeakflowReportChartState();
}

class _PeakflowReportChartState extends State<PeakflowReportChart> {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM');

    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;

    logger.d('Peakflow: ${widget.hasData}');
    return !widget.hasData
        ?  Center(
            child: Text(
              'No peakflow data available',
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
            primaryYAxis: NumericAxis(
              // Changed from CategoryAxis to NumericAxis
              minimum: 0,
              maximum: 800,
              interval: 100,
              plotBands: [
                PlotBand(
                  verticalTextPadding: '5%',
                  horizontalTextPadding: '5%',
                  textAngle: 0,
                  start: double.parse(widget
                      .baseLineScore), // Ensure base line score is parsed to double
                  end: double.parse(widget.baseLineScore),
                  borderColor: const Color(0xFF27AE60),//.withOpacity(1),
                  borderWidth: 2,
                ),
                PlotBand(
                  start: 0,
                  end: 200,
                  color: const Color(0xFFD10000)
                ),
                PlotBand(
                  start: 200,
                  end: 400,
                  color: const Color(0xFFFD4646)
                ),
                PlotBand(
                  start: 400,
                  end: 600,
                  color: const Color(0xFFFF8500)
                ),
                PlotBand(
                  start: 600,
                  end: 800,
                  color: const Color(0xFF27AE60)
                ),
              ],
            ),
            legend: const Legend(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Peakflow',
            ),
            series: <CartesianSeries<PeakflowReportChartModel, String>>[
              LineSeries<PeakflowReportChartModel, String>(
                dataSource: widget.peakflowReportChartData,
                xValueMapper: (PeakflowReportChartModel peakflow, _) =>
                    formatDate(peakflow.createdAt),
                yValueMapper: (PeakflowReportChartModel peakflow, _) =>
                    peakflow.peakflowValue,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
              ),
            ],
          );
  }
}




