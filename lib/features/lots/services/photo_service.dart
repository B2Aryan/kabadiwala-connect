/// Service interface for selecting photos (mock and real)
abstract class PhotoService {
  Future<String?> takePhoto();
  Future<String?> pickFromGallery();
  List<String> getPresetSamples();
}

/// Clean mock implementation for web and development
class MockPhotoService implements PhotoService {
  static const List<String> samplePhotos = [
    'assets/samples/pcb_board.jpg',
    'assets/samples/copper_wire.jpg',
    'assets/samples/mobile_parts.jpg',
    'assets/samples/appliances.jpg',
  ];

  @override
  Future<String?> takePhoto() async {
    // Simulate brief capture
    await Future.delayed(const Duration(milliseconds: 200));
    return samplePhotos[0];
  }

  @override
  Future<String?> pickFromGallery() async {
    // Simulate gallery pick
    await Future.delayed(const Duration(milliseconds: 200));
    return samplePhotos[1];
  }

  @override
  List<String> getPresetSamples() {
    return samplePhotos;
  }
}
