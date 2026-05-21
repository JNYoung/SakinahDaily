import 'dart:async';

import 'package:just_audio/just_audio.dart' as just_audio;

import '../models/sakinah_models.dart';

enum AudioPlaybackStatus {
  idle,
  loading,
  ready,
  playing,
  paused,
  completed,
  error,
  textOnlyFallback,
}

class AudioPlaybackState {
  const AudioPlaybackState({
    required this.status,
    this.asset,
    this.message,
  });

  final AudioPlaybackStatus status;
  final AudioAsset? asset;
  final String? message;

  static const idle = AudioPlaybackState(status: AudioPlaybackStatus.idle);
}

abstract class SakinahAudioPlayer {
  Future<void> load(AudioAsset asset);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Stream<AudioPlaybackState> get stateStream;
  AudioPlaybackState get currentState;
}

class JustAudioSakinahPlayer implements SakinahAudioPlayer {
  JustAudioSakinahPlayer({just_audio.AudioPlayer? player})
      : _player = player ?? just_audio.AudioPlayer() {
    _subscription = _player.playerStateStream.listen((state) {
      if (state.processingState == just_audio.ProcessingState.completed) {
        _emit(AudioPlaybackState(
          status: AudioPlaybackStatus.completed,
          asset: _currentAsset,
        ));
      }
    });
  }

  final just_audio.AudioPlayer _player;
  final _controller = StreamController<AudioPlaybackState>.broadcast(
    sync: true,
  );
  late final StreamSubscription<just_audio.PlayerState> _subscription;
  AudioPlaybackState _state = AudioPlaybackState.idle;
  AudioAsset? _currentAsset;

  @override
  AudioPlaybackState get currentState => _state;

  @override
  Stream<AudioPlaybackState> get stateStream => _controller.stream;

  @override
  Future<void> load(AudioAsset asset) async {
    _currentAsset = asset;
    _emit(
        AudioPlaybackState(status: AudioPlaybackStatus.loading, asset: asset));
    if (asset.textOnlyFallbackRequired) {
      _emit(
        AudioPlaybackState(
          status: AudioPlaybackStatus.textOnlyFallback,
          asset: asset,
        ),
      );
      return;
    }
    try {
      if (asset.assetPath != null && asset.assetPath!.isNotEmpty) {
        await _player.setAsset(asset.assetPath!);
      } else {
        await _player.setUrl(asset.url!);
      }
      _emit(
          AudioPlaybackState(status: AudioPlaybackStatus.ready, asset: asset));
    } on Object catch (error) {
      _emit(
        AudioPlaybackState(
          status: AudioPlaybackStatus.error,
          asset: asset,
          message: '$error',
        ),
      );
    }
  }

  @override
  Future<void> play() async {
    if (_state.status == AudioPlaybackStatus.textOnlyFallback ||
        _state.status == AudioPlaybackStatus.error) {
      return;
    }
    await _player.play();
    _emit(
      AudioPlaybackState(
        status: AudioPlaybackStatus.playing,
        asset: _currentAsset,
      ),
    );
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _emit(
      AudioPlaybackState(
        status: AudioPlaybackStatus.paused,
        asset: _currentAsset,
      ),
    );
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _emit(AudioPlaybackState.idle);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
    await _player.dispose();
  }

  void _emit(AudioPlaybackState state) {
    _state = state;
    _controller.add(state);
  }
}

class FakeSakinahAudioPlayer implements SakinahAudioPlayer {
  final _controller = StreamController<AudioPlaybackState>.broadcast(
    sync: true,
  );
  AudioPlaybackState _state = AudioPlaybackState.idle;
  AudioAsset? _currentAsset;

  @override
  AudioPlaybackState get currentState => _state;

  @override
  Stream<AudioPlaybackState> get stateStream => _controller.stream;

  @override
  Future<void> load(AudioAsset asset) async {
    _currentAsset = asset;
    _emit(
        AudioPlaybackState(status: AudioPlaybackStatus.loading, asset: asset));
    if (asset.textOnlyFallbackRequired) {
      _emit(
        AudioPlaybackState(
          status: AudioPlaybackStatus.textOnlyFallback,
          asset: asset,
        ),
      );
      return;
    }
    _emit(AudioPlaybackState(status: AudioPlaybackStatus.ready, asset: asset));
  }

  @override
  Future<void> play() async {
    if (_state.status == AudioPlaybackStatus.textOnlyFallback ||
        _state.status == AudioPlaybackStatus.error) {
      return;
    }
    _emit(
      AudioPlaybackState(
        status: AudioPlaybackStatus.playing,
        asset: _currentAsset,
      ),
    );
  }

  @override
  Future<void> pause() async {
    _emit(
      AudioPlaybackState(
        status: AudioPlaybackStatus.paused,
        asset: _currentAsset,
      ),
    );
  }

  @override
  Future<void> stop() async {
    _currentAsset = null;
    _emit(AudioPlaybackState.idle);
  }

  Future<void> complete() async {
    _emit(
      AudioPlaybackState(
        status: AudioPlaybackStatus.completed,
        asset: _currentAsset,
      ),
    );
  }

  Future<void> dispose() async {
    await _controller.close();
  }

  void _emit(AudioPlaybackState state) {
    _state = state;
    _controller.add(state);
  }
}
