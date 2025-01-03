import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:qiot_admin/models/fitness_stress_report_model/stress_fitness_report_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class StressReportChart extends StatefulWidget {
  List<FitnessStressReportModel>? fitnessstressReportChartData;
  bool hasData;
  StressReportChart(
      {super.key,
      required this.fitnessstressReportChartData,
      required this.hasData});

  @override
  State<StressReportChart> createState() => _StressReportChartState();
}

class _StressReportChartState extends State<StressReportChart> {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM - hh:mm a');
    return formatter.format(dateTime);
  }

  int mapFitnessCategoryToNumeric(String category) {
    switch (category) {
      case 'Low':
        return 1;
      case 'Medium':
        return 2;
      case 'High':
        return 3;
      default:
        return 0; // For undefined or invalid categories
    }
  }

  // Helper function to map numeric value back to label
  String mapNumericToFitnessCategory(int value) {
    switch (value) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d('Fitness and Stress: ${widget.hasData}');
    return !widget.hasData
        ? Center(
            child: Text(
              'No Stress data available',
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
            primaryYAxis: const NumericAxis(
              // Assuming fitness is represented as numeric value
              minimum: 0,
              maximum: 4, // Adjust according to your fitness values
              interval: 1,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Stress Levels',
            ),
            series: <CartesianSeries<FitnessStressReportModel, String>>[
              // Renders column chart
              ColumnSeries<FitnessStressReportModel, String>(
                dataSource: widget.fitnessstressReportChartData!,
                xValueMapper:
                    (FitnessStressReportModel fitnessstressReportChartData,
                            _) =>
                        formatDate(fitnessstressReportChartData.createdAt),
                yValueMapper:
                    (FitnessStressReportModel fitnessstressReportChartData,
                            _) =>

                        // fitnessstressReportChartData.fitnessValue,
                        mapFitnessCategoryToNumeric(
                            fitnessstressReportChartData.stressValue),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                ),
                pointColorMapper: (FitnessStressReportModel data, _) {
                  switch (data.fitnessValue.toLowerCase()) {
                    case 'low':
                      return const Color(0xFFFD4646); // Red
                    case 'medium':
                      return const Color(0xFFF2C94C); // Yellow
                    case 'high':
                      return const Color(0xFF27AE60); // Green
                    default:
                      return Colors.grey; // Default color
                  }
                },
              ),
            ],
          );
  }
}
