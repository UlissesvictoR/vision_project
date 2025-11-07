import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String path = Get.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirme a imagem')),
      body: Column(
        children: [
          Expanded(child: Image.file(File(path))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Get.back(result: false),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.back(result: true),
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
