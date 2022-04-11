import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// providers
import '../providers/home_provider.dart';

class DailyGoalAmount extends StatelessWidget {
  final Map value;
  DailyGoalAmount({this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          border: Border(left: BorderSide(color: Colors.white, width: 2)),
        ),
        child: Row(
          children: [
            Text(
              value['field2'].toString() == '1'
                  ? 'Not Overflowing'
                  : 'Overflowing',
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 20,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(
              width: 15,
            ),
          ],
        ),
      ),
    );
  }
}
