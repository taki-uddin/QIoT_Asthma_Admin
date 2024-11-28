import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qiot_admin/constants/month_abbreviations.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:qiot_admin/models/asthma_control_test_report_model/asthma_control_test_report_table_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:qiot_admin/models/peakflow_report_model/peakflow_report_table_model.dart';
import 'package:qiot_admin/screens/user_details/widgets/act_legends_zone.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_control_test_report_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/asthma_reloadable_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/button_tab_widget.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_legends_zone.dart';
import 'package:qiot_admin/screens/user_details/widgets/peakflow_report_table.dart';
import 'package:qiot_admin/screens/user_details/widgets/reloadable_chart.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
    });
    _getUserByIdData(userId);
    _getPeakflowHistory(currentMonth, currentYear);
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

  Future<void> _getPeakflowHistoryReport() async {
    logger.d('Current Month: $currentMonth, Current Year: $currentYear');
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
            await generatePDFReport(peakflowReportHistory);
          } else {
            logger.d('Failed to get user data');
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> generatePDFReport(List<dynamic> peakflowReportHistory) async {
    final pdf = pw.Document();
    logger.d(peakflowReportHistory);

    try {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text('Drainage Rate Report',
                    style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  context: context,
                  data: <List<dynamic>>[
                    <String>[
                      'Peakflow Observed On',
                      'Peakflow High',
                      'Peakflow Low',
                      'Peakflow Value',
                      'Daily Variation',
                      'Average Value',
                    ],
                    ...peakflowReportHistory.map(
                      (item) {
                        // Ensure item is not null and contains valid data
                        if (item != null) {
                          return [
                            item['createdAt']?.toString() ?? 'N/A',
                            item['highValue']?.toString() ?? 'N/A',
                            item['lowValue']?.toString() ?? 'N/A',
                            item['peakflowValue']?.toString() ?? 'N/A',
                            item['dailyVariation']?.toString() ?? 'N/A',
                            item['averageValue']?.toString() ?? 'N/A',
                          ];
                        } else {
                          return ['N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A'];
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
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

  void getPrevMonth() {
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

  void getNextMonth() {
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

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default selection
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2100), // Maximum date
    );

    // If the user selected a date, update the state
    if (pickedDate != null && pickedDate != _selectedStartDate) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
      logger.d('${_selectedStartDate?.month} ${_selectedStartDate?.year}');
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default selection
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2100), // Maximum date
    );

    // If the user selected a date, update the state
    if (pickedDate != null && pickedDate != _selectedEndDate) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
      logger.d('${_selectedEndDate?.month} ${_selectedEndDate?.year}');
    }
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
                                      _getPeakflowHistory(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenSize.width * 0.14,
                                          height: 46,
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  screenSize.width * 0.02),
                                          child: const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Peakflow recorded on:',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Color(0xFF004283),
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: screenSize.width * 0.14,
                                          height: 46,
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  screenSize.width * 0.02),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              peakflowReportData[
                                                      'peakflowRecordedOn']
                                                  .toString(),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Color(0xFF004283),
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
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
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: WebColors.primaryBlue),
                                        ),
                                        SizedBox(
                                          width: screenSize.width * 0.02,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                _selectStartDate(context);
                                              },
                                              child: Text(
                                                'Start MM/YYYY',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: WebColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _selectedStartDate != null
                                                  ? '${_selectedStartDate?.month} / ${_selectedStartDate?.year}'
                                                  : 'N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: WebColors.primaryBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                _selectEndDate(context);
                                              },
                                              child: Text(
                                                'End MM/YYYY',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: WebColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _selectedStartDate != null
                                                  ? '${_selectedEndDate?.month} / ${_selectedEndDate?.year}'
                                                  : 'N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: WebColors.primaryBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              downloadReport = true;
                                            });
                                            _getPeakflowHistoryReport();
                                          },
                                          icon: Icon(
                                            Icons.download,
                                            color: WebColors.primaryBlue,
                                            size: 18,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Peakflow Record
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Peakflow Record:',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color(0xFF004283),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                    // Month Selector
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Left Arrow
                                        GestureDetector(
                                          onTap: () {
                                            getPrevMonth();
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color: Color(0xFF004283)
                                                      .withOpacity(0.4),
                                                  width: 2,
                                                ),
                                                left: BorderSide(
                                                  color: Color(0xFF004283)
                                                      .withOpacity(0.4),
                                                  width: 2,
                                                ),
                                                right: BorderSide(
                                                  color: Color(0xFF004283)
                                                      .withOpacity(0.4),
                                                  width: 2,
                                                ),
                                                bottom: BorderSide(
                                                  color: Color(0xFF004283)
                                                      .withOpacity(0.4),
                                                  width: 2,
                                                ),
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                size: 40,
                                                Icons.arrow_left_rounded,
                                                color: Color(0xFF004283),
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
                                                color: const Color(0xFF004283)
                                                    .withOpacity(0.4),
                                                width: 2,
                                              ),
                                              bottom: BorderSide(
                                                color: const Color(0xFF004283)
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
                                                color: Color(0xFF004283),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Right Arrow
                                        GestureDetector(
                                          onTap: () {
                                            getNextMonth();
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color: const Color(0xFF004283)
                                                      .withOpacity(0.4),
                                                  width: 2,
                                                ),
                                                left: BorderSide(
                                                  color: const Color(0xFF004283)
                                                      .withOpacity(0.4),
                                                  width: 2,
                                                ),
                                                right: BorderSide(
                                                  color: const Color(0xFF004283)
                                                      .withOpacity(0.4),
                                                  width: 2,
                                                ),
                                                bottom: BorderSide(
                                                  color: const Color(0xFF004283)
                                                      .withOpacity(0.4),
                                                  width: 2,
                                                ),
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                size: 40,
                                                Icons.arrow_right_rounded,
                                                color: Color(0xFF004283),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
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
                                      : SizedBox(
                                          width: screenSize.width,
                                          height: screenSize.height * 0.4,
                                          child: ReloadableChart(
                                            baseLineScore: peakflowReportData[
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
                              peakflow
                                  ? peakflowReportChartData.isNotEmpty
                                      ? PeakflowLegendsZone(
                                          screenRatio: screenSize.width /
                                              screenSize.height,
                                          screenSize: screenSize,
                                        )
                                      : const SizedBox.shrink()
                                  : asthma
                                      ? peakflowReportChartData.isNotEmpty
                                          ? ACTLegendsZone(
                                              screenRatio: screenSize.width /
                                                  screenSize.height,
                                              screenSize: screenSize,
                                            )
                                          : const SizedBox.shrink()
                                      : peakflowReportChartData.isNotEmpty
                                          ? PeakflowLegendsZone(
                                              screenRatio: screenSize.width /
                                                  screenSize.height,
                                              screenSize: screenSize,
                                            )
                                          : const SizedBox.shrink(),

                              // Peakflow Table
                              peakflow && !asthma
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
                                  : asthmacontroltestReportTableData.isNotEmpty
                                      ? SizedBox(
                                          key: ValueKey(currentMonth),
                                          width: screenSize.width,
                                          child: AsthmaControlTestReportTable(
                                            asthmacontroltestReportTableData:
                                                asthmacontroltestReportTableData,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
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
