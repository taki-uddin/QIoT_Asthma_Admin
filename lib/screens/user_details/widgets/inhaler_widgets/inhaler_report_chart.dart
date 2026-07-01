import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:qiot_admin/utils/effective_recorded_time.dart';
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
  String _formatTooltipDate(String dateString) {
    final dateTime = parseRecordedAt(dateString);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    logger.d('Inhaler: ${widget.hasData}');
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
              final index = args.pointIndex ?? 0;
              final data = widget.inhalerReportChartData?[index.toInt()];
              if (data == null) return;

              final salvalue =
                  double.parse(widget.salbutomalDosage) * data.inhalerValue;
              args.text =
                  'Date: ${_formatTooltipDate(data.createdAt)}\nInhaler Value: ${data.inhalerValue}\nSalbutamol Dosage: $salvalue';
            },
            series: <CartesianSeries<InhalerReportChartModel, DateTime>>[
              LineSeries<InhalerReportChartModel, DateTime>(
                dataSource: widget.inhalerReportChartData,
                xValueMapper: (InhalerReportChartModel inhaler, _) =>
                    parseRecordedAt(inhaler.createdAt),
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
