import 'package:flutter/material.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_widgets/asthma_control_test_report_chart.dart';

// ignore: must_be_immutable
class AsthmaReloadableChart extends StatefulWidget {
  List<AsthmaControlTestReportChartModel> asthmaControlTestReportChartData;
  bool hasData;

  AsthmaReloadableChart({
    super.key,
    required this.asthmaControlTestReportChartData,
    required this.hasData,
  });

  @override
  AsthmaReloadableChartState createState() => AsthmaReloadableChartState();
}

class AsthmaReloadableChartState extends State<AsthmaReloadableChart> {
  void reloadWidget(
      List<AsthmaControlTestReportChartModel> newData, bool newHasData) {
    setState(() {
      widget.asthmaControlTestReportChartData = newData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.d('AsthmaReloadableChart: ${widget.hasData}');
    return AsthmaControlTestReportChart(
      asthmacontroltestReportChartData: widget.asthmaControlTestReportChartData,
      hasData: widget.hasData,
    );
  }
}
