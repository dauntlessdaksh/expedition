import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/logger.dart';
import 'voice_announcement_builder.dart';
import 'voice_queue.dart';
import 'voice_settings.dart';

/// Offline text-to-speech service with serialized announcement playback.
class VoiceService {
  VoiceService({
    FlutterTts? flutterTts,
    VoiceAnnouncementBuilder? announcementBuilder,
  })  : _tts = flutterTts ?? FlutterTts(),
        _announcements = announcementBuilder ?? const VoiceAnnouncementBuilder(),
        _queue = VoiceQueue();

  final FlutterTts _tts;
  final VoiceAnnouncementBuilder _announcements;
  final VoiceQueue _queue;

  VoiceSettings _settings = VoiceSettings.defaults;
  bool _initialized = false;
  Completer<void>? _speakCompleter;
  Future<void>? _initializeFuture;

  VoiceAnnouncementBuilder get announcements => _announcements;

  VoiceSettings get settings => _settings;

  bool get isInitialized => _initialized;

  Future<void> initialize() {
    if (_initialized) {
      return Future<void>.value();
    }

    return _initializeFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    _queue.speakHandler = _speak;

    await _tts.awaitSpeakCompletion(true);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.duckOthers,
          IosTextToSpeechAudioCategoryOptions.interruptSpokenAudioAndMixWithOthers,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _tts.setQueueMode(1);
    }

    _tts.setStartHandler(() {});
    _tts.setCompletionHandler(_onSpeakCompleted);
    _tts.setCancelHandler(_onSpeakCompleted);
    _tts.setErrorHandler((_) => _onSpeakCompleted());

    await _tts.setSpeechRate(_settings.speakingRate.rate);
    _initialized = true;
    AppLogger.info('VoiceService initialized');
  }

  Future<void> applySettings(VoiceSettings settings) async {
    _settings = settings;
    if (!_initialized) {
      await initialize();
      return;
    }

    await _tts.setSpeechRate(settings.speakingRate.rate);
  }

  Future<void> speak(String text) async {
    await initialize();
    return _queue.enqueue(text);
  }

  Future<void> stop() async {
    if (!_initialized) {
      return;
    }

    _queue.clearPending();
    await _tts.stop();
    _completeSpeak();
  }

  void dispose() {
    _queue.dispose();
    if (_initialized) {
      unawaited(_tts.stop());
    }
  }

  Future<void> _speak(String text) async {
    _speakCompleter = Completer<void>();
    await _tts.speak(text);
    await _speakCompleter!.future;
  }

  void _onSpeakCompleted() {
    _completeSpeak();
  }

  void _completeSpeak() {
    if (_speakCompleter?.isCompleted ?? true) {
      return;
    }
    _speakCompleter!.complete();
  }
}
