import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';

void main() => runApp(const IncomeReportApp());

class IncomeReportApp extends StatelessWidget {
  const IncomeReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Income Report',
      theme: buildAppTheme(),
      home: const HomePage(),
    );
  }
}
