import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final Function(File) onImageCaptured;

  const CameraScreen({super.key, required this.onImageCaptured});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() => _isCameraReady = true);
  }

  Future<void> _captureImage() async {
    if (!_cameraController!.value.isInitialized) return;
    final image = await _cameraController!.takePicture();
    final dir = await getApplicationDocumentsDirectory();
    final imagePath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await File(image.path).copy(imagePath);
    widget.onImageCaptured(savedImage); // Passes the captured image back to the parent widget
    Navigator.pop(context); // Takes user back to the previous screen
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Sky')),
      body: _isCameraReady
          ? Stack(
        children: [
          CameraPreview(_cameraController!),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                onPressed: _captureImage,
                child: const Icon(Icons.camera),
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
