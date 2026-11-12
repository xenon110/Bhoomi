import 'gallery_picker_service.dart';

GalleryPickerPlatform getGalleryPickerPlatform() => _StubGalleryPicker();

class _StubGalleryPicker implements GalleryPickerPlatform {
  @override
  Future<PickedGalleryImage?> pickImageFromGallery() async {
    return null;
  }
}

