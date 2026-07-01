import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:qiot_admin/utils/effective_recorded_time.dart';
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
  @override
  Widget build(BuildContext context) {
    logger.d('Peakflow: ${widget.hasData}');
    return !widget.hasData
        ? Center(
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
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat('dd MMM\nhh a'),
              intervalType: DateTimeIntervalType.auto,
              labelRotation: -45,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              labelStyle: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 800,
              interval: 100,
              plotBands: [
                PlotBand(
                  verticalTextPadding: '5%',
                  horizontalTextPadding: '5%',
                  textAngle: 0,
                  start: double.parse(widget.baseLineScore),
                  end: double.parse(widget.baseLineScore),
                  borderColor: const Color(0xFF27AE60).withOpacity(1),
                  borderWidth: 2,
                ),
                PlotBand(
                  start: 0,
                  end: 400,
                  color: const Color(0xFFD10000).withOpacity(0.6),
                ),
                PlotBand(
                  start: 400,
                  end: 472,
                  color: const Color(0xFFFD4646).withOpacity(0.6),
                ),
                PlotBand(
                  start: 472,
                  end: 632,
                  color: const Color(0xFFFF8500).withOpacity(0.6),
                ),
                PlotBand(
                  start: 632,
                  end: 800,
                  color: const Color(0xFF27AE60).withOpacity(0.6),
                ),
              ],
            ),
            legend: const Legend(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Peakflow',
              format: 'point.x : point.y',
            ),
            series: <CartesianSeries<PeakflowReportChartModel, DateTime>>[
              LineSeries<PeakflowReportChartModel, DateTime>(
                dataSource: widget.peakflowReportChartData,
                xValueMapper: (PeakflowReportChartModel peakflow, _) =>
                    parseRecordedAt(peakflow.createdAt),
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
