import 'package:flutter/material.dart';

class PeakflowLegendsZone extends StatelessWidget {
  final double screenRatio;
  final Size screenSize;

  const PeakflowLegendsZone({
    super.key,
    required this.screenRatio,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenSize.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildZoneRow(
                screenRatio: screenRatio,
                screenSize: screenSize,
                color: const Color(0xFF27AE60),
                label: 'Green Zone(80-100%)',
              ),
              _buildZoneRow(
                screenRatio: screenRatio,
                screenSize: screenSize,
                color: const Color(0xFFFF8500),
                label: 'Amber Zone(60-79%)',
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildZoneRow(
                screenRatio: screenRatio,
                screenSize: screenSize,
                color: const Color(0xFFFD4646),
                label: 'Red Zone - Urgent(50-59%)',
              ),
              _buildZoneRow(
                screenRatio: screenRatio,
                screenSize: screenSize,
                color: const Color(0xFFD10000),
                label: 'Red Zone - Emergency(<50%)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneRow({
    required double screenRatio,
    required Size screenSize,
    required Color color,
    required String label,
  }) {
    return SizedBox(
      width: screenSize.width * 0.2, // Increased width for proper spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Ensures left alignment
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: screenRatio * 10,
            height: screenRatio * 10,
            color: color,
          ),
          SizedBox(width: screenRatio * 6),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 8 * screenRatio,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
