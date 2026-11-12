// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'gallery_picker_service.dart';

GalleryPickerPlatform getGalleryPickerPlatform() => _WebGalleryPicker();

class _WebGalleryPicker implements GalleryPickerPlatform {
  @override
  Future<PickedGalleryImage?> pickImageFromGallery() async {
    final completer = Completer<PickedGalleryImage?>();
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          final result = reader.result;
          if (result is Uint8List) {
            completer.complete(PickedGalleryImage(
              fileName: file.name,
              bytes: result,
              mimeType: file.type.isNotEmpty ? file.type : 'image/jpeg',
            ));
          } else if (result is ByteBuffer) {
            completer.complete(PickedGalleryImage(
              fileName: file.name,
              bytes: result.asUint8List(),
              mimeType: file.type.isNotEmpty ? file.type : 'image/jpeg',
            ));
          } else if (result is List<int>) {
            completer.complete(PickedGalleryImage(
              fileName: file.name,
              bytes: Uint8List.fromList(result),
              mimeType: file.type.isNotEmpty ? file.type : 'image/jpeg',
            ));
          } else {
            completer.complete(null);
          }
        });

        reader.onError.listen((_) => completer.complete(null));
        reader.readAsArrayBuffer(file);
      } else {
        completer.complete(null);
      }
    });

    return completer.future;
  }
}

