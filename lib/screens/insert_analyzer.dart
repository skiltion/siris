import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/insert_result.dart';

class InsertAnalyzer {
  final ImageLabeler _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> analyzeAndSaveImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final labels = await _imageLabeler.processImage(inputImage);

    if (labels.isEmpty) return;

    final bestLabel = labels.first; // Confidence 높은 라벨
    final insectType = _determineInsectType(bestLabel.label);

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final insectResult = InsectResult(
      className: bestLabel.label,
      insectType: insectType,
      confidence: bestLabel.confidence,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
    );

    await _firestore.collection('insect_results').add(insectResult.toMap());
  }

  String _determineInsectType(String className) {
    // 임시 분류: 나중에 구체화 가능
    const beneficialInsects = ['bee', 'ladybug'];
    if (beneficialInsects.contains(className.toLowerCase())) {
      return '익충';
    } else {
      return '해충';
    }
  }

  void dispose() {
    _imageLabeler.close();
  }
}
