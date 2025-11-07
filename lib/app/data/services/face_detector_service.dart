import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/material.dart';

class FaceDetectorService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableLandmarks: true,
    ),
  );

  Future<List<Face>> process(CameraImage image, int rotation) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation:
            InputImageRotationValue.fromRawValue(rotation) ??
            InputImageRotation.rotation0deg,
        format:
            InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );

    return await _detector.processImage(inputImage);
  }

  Future<void> dispose() async => _detector.close();
}
