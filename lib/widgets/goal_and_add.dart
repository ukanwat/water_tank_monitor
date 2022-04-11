import 'package:flutter/material.dart';

// widgets
import './daily_amout_dial.dart';
import './daily_goal_amount.dart';
import './water_effect.dart';

class GoalAndAdd extends StatelessWidget {
  final Map value;
  GoalAndAdd({this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
            constraints: constraints,
            child: Stack(
              alignment: Alignment.center,
              children: [
                WaterEffect(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DailyGoalAmount(value: value),

                          // DailyAmountDial()x
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ));
      },
    );
  }
}
