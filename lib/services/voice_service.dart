import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Voice input/output for Assamese and Manipuri via Bhashini (India's
/// National Language Translation Mission), proxied through the
/// `bhashini-voice` Supabase Edge Function so the Bhashini account
/// credentials never ship in this client (see supabase/functions/bhashini-voice).
///
/// Every method here fails silently (returns null/false) when offline, the
/// language isn't one of the two Bhashini covers for us, or the API call
/// errors for any reason -- voice is strictly an optional enhancement over
/// the existing text UI, never something a screen can depend on to work.
class VoiceService {
  VoiceService._internal();
  static final VoiceService instance = VoiceService._internal();

  // Flip to true once the bhashini-voice Edge Function is actually deployed
  // with real Bhashini credentials (see supabase/functions/bhashini-voice) --
  // until then the mic/speaker buttons stay hidden rather than sitting on
  // screen doing nothing. No other code changes needed when that day comes.
  static const featureEnabled = false;

  static const _supportedLanguages = {'as', 'mni'};
  final _recorder = AudioRecorder();
  String? _activeRecordingPath;

  SupabaseClient get _client => Supabase.instance.client;

  bool supportsVoice(String languageCode) =>
      featureEnabled && _supportedLanguages.contains(languageCode);

  Future<bool> _online() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<bool> get isRecording => _recorder.isRecording();

  /// Starts capturing a WAV clip for ASR. Returns false (and records
  /// nothing) if the mic permission is denied -- callers just leave the
  /// text field as a normal typing target in that case.
  Future<bool> startRecording() async {
    if (!await _recorder.hasPermission()) return false;
    final dir = await getTemporaryDirectory();
    final path =
        p.join(dir.path, 'voice_input_${DateTime.now().millisecondsSinceEpoch}.wav');
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
      path: path,
    );
    _activeRecordingPath = path;
    return true;
  }

  Future<void> cancelRecording() async {
    if (await _recorder.isRecording()) await _recorder.stop();
    final path = _activeRecordingPath;
    _activeRecordingPath = null;
    if (path != null) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }

  /// Stops recording and returns the transcript, or null if offline, the
  /// language isn't supported, or the API call failed -- the caller's text
  /// field is left exactly as it was so the caregiver can just type instead.
  Future<String?> stopRecordingAndTranscribe(String languageCode) async {
    final path = await _recorder.stop();
    _activeRecordingPath = null;
    if (path == null || !supportsVoice(languageCode)) return null;
    if (!await _online()) return null;

    try {
      final bytes = await File(path).readAsBytes();
      final response = await _client.functions.invoke(
        'bhashini-voice',
        body: {
          'action': 'asr',
          'language': languageCode,
          'audioBase64': base64Encode(bytes),
        },
      );
      final data = response.data;
      if (data is Map && data['transcript'] is String) {
        final transcript = data['transcript'] as String;
        return transcript.trim().isEmpty ? null : transcript;
      }
      return null;
    } catch (e) {
      debugPrint('Bhashini ASR failed (falling back to text input): $e');
      return null;
    }
  }

  /// Synthesizes speech and returns a local file path ready to hand to
  /// AudioPlayer, or null if offline, unsupported, or the call failed --
  /// callers simply don't play anything and the text stays on screen as the
  /// only representation, exactly as before this feature existed.
  Future<String?> synthesize({required String languageCode, required String text}) async {
    if (!supportsVoice(languageCode) || text.trim().isEmpty) return null;
    if (!await _online()) return null;

    try {
      final response = await _client.functions.invoke(
        'bhashini-voice',
        body: {'action': 'tts', 'language': languageCode, 'text': text},
      );
      final data = response.data;
      if (data is! Map ||
          data['audioBase64'] is! String ||
          (data['audioBase64'] as String).isEmpty) {
        return null;
      }
      final bytes = base64Decode(data['audioBase64'] as String);
      final dir = await getTemporaryDirectory();
      final ext = (data['audioFormat'] as String?) ?? 'wav';
      final path =
          p.join(dir.path, 'voice_output_${DateTime.now().millisecondsSinceEpoch}.$ext');
      await File(path).writeAsBytes(bytes);
      return path;
    } catch (e) {
      debugPrint('Bhashini TTS failed (no audio played): $e');
      return null;
    }
  }
}
