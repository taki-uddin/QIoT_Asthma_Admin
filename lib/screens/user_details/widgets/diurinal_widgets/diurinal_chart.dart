import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/diurinal_model.dart/diurinal_chart.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class DiurinalReportChart extends StatefulWidget {
  final List<DiurinalChartXModel>? diurinalxReportChartData;
  final List<DiurinalChartYModel>? diurinalyReportChartData;
  final bool hasData;

  const DiurinalReportChart({
    super.key,
    required this.diurinalxReportChartData,
    required this.diurinalyReportChartData,
    required this.hasData,
  });

  @override
  State<DiurinalReportChart> createState() => _DiurinalReportChartChartState();
}

class _DiurinalReportChartChartState extends State<DiurinalReportChart> {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM - hh:mm a');

    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
    logger.d('diurinal: ${widget.hasData}');
    return !widget.hasData
        ? Center(
            child: Text(
              'No diurinal data available',
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
            ),
            legend: const Legend(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'diurinal',
            ),
            series: <CartesianSeries<DiurinalChartXModel, String>>[
              LineSeries<DiurinalChartXModel, String>(
                dataSource: widget.diurinalxReportChartData,
                xValueMapper: (DiurinalChartXModel diurinal, _) =>
                    diurinal.date ?? " ",
                yValueMapper: (DiurinalChartXModel diurinal, int index) =>
                    widget.diurinalyReportChartData?[index].value ?? 0,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
              ),
            ],
          );
  }
}
