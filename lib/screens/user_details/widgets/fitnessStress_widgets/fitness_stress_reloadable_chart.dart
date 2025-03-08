import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qiot_admin/models/fitness_stress_report_model/stress_fitness_report_model.dart';
import 'package:qiot_admin/screens/user_details/widgets/fitnessStress_widgets/fitness_report_chart.dart';
import 'package:qiot_admin/screens/user_details/widgets/fitnessStress_widgets/stress_reloadable_chart.dart';

// ignore: must_be_immutable
class FitnessStressReloadableChart extends StatefulWidget {
  List<FitnessStressReportModel> fitnessstressReloadableChartData;
  bool hasData;

  FitnessStressReloadableChart({
    super.key,
    required this.fitnessstressReloadableChartData,
    required this.hasData,
  });

  @override
  FitnessStressReloadableChartState createState() =>
      FitnessStressReloadableChartState();
}

class FitnessStressReloadableChartState
    extends State<FitnessStressReloadableChart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void reloadWidget(List<FitnessStressReportModel> newData, bool newHasData) {
    setState(() {
      widget.fitnessstressReloadableChartData = newData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('_tabcontroller value:${_tabController.index}');
    print('has data is:${widget.hasData}');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TabBar(
            overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
            controller: _tabController, // Link the TabController here
            tabAlignment: TabAlignment.start,
            dividerColor: const Color.fromARGB(0, 238, 25, 25),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Color(0xFF004283),
            isScrollable: true,
            labelPadding: EdgeInsets.only(left: 4, right: 4),
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.black)),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Fitness",
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          letterSpacing: -.4,
                          height: 0,
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                ),
              ),
              Tab(
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.black)),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Stress",
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          letterSpacing: -.4,
                          height: 0,
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                ),
              ),
            ],
            unselectedLabelStyle: TextStyle(
              color: Colors.transparent,
            ),
            unselectedLabelColor: Colors.grey,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController, // Link the TabController here
            children: [
              FitnessReportChart(
                fitnessstressReportChartData:
                    widget.fitnessstressReloadableChartData,
                hasData: widget.hasData,
              ),
              StressReportChart(
                fitnessstressReportChartData:
                    widget.fitnessstressReloadableChartData,
                hasData: widget.hasData,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),
        widget.hasData == true && _tabController.index == 0
            ? SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Row(
                              children: [
                                Text(
                                  '1: Low',
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.manrope(
                                    color: Color(0xFFFD4646),
                                    fontSize: 14,
                                    letterSpacing: -.4,
                                    height: 0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          Text(
                            '2: Medium',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.manrope(
                              color: Color(0xFFF2C94C),
                              fontSize: 14,
                              letterSpacing: -.4,
                              height: 0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          Text(
                            '3: High',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.manrope(
                              color: Color(0xFF27AE60),
                              fontSize: 14,
                              letterSpacing: -.4,
                              height: 0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : widget.hasData == true && _tabController.index == 1
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  Text(
                                    '1: Low',
                                    textAlign: TextAlign.left,

                                    style: GoogleFonts.manrope(
                                      color: Color(0xFF27AE60),
                                      fontSize: 14,
                                      letterSpacing: -.4,
                                      height: 0,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        child: Row(
                          children: [
                            Text(
                              '2: Medium',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.manrope(
                                color: Color(0xFFF2C94C),
                                fontSize: 14,
                                letterSpacing: -.4,
                                height: 0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        child: Row(
                          children: [
                            Text(
                              '3 :High',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.manrope(
                                color: Color(0xFFFD4646),
                                fontSize: 14,
                                letterSpacing: -.4,
                                height: 0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink()
      ],
    );
  }
}
