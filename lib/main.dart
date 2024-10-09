import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

void main() {
  runApp(GuitarApp());
}

class GuitarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Synth Guitar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GuitarPage(),
    );
  }
}

class GuitarPage extends StatefulWidget {
  @override
  _GuitarPageState createState() => _GuitarPageState();
}

class _GuitarPageState extends State<GuitarPage> {
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlayerInited = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    await _player.openPlayer();
    setState(() {
      _isPlayerInited = true;
    });
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  void _playSineWave(double frequency) {
    final buffer =
        _generateSineWave(frequency, duration: 1.0, sampleRate: 44100);
    _player.startPlayer(
      fromDataBuffer: Uint8List.fromList(buffer),
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 1,
    );
    _player.setVolume(1);
  }

  /// Generates a sine wave and converts it to a Uint8List for audio playback
  List<int> _generateSineWave(double frequency,
      {required double duration, int sampleRate = 44100}) {
    int totalSamples = (sampleRate * duration).toInt();
    List<int> buffer = List<int>.filled(
        totalSamples * 2, 0); // 16-bit PCM (2 bytes per sample)
    double phase = 0.0;
    double phaseStep = 2 * pi * frequency / sampleRate;

    for (int i = 0; i < totalSamples; i++) {
      double sample = sin(phase); // Generate sine wave sample
      phase += phaseStep;

      // Normalize sample from [-1.0, 1.0] to [-32767, 32767] (16-bit PCM)
      int intSample = (sample * 32767).toInt();

      // Since we are using 16-bit PCM, store each sample as two 8-bit values (little-endian)
      buffer[i * 2] = intSample & 0xFF; // LSB (Least Significant Byte)
      buffer[i * 2 + 1] =
          (intSample >> 8) & 0xFF; // MSB (Most Significant Byte)
    }

    return buffer;
  }

  Widget buildStringButton(double frequency, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _playSineWave(frequency),
        child: Container(
          height: 80,
          margin: EdgeInsets.symmetric(vertical: 4),
          color: Colors.blue[300],
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Synth Guitar App'),
      ),
      body: Column(
        children: [
          buildStringButton(82.41, 'E (Low)'), // Frequency of low E string
          buildStringButton(110.00, 'A'), // Frequency of A string
          buildStringButton(146.83, 'D'), // Frequency of D string
          buildStringButton(196.00, 'G'), // Frequency of G string
          buildStringButton(246.94, 'B'), // Frequency of B string
          buildStringButton(329.63, 'E (High)'), // Frequency of high E string
        ],
      ),
    );
  }
}
