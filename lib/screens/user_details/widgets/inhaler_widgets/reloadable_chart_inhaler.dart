import 'package:flutter/material.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:qiot_admin/screens/user_details/widgets/inhaler_widgets/inhaler_report_chart.dart';

class InhalerReloadableChart extends StatefulWidget {
  String salbutomalDosage;
  List<InhalerReportChartModel> inhalerReportChartData;
  bool hasData;

  InhalerReloadableChart({
    super.key,
    required this.salbutomalDosage,
    required this.inhalerReportChartData,
    required this.hasData,
  });

  @override
  InhalerReloadableChartState createState() => InhalerReloadableChartState();
}

class InhalerReloadableChartState extends State<InhalerReloadableChart> {
  void reloadWidget(List<InhalerReportChartModel> newData, bool newHasData) {
    setState(() {
      widget.inhalerReportChartData = newData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return PeakflowReportChart(
    //   baseLineScore: widget.baseLineScore,
    //   peakflowReportChartData: widget.peakflowReportChartData,
    //   hasData: widget.hasData,
    // );
    return InhalerReportChart(
        inhalerReportChartData: widget.inhalerReportChartData,
        salbutomalDosage: widget.salbutomalDosage,
        hasData: widget.hasData);
  }
}
