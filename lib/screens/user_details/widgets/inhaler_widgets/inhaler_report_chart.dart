import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InhalerReportChart extends StatefulWidget {
  final List<InhalerReportChartModel>? inhalerReportChartData;
  final String salbutomalDosage;
  final bool hasData;

  const InhalerReportChart({
    super.key,
    required this.inhalerReportChartData,
    required this.salbutomalDosage,
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
    // double salbutomalDosage = double.parse(widget.salbutomalDosage);
    return !widget.hasData
        ? Center(
            child: Text(
              'No Inhaler data available',
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
              title: AxisTitle(text: 'Inhaler Value'),
              minimum: 0,
              maximum: 20,
              interval: 1,
            ),
            axes: [
              NumericAxis(
                name: 'Salbutamol Dosage',
                opposedPosition: true,
                minimum: 0,
                maximum: widget.hasData
                    ? double.parse(widget.salbutomalDosage) * 20
                    : 20,
                interval:
                    widget.hasData ? double.parse(widget.salbutomalDosage) : 1,
                title: AxisTitle(text: 'Salbutamol Dosage'),
              ),
            ],
            legend: const Legend(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Inhaler',
            ),
            onTooltipRender: (TooltipArgs args) {
              // Find the corresponding data point
              final index = args.pointIndex ?? 0;
              final data = widget.inhalerReportChartData?[index.toInt()];
              double salvalue =
                  double.parse(widget.salbutomalDosage) * data!.inhalerValue;

              if (data != null) {
                args.text =
                    'Date: ${formatDate(data.createdAt)}\nInhaler Value: ${data.inhalerValue}\nSalbutamol Dosage: ${salvalue}';
              }
            },
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
