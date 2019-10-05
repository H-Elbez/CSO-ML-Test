// Class responsible on the picture scan and process

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'utils/detector_painters.dart';

class PictureScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PictureScannerState();
}

class _PictureScannerState extends State<PictureScanner> {
  File _imageFile;
  Size _imageSize;
  String res = "";
  dynamic _scanResults;
  Detector _currentDetector = Detector.text;

  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();
  final TextRecognizer _recognizer = FirebaseVision.instance.textRecognizer();

  Future<void> _getAndScanImage() async {
    setState(() {
      _imageFile = null;
      _imageSize = null;
    });

    final File imageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _getImageSize(imageFile);
    }

    setState(() {
      _imageFile = imageFile;
      res = "";
    });
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  Future<void> _scanImage(File imageFile) async {
    setState(() {
      _scanResults = null;
    });

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    dynamic results;
    switch (_currentDetector) {
      case Detector.label:
        results = await _imageLabeler.processImage(visionImage);
        break;
      case Detector.text:
        results = await _recognizer.processImage(visionImage);
        break;
      default:
        return;
    }

    setState(() {
      _scanResults = results;
      getLabel(_scanResults);
    });
  }

  Widget _buildImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.file(_imageFile).image,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: _imageSize == null
                  ? Text(
                      '',
                      style: TextStyle(
                        color: Color(0xffff5e62),
                        fontSize: 15.0,
                      ),
                    )
                  : Text(
                      res,
                      style: TextStyle(
                        color: Color(0xffff5e62),
                        fontSize: 15.0,
                      ),
                    ),
            ),
            //_buildResults(_imageSize, _scanResults),
          ),
        )
      ],
    );
  }

  getLabel(dynamic labels) {
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
    setState(() {
      res = str;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffFF9966),
        title: Text(
          "CSO ML Test",
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.landscape),
            onPressed: () {
              _currentDetector = Detector.label;
              if (_imageFile != null) _scanImage(_imageFile);
            },
            tooltip: "Detect Label",
          ),
          IconButton(
            icon: Icon(Icons.text_fields),
            onPressed: () {
              _currentDetector = Detector.text;
              if (_imageFile != null) _scanImage(_imageFile);
            },
            tooltip: "Detect Text",
          )
        ],
      ),
      body: _imageFile == null
          ? const Center(child: Text('No image selected.'))
          : _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _getAndScanImage,
        tooltip: 'Pick Image',
        backgroundColor: Color(0xffFF9966),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  @override
  void dispose() {
    _imageLabeler.close();
    _recognizer.close();
    super.dispose();
  }
}
