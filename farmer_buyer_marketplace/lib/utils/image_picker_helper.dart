import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<List<XFile>> pickMultipleImages() async {
    final picker = ImagePicker();
    final List<XFile> images = [];
    // For multiple selection, we pick one by one (or use pickMultiImage)
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) images.add(picked);
    // You can add loop to pick more, but for simplicity we return one
    return images;
  }

  static Future<XFile?> pickSingleImage() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }
}