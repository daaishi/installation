import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// display current time and date for tab 1
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1), (i) => DateTime.now()),
          builder: (context, snapshot) {
            return Text(
              snapshot.data != null ? DateFormat('yyyy-MM-dd hh:mm:ss').format(snapshot.data!) : 'Loading...',
              style: const TextStyle(fontSize: 24),
            );
          },
      ),
    ),
    );
  }
}