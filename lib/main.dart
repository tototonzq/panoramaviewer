// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panorama + Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PanoramaCameraPage(),
    );
  }
}

class PanoramaCameraPage extends StatefulWidget {
  @override
  _PanoramaCameraPageState createState() => _PanoramaCameraPageState();
}

class _PanoramaCameraPageState extends State<PanoramaCameraPage> {
  late List<CameraDescription> cameras;
  CameraDescription? selectedCamera;

  bool isStoppedPosition = false;
  double opacity = 0.5;
  double animSpeed = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    setState(() {
      if (selectedCamera == null) {
        selectedCamera = cameras.first;
      }
    });
  }

  void onStop() {
    setState(() {
      isStoppedPosition = !isStoppedPosition;
      opacity = isStoppedPosition ? 1 : 0.5;
      animSpeed = isStoppedPosition ? 0.1 : 0.0;
      _defaultSelectedImageFile = _selectedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panorama + Camera'),
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CameraPage(camera: selectedCamera!),
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Opacity(
                  opacity:
                      opacity, // Adjust the opacity value as needed (0.0 to 1.0).
                  child: Panorama(
                    sensitivity: isStoppedPosition ? 0 : 1,
                    animSpeed: 0.1,
                    sensorControl: SensorControl.AbsoluteOrientation,
                    child: _selectedImageFile != null ||
                            _defaultSelectedImageFile != null
                        ? Image.file(
                            _selectedImageFile ?? _defaultSelectedImageFile!)
                        : Image.asset(
                            'assets/images/test2.png',
                          ),
                  ))),
          Positioned(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: IconButton(
              icon: Image.asset('assets/images/stop-btn.png'),
              iconSize: 80,
              onPressed: onStop,
            ),
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImageFromGallery,
        tooltip: 'Pick Image',
        child: Icon(Icons.photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<Widget> _getPanoramaWidget() async {
    if (_selectedImageFile != null) {
      return Opacity(
        opacity: opacity, // Adjust the opacity value as needed (0.0 to 1.0).
        child: Panorama(
          animSpeed: animSpeed,
          interactive: false,
          sensorControl: SensorControl.AbsoluteOrientation,
          child: Image.file(_selectedImageFile!),
        ),
      );
    } else {
      return Opacity(
        opacity: opacity, // Adjust the opacity value as needed (0.0 to 1.0).
        child: Panorama(
          animSpeed: animSpeed,
          interactive: false,
          sensorControl: SensorControl.AbsoluteOrientation,
          child: Image.asset(
            'assets/images/test.png',
          ), // Display a placeholder image when no image is picked.
        ),
      );
    }
  }

  File? _selectedImageFile;
  File? _defaultSelectedImageFile;

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }
}

class CameraPage extends StatefulWidget {
  final CameraDescription camera;

  CameraPage({required this.camera});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeCameraControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeCameraControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeCameraControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
