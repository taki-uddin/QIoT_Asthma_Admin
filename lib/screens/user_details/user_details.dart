import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qiot_admin/constants/month_abbreviations.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_table_model.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_chart_model.dart';
import 'package:qiot_admin/models/inhaler_report_model/inhaler_table_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_table_model.dart';
import 'package:qiot_admin/helpers/pdf.dart/pdfgeneration.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_widgets/act_legends_zone.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_widgets/asthma_control_test_report_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_widgets/asthma_reloadable_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/button_tab_widget.dart';
import 'package:qiot_admin/screens/user_details/widgets/inhaler_widgets/inhaler_legends_zone.dart';
import 'package:qiot_admin/screens/user_details/widgets/inhaler_widgets/inhaler_report_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/inhaler_widgets/reloadable_chart_inhaler.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_widgets/peakflow_legends_zone.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_widgets/peakflow_report_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_widgets/reloadable_chart.dart';
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

  List<dynamic> peakflowReportHistory = [];
  Map<String, dynamic> peakflowReportData = {};
  List<PeakflowReportChartModel> peakflowReportChartData = [];
  List<PeakflowReportTableModel> peakflowReportTableData = [];

  //for inhaler
  List<dynamic> inhalerReportHistory = [];
  Map<String, dynamic> inhalerReportData = {};
  List<InhalerReportChartModel> inhalerReportChartData = [];
  List<InhalerReportTableModel> inhalerReportTableData = [];

  Map<String, dynamic> asthmacontroltestReportData = {};
  List<AsthmaControlTestReportChartModel> asthmacontroltestReportChartData = [];
  List<AsthmaControlTestReportTableModel> asthmacontroltestReportTableData = [];

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
      return pw.TableHelper.fromTextArray(
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
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
    });
    _getACTHistory(currentMonth, currentYear);
  }

  // Future<void> _selectStartDate(BuildContext context) async {
  //   DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(), // Default selection
  //     firstDate: DateTime(2000), // Minimum date
  //     lastDate: DateTime(2100), // Maximum date
  //   );

  //   // If the user selected a date, update the state
  //   if (pickedDate != null && pickedDate != _selectedStartDate) {
  //     setState(() {
  //       _selectedStartDate = pickedDate;
  //     });
  //     logger.d('${_selectedStartDate?.month} ${_selectedStartDate?.year}');
  //   }
  // }
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

  // Future<void> _selectEndDate(BuildContext context) async {
  //   DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(), // Default selection
  //     firstDate: DateTime(2000), // Minimum date
  //     lastDate: DateTime(2100), // Maximum date
  //   );

  //   // If the user selected a date, update the state
  //   if (pickedDate != null && pickedDate != _selectedEndDate) {
  //     setState(() {
  //       _selectedEndDate = pickedDate;
  //     });
  //     logger.d('${_selectedEndDate?.month} ${_selectedEndDate?.year}');
  //   }
  // }

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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
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
                                      _getPeakflowHistory(
                                          currentMonth, currentYear);
                                      setState(() {
                                        peakflow = false;
                                        asthma = false;
                                        steroid = true;
                                        inhaler = false;
                                        diurinal = false;
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
                                      });
                                    },
                                    screenRatio:
                                        screenSize.width / screenSize.height,
                                  ),
                                  ButtonTabWidget(
                                    label: 'Diurinal Variation',
                                    color: diurinal
                                        ? const Color(0xFFFD4646)
                                        : const Color(0xFFFFECEC),
                                    textColor: diurinal
                                        ? const Color(0xFFFFFFFF)
                                        : const Color(0xFFFD4646),
                                    value: userData['steroidDosage'],
                                    inhaler: true,
                                    onTap: () {
                                      _getPeakflowHistory(
                                          currentMonth, currentYear);
                                      setState(() {
                                        peakflow = false;
                                        asthma = false;
                                        steroid = false;
                                        inhaler = false;
                                        diurinal = true;
                                      });
                                    },
                                    screenRatio:
                                        screenSize.width / screenSize.height,
                                  ),
                                  ButtonTabWidget(
                                    label: 'Fitness & Stress',
                                    color: const Color(0xFF27AE60),
                                    textColor: const Color(0xFFFFFFFF),
                                    value: userData['steroidDosage'],
                                    inhaler: true,
                                    onTap: () {
                                      _getPeakflowHistory(
                                          currentMonth, currentYear);
                                      setState(() {
                                        // showDrainageRate = true;
                                        // showRespiratoryRate = false;
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
                                              : inhaler
                                                  ? dataRecordText(
                                                      text:
                                                          'Inhaler Recorded on:',
                                                    )
                                                  : asthma
                                                      ? dataRecordText(
                                                          text:
                                                              'Asthma Recorded on:',
                                                        )
                                                      : Text('data'),
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
                                                          'peakflowRecordedOn']
                                                      .toString()
                                                  : inhaler
                                                      ? inhalerReportData[
                                                              'inhalerRecordedOn']
                                                          .toString()
                                                      : asthma
                                                          ? asthmacontroltestReportData[
                                                                  'asthamcontroltestRecordedOn']
                                                              .toString()
                                                          : peakflowReportData[
                                                                  'peakflowRecordedOn']
                                                              .toString(),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Color(0xFF004283),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Roboto',
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
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: WebColors.primaryBlue),
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
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: WebColors.primaryBlue,
                                                ),
                                              ),
                                              Text(
                                                _selectedStartDate != null
                                                    ? '${_selectedStartDate?.month} / ${_selectedStartDate?.year}'
                                                    : 'N/A',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: WebColors.primaryBlue,
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
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: WebColors.primaryBlue,
                                                ),
                                              ),
                                              Text(
                                                _selectedStartDate != null
                                                    ? '${_selectedEndDate?.month} / ${_selectedEndDate?.year}'
                                                    : 'N/A',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: WebColors.primaryBlue,
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
                                                  : inhaler
                                                      ?
                                                      // print('calling inhaler')
                                                      _getInhalerHistoryReport()
                                                      : asthma
                                                          ? ()
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
                                                ? const Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Peakflow Record:',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF004283),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Roboto',
                                                      ),
                                                    ),
                                                  )
                                                : inhaler
                                                    ? const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Inhaler Record:',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF004283),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Roboto',
                                                          ),
                                                        ),
                                                      )
                                                    : asthma
                                                        ? const Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Ashtma Record:',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF004283),
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Roboto',
                                                              ),
                                                            ),
                                                          )
                                                        : const Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Peakflow Record:',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF004283),
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Roboto',
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
                                                        : inhaler
                                                            ? getPrevMonthInhaler()
                                                            : asthma
                                                                ? getPrevMonthAsthma()
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
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF004283),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Roboto',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Right Arrow
                                                GestureDetector(
                                                  onTap: () {
                                                    peakflow
                                                        ? getNextMonthPeakflow()
                                                        : inhaler
                                                            ? getNextMonthInhaler()
                                                            : asthma
                                                                ? getNextMonthAsthma()
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
                                              height: screenSize.height * 0.4,
                                              child: InhalerReloadableChart(
                                                baseLineScore:
                                                    inhalerReportData[
                                                            'baseLineScore']
                                                        .toString(),
                                                // peakflowReportChartData:
                                                //     peakflowReportChartData,
                                                inhalerReportChartData:
                                                    inhalerReportChartData,
                                                // hasData: peakflowReportChartData
                                                //         .isNotEmpty
                                                hasData: inhalerReportChartData
                                                        .isNotEmpty
                                                    ? true
                                                    : false,
                                              ),
                                            )
                                          : SizedBox(
                                              width: screenSize.width,
                                              height: screenSize.height * 0.4,
                                              child: ReloadableChart(
                                                baseLineScore:
                                                    peakflowReportData[
                                                            'baseLineScore']
                                                        .toString(),
                                                peakflowReportChartData:
                                                    peakflowReportChartData,
                                                hasData: peakflowReportChartData
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
                                          : peakflowReportChartData.isNotEmpty
                                              ? PeakflowLegendsZone(
                                                  screenRatio:
                                                      screenSize.width /
                                                          screenSize.height,
                                                  screenSize: screenSize,
                                                )
                                              : const SizedBox.shrink(),

                              SizedBox(
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
                                  : asthma
                                      ? asthmacontroltestReportTableData
                                              .isNotEmpty
                                          ? SizedBox(
                                              key: ValueKey(currentMonth),
                                              width: screenSize.width,
                                              child:
                                                  AsthmaControlTestReportTable(
                                                asthmacontroltestReportTableData:
                                                    asthmacontroltestReportTableData,
                                              ),
                                            )
                                          : const SizedBox.shrink()
                                      : inhaler
                                          ? inhalerReportChartData.isNotEmpty
                                              ? SizedBox(
                                                  key: ValueKey(currentMonth),
                                                  width: screenSize.width,
                                                  // child: PeakflowReportTable(
                                                  //   peakflowReportTableData:
                                                  //       peakflowReportTableData,
                                                  // ),
                                                  child: InhalerReportTable(
                                                      inhalerReportTableData:
                                                          inhalerReportTableData),
                                                )
                                              : const SizedBox.shrink()
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
        style: TextStyle(
          color: Color(0xFF004283),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
