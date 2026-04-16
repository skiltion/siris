import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/insert_result.dart';
import '../services/firestore_service.dart';

class AnalyzeScreen extends StatefulWidget {
  final VoidCallback onResultSaved;

  AnalyzeScreen({required this.onResultSaved});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  bool loading = false;
  InsectResult? lastResult;
  File? lastImage;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _pickAndSendImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      loading = true;
      lastResult = null;
      lastImage = File(picked.path);
    });

    try {
      // 위치 권한 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("위치 권한이 거부되었습니다.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.");
      }

      // 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final uri = Uri.parse("http://172.30.1.246:5000/predict"); // 서버 URL
      final request = http.MultipartRequest("POST", uri);
      request.files.add(await http.MultipartFile.fromPath('file', picked.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);

        final insectResult = InsectResult(
          className: resData['class'],
          insectType: resData['type'],
          confidence: (resData['confidence'] as num).toDouble(),
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        );

        await _firestoreService.saveResult(insectResult);

        setState(() {
          lastResult = insectResult;
        });

        widget.onResultSaved();
      } else {
        setState(() {
          lastResult = InsectResult(
            className: "서버 에러",
            insectType: "",
            confidence: 0,
            latitude: 0,
            longitude: 0,
            timestamp: DateTime.now(),
          );
        });
      }
    } catch (e) {
      setState(() {
        lastResult = InsectResult(
          className: "오류 발생",
          insectType: e.toString(),
          confidence: 0,
          latitude: 0,
          longitude: 0,
          timestamp: DateTime.now(),
        );
      });
    }

    setState(() {
      loading = false;
    });
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("촬영"),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("업로드"),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(InsectResult result, File? imageFile) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.green[50], // 연녹색 배경
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  result.className,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: result.insectType == "해충"
                          ? Colors.redAccent
                          : Colors.green[300],
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    result.insectType,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.percent, size: 18),
                const SizedBox(width: 4),
                Text("${(result.confidence * 100).toStringAsFixed(2)}%"),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 4),
                Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(result.timestamp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("해충 / 익충 분석기"),
        backgroundColor: Colors.green[300], // 자연스러운 녹색
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : lastResult != null
                ? SingleChildScrollView(
                    child: _buildResultCard(lastResult!, lastImage),
                  )
                : const Text("사진을 촬영하거나 업로드해주세요"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceOptions,
        backgroundColor: Colors.green[300],
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
