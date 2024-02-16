import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class CreateScriptViewModel extends ChangeNotifier {
  bool isRecording = false;
  bool _isRecorderInitialized = false; // 녹음기 초기화 여부 : 파일
  bool _isRecording = false; // 녹음 중 여부 : 파일
  FlutterSoundRecorder? _audioRecorder;


  bool handDone = false;
  TextEditingController writedTextController = TextEditingController(); // 사용자 입력을 위한 컨트롤러
  TextEditingController voicedTextController = TextEditingController(); // 음성 인식 결과를 위한 컨트롤러
  stt.SpeechToText speechToText = stt.SpeechToText();

  CreateScriptViewModel() {
    _init();
    _initRecorder();
  }

  void _init() async {
    await requestPermission();
    speechToText.initialize(
      onError: (val) => print('Error: $val'),
      onStatus: _handleStatus,
    );
  }

  Future<void> _initRecorder() async {
    _audioRecorder = FlutterSoundRecorder();

    await _audioRecorder?.openRecorder();
    _isRecorderInitialized = true;
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized || _isRecording) return;

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _audioRecorder!.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );

      _isRecording = true;
  }

  Future<void> _stopRecording() async {
    if (!_isRecorderInitialized || !_isRecording) return;

    await _audioRecorder!.stopRecorder();
      _isRecording = false;
  }
  void _handleStatus(String status) {
    if(handDone) return;
    if (status == 'done') {
      stopListening();
      Future.delayed(Duration(milliseconds: 100), () {
        startListening();
      });
    }
    notifyListeners();
  }

  Future<void> requestPermission() async {
    var microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      await Permission.microphone.request();
    }
  }

  void toggleRecording() {
    isRecording ? stopListening() : startListening();
    _isRecording ? _stopRecording() : _startRecording();
    handDone = isRecording;
    isRecording = !isRecording;
    notifyListeners();
  }

  Future<void> startListening() async {
    bool available = await speechToText.initialize();
    if (!available) {
      print("The user has denied the use of speech recognition.");
      return;
    }
    speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          voicedTextController.text += result.recognizedWords + " ";
          notifyListeners();
        }
      },
      listenFor: Duration(minutes: 5),
      pauseFor: Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async {
    speechToText.stop();
    notifyListeners();
  }

  void complete() {
    // 완료 버튼에 대한 로직
    print("완료버튼 눌렀습니다.");
  }

  @override
  void dispose() {
    // 컨트롤러들을 정리합니다.
    if (_audioRecorder != null) {
      _audioRecorder!.closeRecorder();
      _audioRecorder = null;
    }
    writedTextController.dispose();
    voicedTextController.dispose();
    super.dispose();
  }
}
