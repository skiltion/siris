import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String serverUrl = "http://172.30.1.246:5000/predict";

  static Future<Map<String, dynamic>> analyzeInsect(File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse(serverUrl));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }
}
