import 'package:flutter/material.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:qiot_admin/models/steroid_dose_model/steroid_dose_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_widgets/asthma_control_test_report_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/steroid_widgets/steroiddose_report_chart.dart';

// ignore: must_be_immutable
class SteroidReloadableChart extends StatefulWidget {
  List<SteroidDoseChartModel> steroidReportChartData;
  bool hasData;

  SteroidReloadableChart({
    super.key,
    required this.steroidReportChartData,
    required this.hasData,
  });

  @override
  SteroidReloadableChartState createState() => SteroidReloadableChartState();
}

class SteroidReloadableChartState extends State<SteroidReloadableChart> {
  void reloadWidget(
      List<SteroidDoseChartModel> newData, bool newHasData) {
    setState(() {
      widget.steroidReportChartData = newData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.d('AsthmaReloadableChart: ${widget.hasData}');
    return SteroidReportChart(
      steroidReportChartData: widget.steroidReportChartData,
      hasData: widget.hasData,
    );
  }
}
