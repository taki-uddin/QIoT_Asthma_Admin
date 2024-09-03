import 'package:flutter/material.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';

class UserDetails extends StatefulWidget {
  final String userId; // Add a field to store the user ID
  const UserDetails({super.key, required this.userId});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  List<dynamic> userData = [];
  bool hasData = false;
  String userId = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      userId = widget.userId;
    });
    _getUserByIdData(widget.userId);
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
          print('Failed to get user data');
        }
      },
    );
  }

  Future<void> getPeakflowhistories(String userId) async {
    DashboardUsersData.getPeakflowhistories(
            userId,
            int.parse(DateTime.now().month.toString()),
            int.parse(DateTime.now().year.toString()))
        .then(
      (value) async {
        if (value != null) {
          print('value: ${value['payload']}');
        } else {
          print('Failed to get user data');
        }
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'User ID: ${userData[0]['_id']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              'User Name: ${userData[0]['firstName']} ${userData[0]['lastName']}', // Display the user ID
                              style: const TextStyle(
                                fontSize: 16,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    getPeakflowhistories(userData[0]['_id']);
                                  },
                                  child: Container(
                                    width: screenSize.width * 0.2,
                                    height: screenSize.height * 0.08,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.04),
                                          offset: Offset(0.0, 1.0),
                                          blurRadius: 2.0,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Peakflow Baseline: ', // Display the user ID
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        Container(
                                          width: screenSize.width * 0.04,
                                          height: screenSize.height * 0.04,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF27AE60),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.04),
                                                offset: Offset(0.0, 1.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${userData[0]['baseLineScore']}', // Display the user ID
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    getPeakflowhistories(userData[0]['_id']);
                                  },
                                  child: Container(
                                    width: screenSize.width * 0.2,
                                    height: screenSize.height * 0.08,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.04),
                                          offset: Offset(0.0, 1.0),
                                          blurRadius: 2.0,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Asthma Control Test: ', // Display the user ID
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        Container(
                                          width: screenSize.width * 0.04,
                                          height: screenSize.height * 0.04,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFD4646),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.04),
                                                offset: Offset(0.0, 1.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text(
                                              '25', // Display the user ID
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    getPeakflowhistories(userData[0]['_id']);
                                  },
                                  child: Container(
                                    width: screenSize.width * 0.2,
                                    height: screenSize.height * 0.08,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.04),
                                          offset: Offset(0.0, 1.0),
                                          blurRadius: 2.0,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Steroid Dose: ', // Display the user ID
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        Container(
                                          width: screenSize.width * 0.04,
                                          height: screenSize.height * 0.04,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF8500),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.04),
                                                offset: Offset(0.0, 1.0),
                                                blurRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${userData[0]['steroidDosage']}', // Display the user ID
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
