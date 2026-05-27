import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'nokia_providers.dart';

part 'audio_engine_service.g.dart';

class AudioEngineService {
  final AudioPlayer _player = AudioPlayer();
  final NokiaAudioPlaybackStatus _statusController;

  AudioEngineService(this._statusController) {
    // Listen to play/pause state changes
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _statusController.setStatus(NokiaAudioStatus.loaded);
        _player.seek(Duration.zero);
        _player.pause();
      } else if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        _statusController.setStatus(NokiaAudioStatus.loading);
      } else if (state.playing) {
        _statusController.setStatus(NokiaAudioStatus.playing);
      } else {
        _statusController.setStatus(NokiaAudioStatus.loaded);
      }
    });
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<void> loadTrack(String url) async {
    try {
      _statusController.setStatus(NokiaAudioStatus.loading);
      await _player.setUrl(url);
      _statusController.setStatus(NokiaAudioStatus.loaded);
    } catch (e) {
      print('Error loading track: $e');
      _statusController.setStatus(NokiaAudioStatus.idle);
    }
  }

  void play() {
    _player.play();
  }

  void pause() {
    _player.pause();
  }

  void stop() {
    _player.stop();
    _statusController.setStatus(NokiaAudioStatus.loaded);
  }

  void setVolume(double vol) {
    // just_audio volume is between 0.0 and 1.0
    _player.setVolume(vol.clamp(0.0, 1.0));
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  void dispose() {
    _player.dispose();
  }
}

@riverpod
AudioEngineService audioEngine(AudioEngineRef ref) {
  final statusNotifier = ref.watch(nokiaAudioPlaybackStatusProvider.notifier);
  final service = AudioEngineService(statusNotifier);

  // Sync volume changes automatically from the NokiaVolume notifier
  ref.listen(nokiaVolumeProvider, (previous, next) {
    final isMuted = ref.read(nokiaMuteProvider);
    if (isMuted) {
      service.setVolume(0.0);
    } else {
      service.setVolume(next / 100.0);
    }
  });

  // Sync mute changes
  ref.listen(nokiaMuteProvider, (previous, next) {
    if (next) {
      service.setVolume(0.0);
    } else {
      final vol = ref.read(nokiaVolumeProvider);
      service.setVolume(vol / 100.0);
    }
  });

  // Set initial volume
  final isMuted = ref.read(nokiaMuteProvider);
  if (isMuted) {
    service.setVolume(0.0);
  } else {
    final vol = ref.read(nokiaVolumeProvider);
    service.setVolume(vol / 100.0);
  }

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
