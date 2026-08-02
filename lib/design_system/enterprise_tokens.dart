import 'package:flutter/material.dart';

abstract final class EnterpriseSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class EnterpriseRadius {
  static const BorderRadius card = BorderRadius.all(Radius.circular(20));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(999));
}

abstract final class EnterpriseColors {
  static const Color seed = Color(0xFF155EEF);
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color danger = Color(0xFFF04438);
  static const Color info = Color(0xFF2E90FA);
}
