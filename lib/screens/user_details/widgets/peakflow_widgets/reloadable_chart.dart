import 'package:flutter/material.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:qiot_admin/screens/user_details/widgets/inhaler_widgets/inhaler_report_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_widgets/peakflow_report_chart.dart';

// ignore: must_be_immutable
class ReloadableChart extends StatefulWidget {
  String baseLineScore;
  List<PeakflowReportChartModel> peakflowReportChartData;
  bool hasData;

  ReloadableChart({
    super.key,
    required this.baseLineScore,
    required this.peakflowReportChartData,
    required this.hasData,
  });

  @override
  ReloadableChartState createState() => ReloadableChartState();
}

class ReloadableChartState extends State<ReloadableChart> {
  void reloadWidget(List<PeakflowReportChartModel> newData, bool newHasData) {
    setState(() {
      widget.peakflowReportChartData = newData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PeakflowReportChart(
      baseLineScore: widget.baseLineScore,
      peakflowReportChartData: widget.peakflowReportChartData,
      hasData: widget.hasData,
    );
  }
}

