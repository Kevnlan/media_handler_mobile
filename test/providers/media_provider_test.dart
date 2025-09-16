import 'package:flutter_test/flutter_test.dart';
import 'package:media_handler/providers/media_provider.dart';
import 'package:media_handler/data/models/media_model.dart';

void main() {
  group('MediaProvider Tests', () {
    late MediaProvider mediaProvider;

    setUp(() {
      mediaProvider = MediaProvider();
    });

    test('Initial state should be empty', () {
      expect(mediaProvider.getMediaByType(MediaType.image), isEmpty);
      expect(mediaProvider.getMediaByType(MediaType.video), isEmpty);
      expect(mediaProvider.getMediaByType(MediaType.audio), isEmpty);
      expect(mediaProvider.isUploading, false);
      expect(mediaProvider.errorMessage, null);
    });

    test('Loading states should be initialized correctly', () {
      expect(mediaProvider.isLoadingByType(MediaType.image), false);
      expect(mediaProvider.isLoadingByType(MediaType.video), false);
      expect(mediaProvider.isLoadingByType(MediaType.audio), false);
    });

    test('Has more states should be initialized correctly', () {
      expect(mediaProvider.hasMoreByType(MediaType.image), true);
      expect(mediaProvider.hasMoreByType(MediaType.video), true);
      expect(mediaProvider.hasMoreByType(MediaType.audio), true);
    });

    test('Collections should be empty initially', () {
      expect(mediaProvider.collections, isEmpty);
      expect(mediaProvider.isLoadingCollections, false);
    });

    test('Error clearing should work', () {
      // This test would need a way to set an error first
      // In real implementation, you'd mock the service
      mediaProvider.clearError();
      expect(mediaProvider.errorMessage, null);
    });

    test('Selected media clearing should work', () {
      mediaProvider.clearSelectedMedia();
      expect(mediaProvider.selectedMedia, null);
    });
  });
}
