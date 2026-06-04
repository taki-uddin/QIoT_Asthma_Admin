import 'package:flutter/material.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';
import 'package:intl/intl.dart';

class FlaggedUsersScreen extends StatefulWidget {
  const FlaggedUsersScreen({Key? key}) : super(key: key);

  @override
  State<FlaggedUsersScreen> createState() => _FlaggedUsersScreenState();
}

class _FlaggedUsersScreenState extends State<FlaggedUsersScreen> {
  List<dynamic> flaggedUsers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFlaggedUsers();
  }

  Future<void> _loadFlaggedUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await DashboardUsersData.getFlaggedUsers();
      if (response != null && response['payload'] != null) {
        setState(() {
          flaggedUsers = List.from(response['payload']);
          isLoading = false;
        });
      } else {
        setState(() {
          flaggedUsers = [];
          isLoading = false;
        });
      }
    } catch (e) {
      logger.d('Error loading flagged users: $e');
      setState(() {
        errorMessage = 'Failed to load flagged users';
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return dateStr;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag_rounded,
                          color: Color(0xFFD32F2F), size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Flagged Patients (${flaggedUsers.length})',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004283),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _loadFlaggedUsers,
                    icon: const Icon(Icons.refresh, color: Color(0xFF004283)),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Users with 5+ consecutive low PEF readings (<80% baseline) or 5+ consecutive days of excessive inhaler use (>8 puffs/day)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Table header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF004283),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Patient',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Inhaler Serial',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Flag Type',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Flagged At',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('View',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF004283)),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFlaggedUsers,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004283),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (flaggedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green[400]),
            const SizedBox(height: 16),
            const Text(
              'No Flagged Patients',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004283)),
            ),
            const SizedBox(height: 8),
            Text(
              'All patients are within healthy reading thresholds.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: flaggedUsers.length,
      itemBuilder: (context, index) {
        final user = flaggedUsers[index];
        final bool isPefFlagged = user['isFlaggedPef'] == true;
        final bool isInhalerFlagged = user['isFlaggedInhaler'] == true;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/usersdetails/${user['_id']}',
              arguments: {'id': '${user['_id']}', 'returnTab': 1},
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD32F2F).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD32F2F).withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Patient name
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            const Color(0xFFD32F2F).withOpacity(0.1),
                        child: const Icon(Icons.person,
                            color: Color(0xFFD32F2F), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF004283),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (user['email'] != null)
                              Text(
                                user['email'],
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[500]),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Inhaler serial
                Expanded(
                  flex: 2,
                  child: Text(
                    user['inhaler'] ?? '—',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF004283)),
                  ),
                ),
                // Flag type
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      if (isPefFlagged)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🫁 Low PEF',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD32F2F),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      if (isInhalerFlagged)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8F00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '💨 High Inhaler',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFF8F00),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
                // Details
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      if (isPefFlagged)
                        Text(
                          '${user['consecutiveLowPefCount'] ?? 0} low readings',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 12, color: Color(0xFFD32F2F)),
                        ),
                      if (isInhalerFlagged)
                        Text(
                          '${user['consecutiveHighInhalerCount'] ?? 0} high-use days',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 12, color: Color(0xFFFF8F00)),
                        ),
                      if (isPefFlagged && user['baseLineScore'] != null)
                        Text(
                          'Baseline: ${user['baseLineScore']}',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                ),
                // Flagged at
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatDate(user['flaggedAt']),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                // View button
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/usersdetails/${user['_id']}',
                        arguments: {'id': '${user['_id']}', 'returnTab': 1},
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Color(0xFF004283)),
                    tooltip: 'View Details',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
