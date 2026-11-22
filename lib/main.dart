import 'package:flutter/material.dart';

import 'features/home/home_page.dart';

void main() => runApp(const IncomeReportApp());

class IncomeReportApp extends StatelessWidget {
  const IncomeReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Income Report',
      home: HomePage(),
    );
  }
}
