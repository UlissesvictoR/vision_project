import 'package:get/get.dart';
import 'package:vision_project/app/data/services/face_detector_service.dart';
import 'face_detection_controller.dart';

class FaceDetectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FaceDetectorService());
    Get.put(FaceDetectionController(Get.find()));
  }
}
