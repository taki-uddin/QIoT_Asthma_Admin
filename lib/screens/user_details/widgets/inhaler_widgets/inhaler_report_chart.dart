
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InhalerReportChart extends StatefulWidget {
  final List<InhalerReportChartModel>? inhalerReportChartData;
  final String baseLineScore;
  final bool hasData;

  const InhalerReportChart({
    super.key,
    required this.inhalerReportChartData,
    required this.baseLineScore,
    required this.hasData,
  });

  @override
  State<InhalerReportChart> createState() => _InhalerReportChartState();
}

class _InhalerReportChartState extends State<InhalerReportChart> {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM - hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;

    logger.d('Inhaler: ${widget.hasData}');
    return !widget.hasData
        ? const Center(
            child: Text(
              'No Inhaler data available',
              style: TextStyle(
                color: WebColors.primaryBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
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
              maximum: 50,
              interval: 5,
              plotBands: [
                PlotBand(
                  verticalTextPadding: '5%',
                  horizontalTextPadding: '5%',
                  textAngle: 0,
                  start: double.parse(widget
                      .baseLineScore), // Ensure base line score is parsed to double
                  end: double.parse(widget.baseLineScore),
                  borderColor: const Color(0xFF27AE60).withOpacity(1),
                  borderWidth: 2,
                ),
                PlotBand(
                  start: 0,
                  end: 200,
                  color: const Color(0xFFFD4646).withOpacity(0.4),
                ),
                PlotBand(
                  start: 200,
                  end: 400,
                  color: const Color(0xFFFF8500).withOpacity(0.4),
                ),
                PlotBand(
                  start: 400,
                  end: 800,
                  color: const Color(0xFF27AE60).withOpacity(0.4),
                ),
              ],
            ),
            legend: const Legend(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Inhaler',
            ),
            
            series: <CartesianSeries<InhalerReportChartModel, String>>[
              LineSeries<InhalerReportChartModel, String>(
                dataSource: widget.inhalerReportChartData,
                xValueMapper: (InhalerReportChartModel inhaler, _) =>
                    formatDate(inhaler.createdAt),
                yValueMapper: (InhalerReportChartModel inhaler, _) =>
                    inhaler.inhalerValue,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
              ),
            ],
          );
  }
}
