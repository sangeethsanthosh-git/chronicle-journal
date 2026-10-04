import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _timer;
  int _secondsElapsed = 0;
  final StreamController<int> _durationController =
      StreamController<int>.broadcast();

  Stream<int> get durationStream => _durationController.stream;
  int get secondsElapsed => _secondsElapsed;

  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  Future<void> startRecording() async {
    final hasPerm = await hasPermission();
    if (!hasPerm) return;

    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(dir.path, 'voice_notes'));
    if (!audioDir.existsSync()) {
      audioDir.createSync(recursive: true);
    }

    final filePath = p.join(
      audioDir.path,
      'recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );

    _secondsElapsed = 0;
    _durationController.add(0);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      _durationController.add(_secondsElapsed);
    });

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: filePath,
    );
  }

  Future<String?> stopRecording() async {
    _timer?.cancel();
    _timer = null;
    final path = await _audioRecorder.stop();
    return path;
  }

  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  void dispose() {
    _timer?.cancel();
    _durationController.close();
    _audioRecorder.dispose();
  }
}
