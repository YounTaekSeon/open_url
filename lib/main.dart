import 'package:flutter/material.dart';
import 'widget/screen/main_page_screen.dart';

// TODO SHA1: 67:75:37:9B:A1:11:F9:C9:E0:B9:36:19:24:2E:5B:49:0D:C3:DD:2D
// TODO SHA256: 09:39:9E:68:AF:06:BD:FD:84:8B:B3:D6:0F:37:6A:6A:DB:25:BF:B3:36:82:26:48:3A:CF:CC:3B:A9:9E:27:FA

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Open URL',
      home: MainPageScreen(),
    );
  }
}