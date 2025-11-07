import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:vision_project/app/data/services/face_detector_service.dart';
import '../../routes/app_pages.dart';

class FaceDetectionController extends GetxController {
  final FaceDetectorService _service;
  FaceDetectionController(this._service);

  late CameraController cameraController;
  final isCameraInitialized = false.obs;
  RxList<Face> faces = <Face>[].obs;

  bool _isDetecting = false;
  bool _isCapturing = false;
  Rect? _lastBox;
  DateTime? _stillStart;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras.firstWhere((e)=> e.lensDirection.name == "front"),
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController.initialize();
    isCameraInitialized.value = true;
    cameraController.startImageStream(_processImage);
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isDetecting || _isCapturing) return;
    _isDetecting = true;

    try {
      final detectedFaces = await _service.process(
        image,
        cameraController.description.sensorOrientation,
      );
      faces.value = detectedFaces;

      if (detectedFaces.length == 1) {
        final currentBox = detectedFaces.first.boundingBox;
        if (_lastBox != null) {
          final moved = _hasMoved(currentBox, _lastBox!);

          if (!moved) {
            _stillStart ??= DateTime.now();
            if (DateTime.now().difference(_stillStart!).inMilliseconds > 1000) {
              await _captureFace();
            }
          } else {
            _stillStart = null;
          }
        }
        _lastBox = currentBox;
      } else {
        _lastBox = null;
        _stillStart = null;
      }
    } finally {
      _isDetecting = false;
    }
  }

  bool _hasMoved(Rect current, Rect last) {
    const threshold = 0.05;
    final dx = (current.left - last.left).abs();
    final dy = (current.top - last.top).abs();
    final dw = (current.width - last.width).abs();
    final dh = (current.height - last.height).abs();
    return dx > last.width * threshold ||
        dy > last.height * threshold ||
        dw > last.width * threshold ||
        dh > last.height * threshold;
  }

  Future<void> _captureFace() async {
    _isCapturing = true;
    await cameraController.stopImageStream();
    final picture = await cameraController.takePicture();
    await Get.toNamed(AppRoutes.preview, arguments: picture.path);
    await cameraController.startImageStream(_processImage);
    _isCapturing = false;
    _stillStart = null;
  }

  @override
  void onClose() {
    cameraController.dispose();
    _service.dispose();
    super.onClose();
  }
}
