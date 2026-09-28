import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> initialize() async {
    try {
      // AudioPlayer is ready by default
    } catch (e) {
      print('Failed to initialize audio service: $e');
    }
  }

  static Future<void> playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('notification.mp3'));
    } catch (e) {
      print('Failed to play notification sound: $e');
    }
  }

  static Future<void> playActionFeedback(String action) async {
    try {
      // Simple feedback using system sound
      await _audioPlayer.play(AssetSource('tap.mp3'));
    } catch (e) {
      print('Failed to play action feedback: $e');
    }
  }

  static Future<void> playErrorSound() async {
    try {
      await _audioPlayer.play(AssetSource('error.mp3'));
    } catch (e) {
      print('Failed to play error sound: $e');
    }
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
