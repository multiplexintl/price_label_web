import 'package:get/get.dart';

class App {
  late double _height;
  late double _width;

  App() {
    var queryData = Get.size;
    _height = queryData.height / 100.0;
    _width = queryData.width / 100.0;
  }

  double appHeight(double v) {
    return _height * v;
  }

  double appWidth(double v) {
    return _width * v;
  }
}
