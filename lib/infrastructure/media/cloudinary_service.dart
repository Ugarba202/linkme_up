import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const cloudName = "dc6kgo7xr";
  static const uploadPreset = "linkmeup_unsigned";

  Future<String> uploadImage(File file) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(responseData);
      return json['secure_url'];
    } else {
      throw Exception('Cloudinary Upload Failed (${response.statusCode}): $responseData');
    }
  }
}
