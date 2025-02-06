import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qiot_admin/constants/month_abbreviations.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_table_model.dart';
import 'package:qiot_admin/models/diurinal_model.dart/diurinal_chart.dart';
import 'package:qiot_admin/models/diurinal_model.dart/diurinal_table.dart';
import 'package:qiot_admin/models/fitness_stress_report_model/stress_fitness_report_model.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_table_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_table_model.dart';
import 'package:qiot_admin/helpers/pdf.dart/pdfgeneration.dart';
import 'package:qiot_admin/models/steroid_dose_model/steroid_dose_chart.dart';
import 'package:qiot_admin/models/steroid_dose_model/steroid_dose_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_widgets/act_legends_zone.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_widgets/asthma_control_test_report_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_widgets/asthma_reloadable_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/button_tab_widget.dart';
import 'package:qiot_admin/screens/user_details/widgets/diurinal_widgets/diurinal_reloadable.dart';
import 'package:qiot_admin/screens/user_details/widgets/diurinal_widgets/diurinal_widget_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/fitnessStress_widgets/fitness_stress_reloadable_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/fitnessStress_widgets/fitness_stress_report_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/fitnessStress_widgets/fitnessstress_legends_zone.dart';
import 'package:qiot_admin/screens/user_details/widgets/inhaler_widgets/inhaler_legends_zone.dart';
import 'package:qiot_admin/screens/user_details/widgets/inhaler_widgets/inhaler_report_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/inhaler_widgets/reloadable_chart_inhaler.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_widgets/peakflow_legends_zone.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_widgets/peakflow_report_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_widgets/reloadable_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/steroid_widgets/steroiddose_reloadable_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/steroid_widgets/steroiddose_report_table.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class UserDetails extends StatefulWidget {
  final String userId; // Add a field to store the user ID
  const UserDetails({super.key, required this.userId});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  Map<String, dynamic> userData = {};
  bool hasData = false;
  String userId = '';
  String type = 'Daily';

  List<dynamic> peakflowReportHistory = [];
  Map<String, dynamic> peakflowReportData = {};
  List<PeakflowReportChartModel> peakflowReportChartData = [];
  List<PeakflowReportTableModel> peakflowReportTableData = [];

  //for inhaler
  List<dynamic> inhalerReportHistory = [];
  Map<String, dynamic> inhalerReportData = {};
  List<InhalerReportChartModel> inhalerReportChartData = [];
  List<InhalerReportTableModel> inhalerReportTableData = [];

  List<dynamic> asthmaReportHistory = [];
  Map<String, dynamic> asthmacontroltestReportData = {};
  List<AsthmaControlTestReportChartModel> asthmacontroltestReportChartData = [];
  List<AsthmaControlTestReportTableModel> asthmacontroltestReportTableData = [];

  List<dynamic> steroidReportHistory = [];
  Map<String, dynamic> steroidReportData = {};
  List<SteroidDoseChartModel> steroidReportChartData = [];
  List<SteroidDoseTableModel> steroidReportTableData = [];

  List<dynamic> diurinalReportHistory = [];
  Map<String, dynamic> diurinalReportData = {};
  List<DiurinalChartXModel> diurinalReportChartDataxaxis = [];
  List<DiurinalChartYModel> diurinalReportChartDatayaxis = [];
  List<DiurinalTableModel> diurinalReportTableData = [];

  List<dynamic> fitnessStressReportHistory = [];
  Map<String, dynamic> fitnessstressReportData = {};
  List<FitnessStressReportModel> fitnessstressReportChartData = [];
  List<FitnessStressReportModel> fitnessstressReportTableData = [];

  DateTime currentDate = DateTime.now();
  int currentMonth = 1;
  int currentYear = 1;

  DateTime? _selectedStartDate, _selectedEndDate;

  bool downloadReport = false;
  bool peakflow = true;
  bool asthma = false;
  bool steroid = false;
  bool inhaler = false;
  bool diurinal = false;
  bool fitnessStress = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      userId = widget.userId;
      currentMonth = currentDate.month;
      currentYear = currentDate.year;
      _selectedStartDate = currentDate;
      _selectedEndDate = currentDate;
    });
    _getUserByIdData(userId);
    _getPeakflowHistory(currentMonth, currentYear);
    // _getInhalerHistory(currentMonth, currentYear);
  }

  Future<void> _getUserByIdData(String userId) async {
    DashboardUsersData.getUserByIdData(userId).then(
      (value) async {
        if (value != null) {
          setState(() {
            userData = value['payload'];
            hasData = true;
          });
        } else {
          logger.d('Failed to get user data');
        }
      },
    );
  }

  Future<void> _getPeakflowHistory(int currentMonth, int currentYear) async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');
    try {
      peakflowReportChartData.clear();
      peakflowReportTableData.clear();
      DashboardUsersData.getPeakflowhistories(
        userId,
        currentMonth,
        currentYear,
      ).then(
        (value) async {
          if (value != null) {
            // logger.d('value: ${value['payload']}');
            setState(() {
              peakflowReportData = value['payload'];
            });
            for (var i in peakflowReportData['peakflow']) {
              peakflowReportChartData.add(
                PeakflowReportChartModel(
                  i['createdAt'],
                  i['peakflowValue'],
                ),
              );
              peakflowReportTableData.add(
                PeakflowReportTableModel(
                  i['createdAt'],
                  i['peakflowValue'],
                  i['highValue'],
                  i['lowValue'],
                  double.tryParse(i['averageValue'].toString()) ?? 0.0,
                  double.tryParse(i['dailyVariation'].toString()) ?? 0.0,
                ),
              );
            }
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getInhalerHistory(int currentMonth, int currentYear) async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');
    try {
      // peakflowReportChartData.clear();
      // peakflowReportTableData.clear();
      inhalerReportChartData.clear();
      inhalerReportTableData.clear();
      DashboardUsersData.getInhalerhistories(
        userId,
        currentMonth,
        currentYear,
      ).then(
        (value) async {
          if (value != null) {
            // logger.d('value: ${value['payload']}');
            setState(() {
              inhalerReportData = value['payload'];
            });
            for (var i in inhalerReportData['inhaler']) {
              inhalerReportChartData.add(
                InhalerReportChartModel(
                  i['createdAt'],
                  i['inhalerValue'],
                ),
              );
              inhalerReportTableData.add(
                InhalerReportTableModel(
                  i['createdAt'],
                  i['inhalerValue'],
                  i['highValue'],
                  i['lowValue'],
                  double.tryParse(i['averageValue'].toString()) ?? 0.0,
                  double.tryParse(i['dailyVariation'].toString()) ?? 0.0,
                ),
              );
            }
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getPeakflowHistoryReport() async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');

    if (_selectedStartDate != null && _selectedEndDate != null) {
      if (_selectedEndDate!.year < _selectedStartDate!.year ||
          (_selectedEndDate!.year == _selectedStartDate!.year &&
              _selectedEndDate!.month < _selectedStartDate!.month)) {
        _showErrorDialog('Error retrieving data, please verify the dates.');
        return;
      }
    }

    try {
      DashboardUsersData.getPeakflowhistoryReport(
        context,
        userId,
        _selectedStartDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedStartDate?.year ?? int.parse(DateTime.now().year.toString()),
        _selectedEndDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedEndDate?.year ?? int.parse(DateTime.now().year.toString()),
      ).then(
        (value) async {
          if (value != null) {
            // logger.d('value: ${value['payload']}');
            setState(() {
              peakflowReportHistory = value['payload']['peakflow'];
            });
            logger.d(
                'peakflowReportHistory: ${peakflowReportHistory.toString()}');

            await generatePDFReport(peakflowReportHistory,
                'Peak Flow History Report', 'Peak flow', 'peakflow');
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getInhalerHistoryReport() async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');

    if (_selectedStartDate != null && _selectedEndDate != null) {
      if (_selectedEndDate!.year < _selectedStartDate!.year ||
          (_selectedEndDate!.year == _selectedStartDate!.year &&
              _selectedEndDate!.month < _selectedStartDate!.month)) {
        _showErrorDialog('Error retrieving data, please verify the dates.');
        return;
      }
    }
    try {
      DashboardUsersData.getInhalerhistoryReport(
        context,
        userId,
        _selectedStartDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedStartDate?.year ?? int.parse(DateTime.now().year.toString()),
        _selectedEndDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedEndDate?.year ?? int.parse(DateTime.now().year.toString()),
      ).then(
        (value) async {
          if (value != null) {
            // logger.d('value: ${value['payload']}');
            setState(() {
              inhalerReportHistory = value['payload']['inhaler'];
            });
            logger.d('Inhaler report: ${inhalerReportHistory.toString()}');
            await generatePDFReport(inhalerReportHistory,
                'Inhaler History Report', 'Inhaler Value', 'inhaler');
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getFitnessStressHistoryReport() async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');

    if (_selectedStartDate != null && _selectedEndDate != null) {
      if (_selectedEndDate!.year < _selectedStartDate!.year ||
          (_selectedEndDate!.year == _selectedStartDate!.year &&
              _selectedEndDate!.month < _selectedStartDate!.month)) {
        _showErrorDialog('Error retrieving data, please verify the dates.');
        return;
      }
    }
    try {
      DashboardUsersData.getFitnessStresshistoryReport(
        context,
        userId,
        _selectedStartDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedStartDate?.year ?? int.parse(DateTime.now().year.toString()),
        _selectedEndDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedEndDate?.year ?? int.parse(DateTime.now().year.toString()),
      ).then(
        (value) async {
          if (value != null) {
            // logger.d('value: ${value['payload']}');
            setState(() {
              fitnessStressReportHistory = value['payload']['fitnessAndStress'];
            });
            logger
                .d('Inhaler report: ${fitnessStressReportHistory.toString()}');
            await generatePDFReport(
                fitnessStressReportHistory,
                'Fitness and Stress History Report',
                'Fitness and Stress',
                'fitness');
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getDiurinalHistoryReport() async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');

    if (_selectedStartDate != null && _selectedEndDate != null) {
      if (_selectedEndDate!.year < _selectedStartDate!.year ||
          (_selectedEndDate!.year == _selectedStartDate!.year &&
              _selectedEndDate!.month < _selectedStartDate!.month)) {
        _showErrorDialog('Error retrieving data, please verify the dates.');
        return;
      }
    }
    try {
      DashboardUsersData.getDiurinalhistoryReport(
        context,
        userId,
        _selectedStartDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedStartDate?.year ?? int.parse(DateTime.now().year.toString()),
        type,
        _selectedEndDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedEndDate?.year ?? int.parse(DateTime.now().year.toString()),
      ).then(
        (value) async {
          if (value != null) {
            // logger.d('value: ${value['payload']}');
            setState(() {
              diurinalReportHistory = value['payload']['diurnalData'];
            });
            logger.d('Diurinal report: ${diurinalReportHistory.toString()}');
            await generatePDFReport(diurinalReportHistory,
                'Diurinal History Report', 'Diurinal Data', 'diurinal');
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getSteroidHistoryReport() async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');

    if (_selectedStartDate != null && _selectedEndDate != null) {
      if (_selectedEndDate!.year < _selectedStartDate!.year ||
          (_selectedEndDate!.year == _selectedStartDate!.year &&
              _selectedEndDate!.month < _selectedStartDate!.month)) {
        _showErrorDialog('Error retrieving data, please verify the dates.');
        return;
      }
    }
    try {
      DashboardUsersData.getSteroidhistoryReport(
        context,
        userId,
        _selectedStartDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedStartDate?.year ?? int.parse(DateTime.now().year.toString()),
        _selectedEndDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedEndDate?.year ?? int.parse(DateTime.now().year.toString()),
      ).then(
        (value) async {
          if (value != null) {
            // logger.d('value: ${value['payload']}');
            setState(() {
              steroidReportHistory = value['payload']['steroid'];
            });
            logger.d('Steroid report: ${steroidReportHistory.toString()}');
            await generatePDFReport(steroidReportHistory, 'Steroid Report',
                'Steroid Dosage', 'steroid');
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops!'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> generatePDFReport(
      List<dynamic> report, String header, String value, String type) async {
    final pdf = pw.Document();

    // Create a header for the PDF
    pw.Widget _buildHeader() {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(header,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Generated on: ${DateTime.now().toLocal()}',
                style: pw.TextStyle(fontSize: 12)),
            pw.Divider()
          ]);
    }

    // Create a detailed table of measurements

    pw.Widget _buildDetailTable(List<dynamic> data) {
      return type == 'fitness'
          ? pw.TableHelper.fromTextArray(
              context: null,
              data: [
                ...data
                    .map((entry) => [
                          entry['createdAt'].toString(),
                          entry['fitness'].toString(),
                          entry['stress'].toString()
                        ])
                    .toList()
              ],
              headers: [
                'Date',
                'Fitness Value',
                'Stress Value',
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerAlignment: pw.Alignment.center,
              cellAlignment: pw.Alignment.center,
            )
          : type == 'steroid'
              ? pw.TableHelper.fromTextArray(
                  context: null,
                  data: [
                    ...data
                        .map((entry) => [
                              entry['createdAt'].toString(),
                              entry['steroidDoseValue'].toString(),
                            ])
                        .toList()
                  ],
                  headers: [
                    'Date',
                    'Steroid Dsosage Value',
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellStyle: pw.TextStyle(fontSize: 10),
                  headerAlignment: pw.Alignment.center,
                  cellAlignment: pw.Alignment.center,
                )
              : type == 'diurinal'
                  ? pw.TableHelper.fromTextArray(
                      context: null,
                      data: [
                        ...data
                            .map((entry) => [
                                  entry['createdAt'].toString(),
                                  entry['highvalue'].toString(),
                                  entry['lowvalue'].toString(),
                                  entry['DailyMean'].toString(),
                                  entry['DailyVariation'].toString(),
                                  // entry['dailyVariation'].toString()
                                ])
                            .toList()
                      ],
                      headers: [
                        'Date',
                        'High Value',
                        'Low Value',
                        'Daily Mean',
                        'Daily Variation',
                      ],
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      cellStyle: pw.TextStyle(fontSize: 10),
                      headerAlignment: pw.Alignment.center,
                      cellAlignment: pw.Alignment.center,
                    )
                  : type == 'asthma'
                      ? pw.TableHelper.fromTextArray(
                          context: null,
                          data: [
                            ...data
                                .map((entry) => [
                                      entry['createdAt'].toString(),
                                      entry['actScore'].toString(),
                                    ])
                                .toList()
                          ],
                          headers: [
                            'Date',
                            'ACT Score',
                          ],
                          headerStyle:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          cellStyle: pw.TextStyle(fontSize: 10),
                          headerAlignment: pw.Alignment.center,
                          cellAlignment: pw.Alignment.center,
                        )
                      : pw.TableHelper.fromTextArray(
                          context: null,
                          data: [
                            ...data
                                .map((entry) => [
                                      entry['createdAt'].toString(),
                                      type == 'peakflow'
                                          ? entry['peakflowValue'].toString()
                                          : type == 'inhaler'
                                              ? entry['inhalerValue'].toString()
                                              : "No data",
                                      '${entry['dailyVariation'].toStringAsFixed(2)}%',
                                      entry['highValue'].toString(),
                                      entry['lowValue'].toString(),
                                      entry['averageValue'].toString()
                                    ])
                                .toList()
                          ],
                          headers: [
                            'Date',
                            value,
                            'Daily Variation',
                            'High Value',
                            'Low Value',
                            'Average'
                          ],
                          headerStyle:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          cellStyle: pw.TextStyle(fontSize: 10),
                          headerAlignment: pw.Alignment.center,
                          cellAlignment: pw.Alignment.center,
                        );
    }

    //pdf making
    pdf.addPage(pw.MultiPage(
        build: (pw.Context context) => [
              _buildHeader(),
              // _buildSummary(report),
              pw.SizedBox(height: 20),
              pw.Text('Detailed Measurements',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildDetailTable(report)
            ]));

    // Save the PDF
    try {
      final pdfBytes = await pdf.save();
      final fileName = value + '_${DateTime.now().toString()}.pdf';

      final savedFile = await PDFSaver.savePDF(pdfBytes, fileName);

      if (savedFile != null) {
        logger.d('PDF saved at: ${savedFile.path}');
      }
    } catch (e) {
      logger.e('Error generating PDF: $e');
    }
  }

  Future<void> _getACTHistory(int currentMonth, int currentYear) async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');
    try {
      asthmacontroltestReportChartData.clear();
      asthmacontroltestReportTableData.clear();
      DashboardUsersData.getACThistories(
        userId,
        currentMonth,
        currentYear,
      ).then(
        (value) async {
          print('the vlaue issssssss');
          print(value);

          print('API Response: $value');
          print('Payload: ${value?['payload']}');
          if (value != null) {
            logger.d('value: ${value['payload']}');
            setState(() {
              asthmacontroltestReportData = value['payload'];
            });
            for (var i in asthmacontroltestReportData['asthamcontroltest']) {
              asthmacontroltestReportChartData.add(
                AsthmaControlTestReportChartModel(
                  i['createdAt'],
                  i['actScore'],
                ),
              );
              asthmacontroltestReportTableData.add(
                AsthmaControlTestReportTableModel(
                  i['createdAt'],
                  i['actScore'],
                ),
              );
            }
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getasthmaHistoryReport() async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');

    if (_selectedStartDate != null && _selectedEndDate != null) {
      if (_selectedEndDate!.year < _selectedStartDate!.year ||
          (_selectedEndDate!.year == _selectedStartDate!.year &&
              _selectedEndDate!.month < _selectedStartDate!.month)) {
        _showErrorDialog('Error retrieving data, please verify the dates.');
        return;
      }
    }
    try {
      DashboardUsersData.getAsthmahistoryReport(
        context,
        userId,
        _selectedStartDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedStartDate?.year ?? int.parse(DateTime.now().year.toString()),
        _selectedEndDate?.month ?? int.parse(DateTime.now().month.toString()),
        _selectedEndDate?.year ?? int.parse(DateTime.now().year.toString()),
      ).then(
        (value) async {
          if (value != null) {
            // logger.d('value: ${value['payload']}');
            setState(() {
              asthmaReportHistory = value['payload']['asthma'];
            });
            logger.d('asthma report: ${asthmaReportHistory.toString()}');
            await generatePDFReport(asthmaReportHistory, 'Asthma Report',
                'Asthma Values', 'asthma');
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getSteroidHistory(int currentMonth, int currentYear) async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');
    try {
      steroidReportChartData.clear();
      steroidReportTableData.clear();
      DashboardUsersData.getSteroidhistories(
        userId,
        currentMonth,
        currentYear,
      ).then(
        (value) async {
          print(value);

          print('API Response: $value');
          print('Payload: ${value?['payload']}');
          if (value != null) {
            logger.d('value: ${value['payload']}');
            setState(() {
              steroidReportData = value['payload'];
            });
            for (var i in steroidReportData['steroiddose']) {
              steroidReportChartData.add(
                SteroidDoseChartModel(
                  i['createdAt'],
                  i['steroidDoseValue'],
                ),
              );
              steroidReportTableData.add(
                SteroidDoseTableModel(
                  i['createdAt'],
                  i['steroidDoseValue'],
                ),
              );
            }
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getDiurinalHistory(int currentMonth, int currentYear) async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');
    try {
      // peakflowReportChartData.clear();
      // peakflowReportTableData.clear();
      // inhalerReportChartData.clear();
      // inhalerReportTableData.clear();
      diurinalReportTableData.clear();
      DashboardUsersData.getdiurinalhistories(
              userId, currentMonth, currentYear, type)
          .then(
        (value) async {
          if (value != null) {
            // logger.d('value: ${value['payload']}');
            setState(() {
              diurinalReportData = value['payload'];
            });
            for (var i in diurinalReportData['x_Axis']) {
              diurinalReportChartDataxaxis.add(DiurinalChartXModel(date: i));
            }
            for (var i in diurinalReportData['y_Axis']) {
              diurinalReportChartDatayaxis.add(DiurinalChartYModel(value: i));
            }

            for (var i in diurinalReportData['DiurinalVariation']) {
              // inhalerReportChartData.add(
              //   InhalerReportChartModel(
              //     i['createdAt'],
              //     i['inhalerValue'],
              //   ),
              // );
              diurinalReportTableData.add(
                DiurinalTableModel(
                  i['highvalue'],
                  i['lowvalue'],
                  i['createdAt'],
                  double.tryParse(i['DailyMean'].toString()) ?? 0.0,
                  // i['DailyMean'],
                  double.tryParse(i['DailyVariation'].toString()) ?? 0.0,
                ),
              );
            }
            print('the added data is:');
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _getFitnessStressHistory(
      int currentMonth, int currentYear) async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');

    try {
      setState(() {
        fitnessstressReportChartData.clear();
        fitnessstressReportTableData.clear();
      });

      final value = await DashboardUsersData.getFitnessStresshistories(
        userId,
        currentMonth,
        currentYear,
      );

      print('API Response: $value');

      if (value == null || value['payload'] == null) {
        logger.d('Failed to get user fitness and stress data');
        return;
      }

      setState(() {
        fitnessstressReportData = value['payload'];

        final fitnessData = fitnessstressReportData['fitnessandstress'] ?? [];
        print('Fitness and Stress Data: $fitnessData');

        for (var i in fitnessData) {
          try {
            print('Processing record: $i');

            final model = FitnessStressReportModel(
              i['createdAt'] ?? '',
              i['fitness'] ?? 'No Data',
              i['stress'] ?? 'No Data',
            );

            fitnessstressReportChartData.add(model);
            fitnessstressReportTableData.add(model);
          } catch (e) {
            logger.e('Error processing record: $i, Error: $e');
          }
        }
      });
    } catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  void getPrevMonthPeakflow() {
    setState(() {
      peakflowReportChartData.clear();
      peakflowReportTableData.clear();

      currentMonth -= 1;
      if (currentMonth == 0) {
        currentMonth = 12;
        currentYear -= 1;
      }
    });
    _getPeakflowHistory(currentMonth, currentYear);
  }

  void getPrevMonthAsthma() {
    setState(() {
      asthmacontroltestReportTableData.clear();
      asthmacontroltestReportChartData.clear();

      currentMonth -= 1;
      if (currentMonth == 0) {
        currentMonth = 12;
        currentYear -= 1;
      }
    });
    _getACTHistory(currentMonth, currentYear);
  }

  void getPrevMonthSteroid() {
    setState(() {
      steroidReportChartData.clear();
      steroidReportTableData.clear();

      currentMonth -= 1;
      if (currentMonth == 0) {
        currentMonth = 12;
        currentYear -= 1;
      }
    });
    _getSteroidHistory(currentMonth, currentYear);
  }

  void getPrevMonthDiurinal() {
    setState(() {
      diurinalReportChartDataxaxis.clear();
      diurinalReportChartDatayaxis.clear();
      diurinalReportTableData.clear();

      currentMonth -= 1;
      if (currentMonth == 0) {
        currentMonth = 12;
        currentYear -= 1;
      }
    });
    _getDiurinalHistory(currentMonth, currentYear);
  }

  void getPrevMonthFitnessStress() {
    setState(() {
      fitnessstressReportChartData.clear();
      fitnessstressReportTableData.clear();

      currentMonth -= 1;
      if (currentMonth == 0) {
        currentMonth = 12;
        currentYear -= 1;
      }
    });
    _getFitnessStressHistory(currentMonth, currentYear);
  }

  void getPrevMonthInhaler() {
    setState(() {
      inhalerReportChartData.clear();
      inhalerReportTableData.clear();
      currentMonth -= 1;
      if (currentMonth == 0) {
        currentMonth = 12;
        currentYear -= 1;
      }
    });
    _getInhalerHistory(currentMonth, currentYear);
  }

//next month
  void getNextMonthPeakflow() {
    setState(() {
      peakflowReportChartData.clear();
      peakflowReportTableData.clear();

      currentMonth += 1;
      if (currentMonth == 13) {
        currentMonth = 1;
        currentYear += 1;
      }
    });
    _getPeakflowHistory(currentMonth, currentYear);
  }

  void getNextMonthInhaler() {
    setState(() {
      inhalerReportTableData.clear();
      inhalerReportChartData.clear();
      currentMonth += 1;
      if (currentMonth == 13) {
        currentMonth = 1;
        currentYear += 1;
      }
    });
    _getInhalerHistory(currentMonth, currentYear);
  }

  void getNextMonthAsthma() {
    setState(() {
      asthmacontroltestReportTableData.clear();
      asthmacontroltestReportChartData.clear();
      currentMonth += 1;
      if (currentMonth == 13) {
        currentMonth = 1;
        currentYear += 1;
      }
      asthmacontroltestReportData['asthamcontroltestRecordedOn'];
    });
    _getACTHistory(currentMonth, currentYear);
  }

  void getNextMonthSteroid() {
    setState(() {
      steroidReportChartData.clear();
      steroidReportTableData.clear();
      currentMonth += 1;
      if (currentMonth == 13) {
        currentMonth = 1;
        currentYear += 1;
      }
      steroidReportData['steroiddoseRecordedOn'];
    });
    _getSteroidHistory(currentMonth, currentYear);
  }

  void getNextMonthDiurinal() {
    setState(() {
      diurinalReportChartDataxaxis.clear();
      diurinalReportChartDatayaxis.clear();
      diurinalReportTableData.clear();

      currentMonth += 1;
      if (currentMonth == 13) {
        currentMonth = 1;
        currentYear += 1;
      }
      steroidReportData['steroiddoseRecordedOn'];
    });
    _getDiurinalHistory(currentMonth, currentYear);
  }

  void getNextMonthFitness() {
    setState(() {
      fitnessstressReportTableData.clear();
      fitnessstressReportChartData.clear();

      currentMonth += 1;
      if (currentMonth == 13) {
        currentMonth = 1;
        currentYear += 1;
      }
    });
    _getFitnessStressHistory(currentMonth, currentYear);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 350,
            width: 300,
            child: SfDateRangePicker(
              view: DateRangePickerView.year, // Initial view to show months
              selectionMode: DateRangePickerSelectionMode.single,
              minDate: DateTime(2000),
              maxDate: DateTime(2100),
              showNavigationArrow: true, // Show arrows for navigation
              headerStyle: DateRangePickerHeaderStyle(
                backgroundColor: Colors.blueAccent,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              initialSelectedDate: _selectedStartDate,

              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: TextStyle(fontSize: 14, color: Colors.transparent),
              ),
              allowViewNavigation: false,
              onViewChanged: (DateRangePickerViewChangedArgs args) {
                logger.d('Current View: ${args.visibleDateRange.startDate}');
              },
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is DateTime) {
                  setState(() {
                    _selectedStartDate = args.value as DateTime;
                  });
                  logger.d(
                    'Selected Month: ${_selectedStartDate?.month}, Selected Year: ${_selectedStartDate?.year}',
                  );
                }
                Navigator.pop(context); // Close the dialog after selection
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectEndDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 350,
            width: 300,
            child: SfDateRangePicker(
              view: DateRangePickerView.year, // Initial view to show months
              selectionMode: DateRangePickerSelectionMode.single,
              minDate: DateTime(2000),
              maxDate: DateTime(2100),
              showNavigationArrow: true, // Show arrows for navigation
              headerStyle: DateRangePickerHeaderStyle(
                backgroundColor: Colors.blueAccent,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              initialSelectedDate: _selectedEndDate,

              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: TextStyle(fontSize: 14, color: Colors.transparent),
              ),
              allowViewNavigation: false,
              onViewChanged: (DateRangePickerViewChangedArgs args) {
                logger.d('Current View: ${args.visibleDateRange.startDate}');
              },
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is DateTime) {
                  setState(() {
                    _selectedEndDate = args.value as DateTime;
                  });
                  logger.d(
                    'Selected Month: ${_selectedEndDate?.month}, Selected Year: ${_selectedEndDate?.year}',
                  );
                }
                Navigator.pop(context); // Close the dialog after selection
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: hasData == false // Check if the data is available
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: EdgeInsets.all(screenSize.width * 0.02),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Container
                      SizedBox(
                        width: screenSize.width * 0.16,
                        height: screenSize.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${userData['firstName']} ${userData['lastName']}', // Display the user Name
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                letterSpacing: -.4,
                                height: 0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Middle Container
                      SizedBox(
                        width: screenSize.width * 0.64,
                        height: screenSize.height,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ButtonTabWidget(
                                    label: 'Peakflow Baseline',
                                    color: peakflow
                                        ? const Color(0xFF27AE60)
                                        : const Color(0xFFE9F7EF),
                                    textColor: peakflow
                                        ? const Color(0xFFFFFFFF)
                                        : const Color(0xFF27AE60),
                                    value: userData['baseLineScore'],
                                    onTap: () {
                                      _getPeakflowHistory(
                                          currentMonth, currentYear);
                                      setState(() {
                                        peakflow = true;
                                        asthma = false;
                                        steroid = false;
                                        inhaler = false;
                                        diurinal = false;
                                        fitnessStress = false;
                                      });
                                    },
                                    screenRatio:
                                        screenSize.width / screenSize.height,
                                  ),
                                  ButtonTabWidget(
                                    label: 'Asthma Control Test',
                                    color: asthma
                                        ? const Color(0xFFFD4646)
                                        : const Color(0xFFFFECEC),
                                    textColor: asthma
                                        ? const Color(0xFFFFFFFF)
                                        : const Color(0xFFFD4646),
                                    value: userData['actScore'],
                                    onTap: () {
                                      _getACTHistory(currentMonth, currentYear);
                                      setState(() {
                                        peakflow = false;
                                        asthma = true;
                                        steroid = false;
                                        inhaler = false;
                                        diurinal = false;
                                        fitnessStress = false;
                                      });
                                    },
                                    screenRatio:
                                        screenSize.width / screenSize.height,
                                  ),
                                  ButtonTabWidget(
                                    label: 'Steroid Dose',
                                    color: steroid
                                        ? const Color(0xFFFF8500)
                                        : const Color(0xFFFFF3E5),
                                    textColor: steroid
                                        ? const Color(0xFFFFFFFF)
                                        : const Color(0xFFFF8500),
                                    value: userData['steroidDosage'],
                                    onTap: () {
                                      _getSteroidHistory(
                                          currentMonth, currentYear);
                                      setState(() {
                                        peakflow = false;
                                        asthma = false;
                                        steroid = true;
                                        inhaler = false;
                                        diurinal = false;
                                        fitnessStress = false;
                                      });
                                    },
                                    screenRatio:
                                        screenSize.width / screenSize.height,
                                  ),
                                ],
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ButtonTabWidget(
                                    label: 'QIoT Inhaler',
                                    color: const Color(0xFFE9F7EF),
                                    textColor: const Color(0xFF27AE60),
                                    value: userData['inhaler'],
                                    inhaler: true,
                                    onTap: () {
                                      // _getPeakflowHistory(
                                      //     currentMonth, currentYear);
                                      _getInhalerHistory(
                                          currentMonth, currentYear);
                                      setState(() {
                                        peakflow = false;
                                        asthma = false;
                                        steroid = false;
                                        inhaler = true;
                                        diurinal = false;
                                        fitnessStress = false;
                                      });
                                    },
                                    screenRatio:
                                        screenSize.width / screenSize.height,
                                  ),
                                  ButtonTabWidget(
                                    label: 'Diurinal Variation',
                                    // color: diurinal
                                    //     ? const Color(0xFFFD4646)
                                    //     : const Color(0xFFFFECEC),
                                    // textColor: diurinal
                                    //     ? const Color(0xFFFFFFFF)
                                    //     : const Color(0xFFFD4646),
                                    // value: userData['steroidDosage'],
                                    value: '10',
                                    inhaler: true,
                                    onTap: () {
                                      _getDiurinalHistory(
                                          currentMonth, currentYear);
                                      setState(() {
                                        peakflow = false;
                                        asthma = false;
                                        steroid = false;
                                        inhaler = false;
                                        diurinal = true;
                                        fitnessStress = false;
                                      });
                                    },
                                    screenRatio:
                                        screenSize.width / screenSize.height,
                                  ),
                                  ButtonTabWidget(
                                    label: 'Fitness & Stress',
                                    color: const Color(0xFF27AE60),
                                    textColor: const Color(0xFFFFFFFF),
                                    value:
                                        userData['steroidDosage'] ?? 'No Data',

                                    // inhaler: true,
                                    onTap: () {
                                      _getFitnessStressHistory(
                                          currentMonth, currentYear);

                                      setState(() {
                                        // showDrainageRate = true;
                                        // showRespiratoryRate = false;
                                        peakflow = false;
                                        asthma = false;
                                        steroid = false;
                                        inhaler = false;
                                        diurinal = false;
                                        fitnessStress = true;
                                      });
                                    },
                                    screenRatio:
                                        screenSize.width / screenSize.height,
                                  ),
                                ],
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              // Peakflow Recorded On
                              Container(
                                width: screenSize.width,
                                height: screenSize.height * 0.06,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF0D8EF8).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          // width: screenSize.width * 0.14,
                                          height: 46,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: peakflow
                                              ? dataRecordText(
                                                  text: 'Peakflow Recorded on:',
                                                )
                                              : steroid
                                                  ? dataRecordText(
                                                      text:
                                                          'Steroid Recorded on:',
                                                    )
                                                  : inhaler
                                                      ? dataRecordText(
                                                          text:
                                                              'Inhaler Recorded on:',
                                                        )
                                                      : diurinal
                                                          ? dataRecordText(
                                                              text:
                                                                  'Diurinal Recorded on:')
                                                          : asthma
                                                              ? dataRecordText(
                                                                  text:
                                                                      'Asthma Recorded on:',
                                                                )
                                                              : fitnessStress
                                                                  ? dataRecordText(
                                                                      text:
                                                                          'F and S Recorded on:',
                                                                    )
                                                                  : Text(
                                                                      'data'),
                                        ),
                                        Container(
                                          // width: screenSize.width * 0.14,
                                          height: 46,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              peakflow
                                                  ? peakflowReportData[
                                                          'peakflowRecordedOn'] ??
                                                      'No data'
                                                  : steroid
                                                      ? steroidReportData[
                                                              'steroiddoseRecordedOn'] ??
                                                          'No data'
                                                      : inhaler
                                                          ? inhalerReportData[
                                                                  'inhalerRecordedOn'] ??
                                                              "No data"
                                                          : asthma
                                                              ? asthmacontroltestReportData[
                                                                      'asthamcontroltestRecordedOn'] ??
                                                                  "No data"
                                                              : fitnessStress
                                                                  ? fitnessstressReportData[
                                                                          'fitnessandstressRecordedOn'] ??
                                                                      "No data"
                                                                  : "No data",
                                              textAlign: TextAlign.right,
                                              style: GoogleFonts.manrope(
                                                fontSize: 14,
                                                letterSpacing: -.2,
                                                height: 0,
                                                color: Color(0xFF004283),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: screenSize.width * 0.02,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Download report:',
                                          // style: TextStyle(
                                          //     fontSize: 14,
                                          //     fontWeight: FontWeight.bold,
                                          //     color: WebColors.primaryBlue),
                                          style: GoogleFonts.manrope(
                                            fontSize: 14,
                                            letterSpacing: -.2,
                                            height: 0,
                                            color: Color(0xFF004283),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenSize.width * 0.01,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _selectStartDate(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Start Date: ',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 14,
                                                  letterSpacing: -.2,
                                                  height: 0,
                                                  color: Color(0xFF004283),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                _selectedStartDate != null
                                                    ? '${_selectedStartDate?.month} / ${_selectedStartDate?.year}'
                                                    : 'N/A',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 14,
                                                  letterSpacing: -.2,
                                                  height: 0,
                                                  color: Color(0xFF004283),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _selectEndDate(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'End Date: ',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 14,
                                                  letterSpacing: -.2,
                                                  height: 0,
                                                  color: Color(0xFF004283),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                _selectedStartDate != null
                                                    ? '${_selectedEndDate?.month} / ${_selectedEndDate?.year}'
                                                    : 'N/A',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 14,
                                                  letterSpacing: -.2,
                                                  height: 0,
                                                  color: Color(0xFF004283),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                downloadReport = true;
                                              });
                                              peakflow
                                                  ? _getPeakflowHistoryReport()
                                                  : asthma
                                                      ? _getasthmaHistoryReport()
                                                      : steroid
                                                          ? _getSteroidHistoryReport()
                                                          :diurinal?
                                                           _getDiurinalHistoryReport(): 
                                                          
                                                          inhaler
                                                              ?
                                                              // print('calling inhaler')
                                                              _getInhalerHistoryReport()
                                                              : asthma
                                                                  ? ()
                                                                  : fitnessStress
                                                                      ? _getFitnessStressHistoryReport()
                                                                      : ();
                                            },
                                            icon: Icon(
                                              Icons.download,
                                              color: WebColors.primaryBlue,
                                              size: 24,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.01),
                              // Month Selector
                              SizedBox(
                                width: screenSize.width,
                                height: screenSize.height * 0.06,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Peakflow Record
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            peakflow
                                                ? Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Peakflow Record:',
                                                      textAlign: TextAlign.left,
                                                      style:
                                                          GoogleFonts.manrope(
                                                        fontSize: 16,
                                                        letterSpacing: -.2,
                                                        height: 0,
                                                        color:
                                                            Color(0xFF004283),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  )
                                                : steroid
                                                    ? Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Steroid  Record:',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: GoogleFonts
                                                              .manrope(
                                                            fontSize: 16,
                                                            letterSpacing: -.2,
                                                            height: 0,
                                                            color: Color(
                                                                0xFF004283),
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                      )
                                                    : inhaler
                                                        ? Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Inhaler Record:',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: GoogleFonts
                                                                  .manrope(
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    -.2,
                                                                height: 0,
                                                                color: Color(
                                                                    0xFF004283),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          )
                                                        : diurinal
                                                            ? Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  'Diurinal Record:',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: GoogleFonts
                                                                      .manrope(
                                                                    fontSize:
                                                                        16,
                                                                    letterSpacing:
                                                                        -.2,
                                                                    height: 0,
                                                                    color: Color(
                                                                        0xFF004283),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                  ),
                                                                ),
                                                              )
                                                            : asthma
                                                                ? Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      'Ashtma Record:',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: GoogleFonts
                                                                          .manrope(
                                                                        fontSize:
                                                                            16,
                                                                        letterSpacing:
                                                                            -.2,
                                                                        height:
                                                                            0,
                                                                        color: Color(
                                                                            0xFF004283),
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : fitnessStress
                                                                    ? Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Text(
                                                                          'Fitness and Stress Record:',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              GoogleFonts.manrope(
                                                                            fontSize:
                                                                                16,
                                                                            letterSpacing:
                                                                                -.2,
                                                                            height:
                                                                                0,
                                                                            color:
                                                                                Color(0xFF004283),
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Text(
                                                                          'Peakflow Record:',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              GoogleFonts.manrope(
                                                                            fontSize:
                                                                                16,
                                                                            letterSpacing:
                                                                                -.2,
                                                                            height:
                                                                                0,
                                                                            color:
                                                                                Color(0xFF004283),
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                          ),
                                                                        ),
                                                                      ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Month Selector
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Left Arrow
                                                GestureDetector(
                                                  onTap: () {
                                                    peakflow
                                                        ? getPrevMonthPeakflow()
                                                        : steroid
                                                            ? getPrevMonthSteroid()
                                                            : inhaler
                                                                ? getPrevMonthInhaler()
                                                                : diurinal
                                                                    ? getPrevMonthDiurinal()
                                                                    : asthma
                                                                        ? getPrevMonthAsthma()
                                                                        : fitnessStress
                                                                            ? getPrevMonthFitnessStress()
                                                                            : ();
                                                  },
                                                  child: Container(
                                                    width: 36,
                                                    height: 52,
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        top: BorderSide(
                                                          color: Color(
                                                                  0xFF004283)
                                                              .withOpacity(0.4),
                                                          width: 2,
                                                        ),
                                                        left: BorderSide(
                                                          color: Color(
                                                                  0xFF004283)
                                                              .withOpacity(0.4),
                                                          width: 2,
                                                        ),
                                                        right: BorderSide(
                                                          color: Color(
                                                                  0xFF004283)
                                                              .withOpacity(0.4),
                                                          width: 2,
                                                        ),
                                                        bottom: BorderSide(
                                                          color: Color(
                                                                  0xFF004283)
                                                              .withOpacity(0.4),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(8),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                      ),
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        size: 40,
                                                        Icons
                                                            .arrow_left_rounded,
                                                        color:
                                                            Color(0xFF004283),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Container for the month
                                                Container(
                                                  width: 80,
                                                  height: 52,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                        color: const Color(
                                                                0xFF004283)
                                                            .withOpacity(0.4),
                                                        width: 2,
                                                      ),
                                                      bottom: BorderSide(
                                                        color: const Color(
                                                                0xFF004283)
                                                            .withOpacity(0.4),
                                                        width: 2,
                                                      ),
                                                    ),
                                                    shape: BoxShape.rectangle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${monthAbbreviations[currentMonth - 1]} - $currentYear',
                                                      style:
                                                          GoogleFonts.manrope(
                                                        fontSize: 14,
                                                        letterSpacing: -.2,
                                                        height: 0,
                                                        color:
                                                            Color(0xFF004283),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Right Arrow
                                                GestureDetector(
                                                  onTap: () {
                                                    peakflow
                                                        ? getNextMonthPeakflow()
                                                        : steroid
                                                            ? getNextMonthSteroid()
                                                            : inhaler
                                                                ? getNextMonthInhaler()
                                                                : diurinal
                                                                    ? getNextMonthDiurinal()
                                                                    : asthma
                                                                        ? getNextMonthAsthma()
                                                                        : fitnessStress
                                                                            ? getNextMonthFitness()
                                                                            : ();
                                                  },
                                                  child: Container(
                                                    width: 36,
                                                    height: 52,
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        top: BorderSide(
                                                          color: const Color(
                                                                  0xFF004283)
                                                              .withOpacity(0.4),
                                                          width: 2,
                                                        ),
                                                        left: BorderSide(
                                                          color: const Color(
                                                                  0xFF004283)
                                                              .withOpacity(0.4),
                                                          width: 2,
                                                        ),
                                                        right: BorderSide(
                                                          color: const Color(
                                                                  0xFF004283)
                                                              .withOpacity(0.4),
                                                          width: 2,
                                                        ),
                                                        bottom: BorderSide(
                                                          color: const Color(
                                                                  0xFF004283)
                                                              .withOpacity(0.4),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(8),
                                                        bottomRight:
                                                            Radius.circular(8),
                                                      ),
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        size: 40,
                                                        Icons
                                                            .arrow_right_rounded,
                                                        color:
                                                            Color(0xFF004283),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              peakflow
                                  ? // Peakflow Chart
                                  SizedBox(
                                      width: screenSize.width,
                                      height: screenSize.height * 0.4,
                                      child: ReloadableChart(
                                        baseLineScore:
                                            peakflowReportData['baseLineScore']
                                                .toString(),
                                        peakflowReportChartData:
                                            peakflowReportChartData,
                                        hasData:
                                            peakflowReportChartData.isNotEmpty
                                                ? true
                                                : false,
                                      ),
                                    )
                                  : steroid
                                      ? SizedBox(
                                          width: screenSize.width,
                                          height: screenSize.height * 0.4,
                                          child: SteroidReloadableChart(
                                            steroidReportChartData:
                                                steroidReportChartData,
                                            hasData: steroidReportChartData
                                                    .isNotEmpty
                                                ? true
                                                : false,
                                          ),
                                        )
                                      : asthma
                                          ? // Asthma Control Test Chart
                                          SizedBox(
                                              width: screenSize.width,
                                              height: screenSize.height * 0.4,
                                              child: AsthmaReloadableChart(
                                                asthmaControlTestReportChartData:
                                                    asthmacontroltestReportChartData,
                                                hasData:
                                                    asthmacontroltestReportChartData
                                                            .isNotEmpty
                                                        ? true
                                                        : false,
                                              ),
                                            )
                                          : inhaler
                                              ? SizedBox(
                                                  width: screenSize.width,
                                                  height:
                                                      screenSize.height * 0.4,
                                                  child: InhalerReloadableChart(
                                                    salbutomalDosage:
                                                        inhalerReportData[
                                                                'salbutomalDosage']
                                                            .toString(),
                                                    // peakflowReportChartData:
                                                    //     peakflowReportChartData,
                                                    inhalerReportChartData:
                                                        inhalerReportChartData,
                                                    // hasData: peakflowReportChartData
                                                    //         .isNotEmpty
                                                    hasData:
                                                        inhalerReportChartData
                                                                .isNotEmpty
                                                            ? true
                                                            : false,
                                                  ),
                                                )
                                              : diurinal
                                                  ? SizedBox(
                                                      width: screenSize.width,
                                                      height:
                                                          screenSize.height *
                                                              0.4,
                                                      child:
                                                          DiurinalReloadableChart(
                                                        // salbutomalDosage:
                                                        //     inhalerReportData[
                                                        //             'salbutomalDosage']
                                                        //         .toString(),
                                                        // peakflowReportChartData:
                                                        //     peakflowReportChartData,
                                                        diruinalxReportChartData:
                                                            diurinalReportChartDataxaxis,
                                                        diruinalyReportChartData:
                                                            diurinalReportChartDatayaxis,

                                                        // inhalerReportChartData:
                                                        //     inhalerReportChartData,

                                                        hasData:
                                                            diurinalReportChartDataxaxis
                                                                    // inhalerReportChartData
                                                                    .isNotEmpty
                                                                ? true
                                                                : false,
                                                      ),
                                                    )
                                                  : fitnessStress
                                                      ? SizedBox(
                                                          width:
                                                              screenSize.width,
                                                          height: screenSize
                                                                  .height *
                                                              0.4,
                                                          child: FitnessStressReloadableChart(
                                                              fitnessstressReloadableChartData:
                                                                  fitnessstressReportChartData,
                                                              hasData:
                                                                  fitnessstressReportChartData
                                                                          .isNotEmpty
                                                                      ? true
                                                                      : false),
                                                        )
                                                      : SizedBox(
                                                          width:
                                                              screenSize.width,
                                                          height: screenSize
                                                                  .height *
                                                              0.4,
                                                          child:
                                                              ReloadableChart(
                                                            baseLineScore:
                                                                peakflowReportData[
                                                                        'baseLineScore']
                                                                    .toString(),
                                                            peakflowReportChartData:
                                                                peakflowReportChartData,
                                                            hasData:
                                                                peakflowReportChartData
                                                                        .isNotEmpty
                                                                    ? true
                                                                    : false,
                                                          ),
                                                        ),
                              // Peakflow Legends Zone
                              SizedBox(
                                height: 30,
                              ),

                              peakflow
                                  ? peakflowReportChartData.isNotEmpty
                                      ? PeakflowLegendsZone(
                                          screenRatio: screenSize.width /
                                              screenSize.height,
                                          screenSize: screenSize,
                                        )
                                      : const SizedBox.shrink()
                                  : asthma
                                      ? asthmacontroltestReportTableData
                                              .isNotEmpty
                                          ? ACTLegendsZone(
                                              screenRatio: screenSize.width /
                                                  screenSize.height,
                                              screenSize: screenSize,
                                            )
                                          : const SizedBox.shrink()
                                      : inhaler
                                          ? inhalerReportChartData.isNotEmpty
                                              ? InhalerLegendsZone(
                                                  // screenRatio:
                                                  //     screenSize.width /
                                                  //         screenSize.height,
                                                  // screenSize: screenSize,
                                                  )
                                              : const SizedBox.shrink()
                                          : SizedBox(
                                              height: 50,
                                            ),

                              peakflow
                                  ? peakflowReportChartData.isNotEmpty
                                      ? SizedBox(
                                          key: ValueKey(currentMonth),
                                          width: screenSize.width,
                                          child: PeakflowReportTable(
                                            peakflowReportTableData:
                                                peakflowReportTableData,
                                          ),
                                        )
                                      : const SizedBox.shrink()
                                  : diurinal
                                      ? diurinalReportTableData.isNotEmpty
                                          ? SizedBox(
                                              key: ValueKey(currentMonth),
                                              width: screenSize.width,
                                              child: DiurinalReportTable(
                                                diurinalReportTableData:
                                                    diurinalReportTableData,
                                              ),
                                            )
                                          : const SizedBox.shrink()
                                      : steroid
                                          ? steroidReportTableData.isNotEmpty
                                              ? SizedBox(
                                                  key: ValueKey(currentMonth),
                                                  width: screenSize.width,
                                                  child: SteroidReportTable(
                                                    steroidReportTableData:
                                                        steroidReportTableData,
                                                  ),
                                                )
                                              : SizedBox.shrink()
                                          : asthma
                                              ? asthmacontroltestReportTableData
                                                      .isNotEmpty
                                                  ? SizedBox(
                                                      key: ValueKey(
                                                          currentMonth),
                                                      width: screenSize.width,
                                                      child:
                                                          AsthmaControlTestReportTable(
                                                        asthmacontroltestReportTableData:
                                                            asthmacontroltestReportTableData,
                                                      ),
                                                    )
                                                  : const SizedBox.shrink()
                                              : inhaler
                                                  ? inhalerReportChartData
                                                          .isNotEmpty
                                                      ? SizedBox(
                                                          key: ValueKey(
                                                              currentMonth),
                                                          width:
                                                              screenSize.width,
                                                          // child: PeakflowReportTable(
                                                          //   peakflowReportTableData:
                                                          //       peakflowReportTableData,
                                                          // ),
                                                          child: InhalerReportTable(
                                                              salbutomalDosage:
                                                                  inhalerReportData[
                                                                      'salbutomalDosage'],
                                                              inhalerReportTableData:
                                                                  inhalerReportTableData),
                                                        )
                                                      : const SizedBox.shrink()
                                                  : fitnessStress
                                                      ? fitnessstressReportTableData
                                                              .isNotEmpty
                                                          ? SizedBox(
                                                              key: ValueKey(
                                                                  currentMonth),
                                                              width: screenSize
                                                                  .width,
                                                              // child: PeakflowReportTable(
                                                              //   peakflowReportTableData:
                                                              //       peakflowReportTableData,
                                                              // ),
                                                              child: FitnessStressReportTable(
                                                                  fitnessstressReportTableData:
                                                                      fitnessstressReportTableData),
                                                            )
                                                          : const SizedBox
                                                              .shrink()
                                                      : SizedBox.shrink()
                            ],
                          ),
                        ),
                      ),
                      // Left Container
                      SizedBox(
                        width: screenSize.width * 0.16,
                        height: screenSize.height,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class dataRecordText extends StatelessWidget {
  const dataRecordText({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        textAlign: TextAlign.left,
        // style: TextStyle(
        //   color: Color(0xFF004283),
        //   fontSize: 14,
        //   fontWeight: FontWeight.bold,
        //   fontFamily: 'Roboto',
        // ),
        style: GoogleFonts.manrope(
          fontSize: 14,
          letterSpacing: -.2,
          height: 0,
          color: Color(0xFF004283),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
