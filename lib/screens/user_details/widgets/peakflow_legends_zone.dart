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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildZoneRow(
                screenRatio: screenRatio,
                screenSize: screenSize,
                color: const Color(0xFF27AE60),
                label: 'Green Zone\n(80-100%)',
              ),
              SizedBox(height: screenSize.height * 0.01),
              _buildZoneRow(
                screenRatio: screenRatio,
                screenSize: screenSize,
                color: const Color(0xFFFF8500),
                label: 'Amber Zone\n(60-79%)',
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildZoneRow(
                screenRatio: screenRatio,
                screenSize: screenSize,
                color: const Color(0xFFFD4646),
                label: 'Red Zone - Urgent\n(50-59%)',
              ),
              SizedBox(height: screenSize.height * 0.01),
              _buildZoneRow(
                screenRatio: screenRatio,
                screenSize: screenSize,
                color: const Color(0xFFD10000),
                label: 'Red Zone - Emergency\n(<50%)',
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
      width: screenSize.width * 0.25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: screenRatio * 8,
            height: screenRatio * 8,
            color: color,
          ),
          SizedBox(width: screenRatio * 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 5 * screenRatio,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
