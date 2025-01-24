import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:price_label_web/pages/accessories_promo.dart';
import 'package:price_label_web/pages/main_page.dart';
import 'package:price_label_web/pages/price_label_non_promo.dart';
import 'package:price_label_web/pages/price_label_promo.dart';
import 'package:price_label_web/pages/price_tag_exquisite.dart';
import 'package:price_label_web/pages/splash_screen.dart';
import 'package:price_label_web/pages/test.dart';

import 'pages/accessories_no_promo.dart';

class RouteGenerator {
  static var list = [
    GetPage(
      name: RouteLinks.splash,
      page: () => const SplashScreen(),
      transition: Transition.cupertino,
      curve: Curves.easeIn,
      transitionDuration: const Duration(seconds: 1),
    ),
    GetPage(
      name: RouteLinks.main,
      page: () => const MainPage(),
      transition: Transition.cupertino,
      curve: Curves.easeIn,
      transitionDuration: const Duration(seconds: 1),
    ),
    GetPage(
      name: RouteLinks.priceTagExq,
      page: () => const PriceTagLabelExquisiteView(),
      transition: Transition.cupertino,
      curve: Curves.easeIn,
      transitionDuration: const Duration(seconds: 1),
    ),
    GetPage(
      name: RouteLinks.priceLabelPromo,
      page: () => const PriceLabelPromoView(),
      transition: Transition.cupertino,
      curve: Curves.easeIn,
      transitionDuration: const Duration(seconds: 1),
    ),
    GetPage(
      name: RouteLinks.priceLabelNoPromo,
      page: () => const PriceLabelNonPromoView(),
      transition: Transition.cupertino,
      curve: Curves.easeIn,
      transitionDuration: const Duration(seconds: 1),
    ),
    GetPage(
      name: RouteLinks.accessoriesPromo,
      page: () => const AccessoriesPromoView(),
      transition: Transition.cupertino,
      curve: Curves.easeIn,
      transitionDuration: const Duration(seconds: 1),
    ),
    GetPage(
      name: RouteLinks.accessoriesNoPromo,
      page: () => const AccessoriesNoPromoView(),
      transition: Transition.cupertino,
      curve: Curves.easeIn,
      transitionDuration: const Duration(seconds: 1),
    ),
    GetPage(
      name: RouteLinks.test,
      page: () => const PriceLabelPromoViewTest(),
      transition: Transition.cupertino,
      curve: Curves.easeIn,
      transitionDuration: const Duration(seconds: 1),
    ),
  ];
}

class RouteLinks {
  static const String splash = "/Splash";
  static const String main = "/MainScreen";
  static const String priceTagExq = "/PricetagExquisite";
  static const String priceLabelPromo = "/PriceLabelPromo";
  static const String priceLabelNoPromo = "/PriceLabelNoPromo";
  static const String accessoriesPromo = "/AccessoriesPromo";
  static const String accessoriesNoPromo = "/AccessoriesNoPromo";
  static const String test = "/Test";
}
