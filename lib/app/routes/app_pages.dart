import 'package:get/get.dart';
import '../modules/face_detection/face_detection_binding.dart';
import '../modules/face_detection/face_detection_page.dart';
import '../modules/face_detection/preview_page.dart';

part 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.faceDetection,
      page: () => const FaceDetectionPage(),
      binding: FaceDetectionBinding(),
    ),
    GetPage(name: AppRoutes.preview, page: () => const PreviewPage()),
  ];
}
