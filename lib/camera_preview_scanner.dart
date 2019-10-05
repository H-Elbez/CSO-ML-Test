// Class responsible on live camera processing

import 'utils/scanner_utils.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

import 'utils/detector_painters.dart';

class CameraPreviewScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CameraPreviewScannerState();
}

class _CameraPreviewScannerState extends State<CameraPreviewScanner> {
  dynamic _scanResults;
  CameraController _camera;
  Detector _currentDetector = Detector.text;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;
  String res = "";
  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();
  final TextRecognizer _recognizer = FirebaseVision.instance.textRecognizer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final CameraDescription description =
        await ScannerUtils.getCamera(_direction);

    _camera = CameraController(
      description,
      ResolutionPreset.medium,
    );
    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      _isDetecting = true;

      ScannerUtils.detect(
        image: image,
        detectInImage: _getDetectionMethod(),
        imageRotation: description.sensorOrientation,
      ).then(
        (dynamic results) {
          if (_currentDetector == null) return;
          setState(() {
            _scanResults = results;
          });
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  Future<dynamic> Function(FirebaseVisionImage image) _getDetectionMethod() {
    switch (_currentDetector) {
      case Detector.text:
        return _recognizer.processImage;
      case Detector.label:
        return _imageLabeler.processImage;
      default:
    }

    return null;
  }

  Widget _buildResults() {
    String str = "";
    const Text noResultsText = Text('',
        style: TextStyle(
          color: Color(0xffff5e62),
          fontSize: 15.0,
        ));

    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }

    switch (_currentDetector) {
      case Detector.label:
        if (_scanResults is! List<ImageLabel>) return noResultsText;
        str = getLabel(_scanResults);
        break;
      default:
        assert(_currentDetector == Detector.text);
        if (_scanResults is! VisionText) return noResultsText;
        str = getLabel(_scanResults);
    }
    return Text(str,
        style: TextStyle(
          color: Color(0xffff5e62),
          fontSize: 15.0,
        ));
  }

  String getLabel(dynamic labels) {
    String str = "";

    switch (_currentDetector) {
      case Detector.label:
        for (ImageLabel label in labels) {
          str = str +
              ('${(label.confidence * 100).toStringAsFixed(2)} % : ${label.text}\n');
        }

        break;

      case Detector.text:
        for (TextBlock block in labels.blocks) {
          for (TextLine line in block.lines) {
            for (TextElement element in line.elements) {
              str = str + element.text + " ";
            }
            str = str + "\n";
          }
        }

        break;
      default:
        break;
    }

    return str;
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(
              child: Text(
                '',
                style: TextStyle(
                  color: Color(0xffff5e62),
                  fontSize: 15.0,
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 350,
                    child: CameraPreview(_camera)),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildResults(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffFF5E62),
        title: const Text('CSO ML Test'),
        actions: <Widget>[
           IconButton(
            icon: Icon(Icons.landscape),
            onPressed: () {
              _currentDetector = Detector.label;
            },
            tooltip: "Detect Label",
          ),
          IconButton(
            icon: Icon(Icons.text_fields),
            onPressed: () {
              _currentDetector = Detector.text;
            },
            tooltip: "Detect Text",
          )
        ],
      ),
      body: _buildImage(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffFF5E62),
        onPressed: _toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    );
  }

  @override
  void dispose() {
    _camera.dispose().then((_) {
      _imageLabeler.close();
      _recognizer.close();
    });

    _currentDetector = null;
    super.dispose();
  }
}
