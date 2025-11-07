import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'face_detection_controller.dart';

class FaceDetectionPage extends GetView<FaceDetectionController> {
  const FaceDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Detection')),
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final previewSize =
            controller.cameraController.value.previewSize ?? const Size(1, 1);

        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller.cameraController),
            Obx(
              () => CustomPaint(
                painter: FacePainter(
                  faces: controller.faces.toList(), // força nova referência
                  imageSize: Size(previewSize.height, previewSize.width),
                  cameraDescription: controller.cameraController.description,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final CameraDescription cameraDescription;

  FacePainter({
    required this.faces,
    required this.imageSize,
    required this.cameraDescription,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    if (faces.isEmpty) return;

    final isFrontCamera =
        cameraDescription.lensDirection == CameraLensDirection.front;

    // Cálculo de escala corrigido (width/height invertidos)
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    for (final face in faces) {
      // Corrige rotação e espelhamento
      Rect rect = Rect.fromLTRB(
        face.boundingBox.left * scaleX,
        face.boundingBox.top * scaleY,
        face.boundingBox.right * scaleX,
        face.boundingBox.bottom * scaleY,
      );

      if (isFrontCamera) {
        rect = Rect.fromLTRB(
          size.width - rect.right,
          rect.top,
          size.width - rect.left,
          rect.bottom,
        );
      }

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) {
    // Força repintura sempre que o número de rostos mudar
    return oldDelegate.faces.length != faces.length ||
        oldDelegate.faces.hashCode != faces.hashCode;
  }
}
