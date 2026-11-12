import 'dart:typed_data';
import 'gallery_picker_stub.dart'
    if (dart.library.html) 'gallery_picker_web.dart';

class PickedGalleryImage {
  final String fileName;
  final Uint8List bytes;
  final String mimeType;

  const PickedGalleryImage({
    required this.fileName,
    required this.bytes,
    required this.mimeType,
  });
}

abstract class GalleryPickerPlatform {
  Future<PickedGalleryImage?> pickImageFromGallery();
}

class GalleryPickerService {
  static Future<PickedGalleryImage?> pickImage() {
    return getGalleryPickerPlatform().pickImageFromGallery();
  }
}

