import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const cloudName = "dc6kgo7xr";
  static const uploadPreset = "linkmeup_unsigned";

  Future<String> uploadImage(File file) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload image to Cloudinary: ${response.reasonPhrase}');
    }

    final responseBody = await response.stream.bytesToString();
    final data = json.decode(responseBody);

    return data['secure_url'] as String;
  }
}
