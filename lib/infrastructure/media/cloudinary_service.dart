
import 'dart:io';


class CloudinaryService {
  static const cloudName = "dc6kgo7xr";
  static const uploadPreset = "linkmeup_unsigned";

  Future<String> uploadImage(File file) async {
    // Mock implementation for testing
    await Future.delayed(const Duration(seconds: 1)); // Simulate upload delay
    print("MOCK: Image uploaded (simulated): ${file.path}");
    return file.path; // Return local path to display image immediately
  }
}
