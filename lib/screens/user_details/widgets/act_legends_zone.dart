import 'package:flutter/material.dart';

class ACTLegendsZone extends StatelessWidget {
  final double screenRatio;
  final Size screenSize;

  const ACTLegendsZone({
    super.key,
    required this.screenRatio,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenSize.width * 0.5,
      height: screenSize.height * 0.04,
      child: const Row(
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
                        'Value:25',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color(0xFF27AE60),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            child: Row(
              children: [
                Text(
                  'Value:21-24',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFFF2C94C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            child: Row(
              children: [
                Text(
                  'Value:<20',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFFFD4646),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
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
