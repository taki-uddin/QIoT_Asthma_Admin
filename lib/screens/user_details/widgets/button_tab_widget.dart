import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonTabWidget extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final dynamic value;
  final bool? inhaler;
  final VoidCallback onTap;
  final double screenRatio;

  const ButtonTabWidget({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    required this.value,
    this.inhaler,
    required this.onTap,
    required this.screenRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenRatio * 128,
        height: MediaQuery.of(context).size.height * 0.08,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label: ',
              // style: TextStyle(
              //   fontSize: screenRatio * 8,
              //   fontWeight: FontWeight.bold,
              //   color: const Color(0xFF000000),
              // ),
              style: GoogleFonts.manrope(
                fontSize: screenRatio * 8,
                letterSpacing: -.4,
                height: 0,
                fontWeight: FontWeight.w800,
              ),
            ),
            label != 'Fitness & Stress' && label != 'Diurinal Variation'
                ? Container(
                    width: screenRatio * (inhaler != true ? 28 : 46),
                    height: MediaQuery.of(context).size.height * 0.06,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.04),
                          offset: Offset(0.0, 1.0),
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        textAlign: TextAlign.center,
                        // style: TextStyle(
                        //   fontSize: screenRatio * 9,
                        //   fontWeight: FontWeight.bold,
                        //   color: textColor,
                        // ),
                        style: GoogleFonts.manrope(
                          fontSize: screenRatio * 8,
                          letterSpacing: -.4,
                          height: 0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
