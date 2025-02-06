import 'package:flutter/material.dart';
import 'package:qiot_admin/models/diurinal_model.dart/diurinal_chart.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:qiot_admin/screens/user_details/widgets/diurinal_widgets/diurinal_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/inhaler_widgets/inhaler_report_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_widgets/peakflow_report_chart.dart';

// ignore: must_be_immutable
class DiurinalReloadableChart extends StatefulWidget {
  List<DiurinalChartXModel> diruinalxReportChartData;
  List<DiurinalChartYModel> diruinalyReportChartData;

  bool hasData;

  DiurinalReloadableChart({
    super.key,
    required this.diruinalxReportChartData,
    required this.diruinalyReportChartData,
    required this.hasData,
  });

  @override
  DiurinalReloadableChartState createState() => DiurinalReloadableChartState();
}

class DiurinalReloadableChartState extends State<DiurinalReloadableChart> {
  void reloadWidget(List<DiurinalChartXModel> xnewData,
      List<DiurinalChartYModel> ynewData, bool newHasData) {
    setState(() {
      widget.diruinalxReportChartData = xnewData;

      widget.diruinalyReportChartData = ynewData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DiurinalReportChart(
      diurinalxReportChartData: widget.diruinalxReportChartData,
      diurinalyReportChartData: widget.diruinalyReportChartData,
      hasData: widget.hasData,
    );
  }
}
