import 'package:flutter/material.dart';

class InhalerLegendsZone extends StatelessWidget {
  // final double screenRatio;
  // final Size screenSize;

  const InhalerLegendsZone({
    super.key,
    // required this.screenRatio,
    // required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: screenSize.width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildZoneRow(
                  // screenRatio: screenRatio,
                  // screenSize: screenSize,
                  color: const Color(0xFF27AE60),
                  label: 'Green Zone\n(80-100%)',
                ),
                SizedBox(
                  width: 20,
                ),
                _buildZoneRow(
                  // screenRatio: screenRatio,
                  // screenSize: screenSize,
                  color: const Color(0xFFFF8500),
                  label: 'Amber Zone\n(60-79%)',
                ),
                SizedBox(
                  width: 20,
                ),
                _buildZoneRow(
                  // screenRatio: screenRatio,
                  // screenSize: screenSize,
                  color: const Color(0xFFFD4646),
                  label: 'Red Zone - Urgent\n(50-59%)',
                ),
                SizedBox(
                  width: 20,
                ),
                _buildZoneRow(
                  // screenRatio: screenRatio,
                  // screenSize: screenSize,
                  color: const Color(0xFFD10000),
                  label: 'Red Zone - Emergency\n(<50%)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneRow({
    // required double screenRatio,
    // required Size screenSize,
    required Color color,
    required String label,
  }) {
    return SizedBox(
      width: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            color: color,
          ),
          SizedBox(width: 15),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
