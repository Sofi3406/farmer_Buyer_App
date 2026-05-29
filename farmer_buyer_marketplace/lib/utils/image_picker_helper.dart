import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<List<XFile>> pickMultipleImages() async {
    final picker = ImagePicker();
    // Use pickMultiImage when available to allow multiple selection
    final List<XFile> picked = await picker.pickMultiImage();
    // Limit to max 5 images
    return picked.take(5).toList();
  }

  static Future<XFile?> pickSingleImage() async {
    final picker = ImagePicker();
    return picker.pickImage(source: ImageSource.gallery);
  }
}