import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        return child!;
      },
      title: 'Price Label',
      initialRoute: RouteLinks.splash,
      getPages: RouteGenerator.list,
      debugShowCheckedModeBanner: false,
    );
  }
}
