import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue[200],
          gradient: LinearGradient(
              colors: [Colors.blue.shade200, Colors.blue.shade700],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,
          ),
          Row(
            children: [
              Image.asset(
                'assets/3d-fluency-empty-battery-1.png',
                height: 200,
              ),
              Text(
                '37%',
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              )
            ],
          )
        ],
      ),
    );
  }
}
