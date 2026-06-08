import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final file = File('assets/audio/ringback.wav');
  if (!file.parent.existsSync()) {
    file.parent.createSync(recursive: true);
  }

  const sampleRate = 44100;
  const durationSeconds = 5.0; // 1 second ring, 4 seconds silence
  const frequency = 425.0; // Standard European/UK ringback frequency
  const amplitude = 0.5;
  final numSamples = (sampleRate * durationSeconds).toInt();

  // 16-bit PCM (2 bytes per sample)
  final byteData = ByteData(44 + numSamples * 2);

  // RIFF header
  byteData.setUint8(0, 0x52); // 'R'
  byteData.setUint8(1, 0x49); // 'I'
  byteData.setUint8(2, 0x46); // 'F'
  byteData.setUint8(3, 0x46); // 'F'
  byteData.setUint32(4, 36 + numSamples * 2, Endian.little);

  // WAVE format
  byteData.setUint8(8, 0x57); // 'W'
  byteData.setUint8(9, 0x41); // 'A'
  byteData.setUint8(10, 0x56); // 'V'
  byteData.setUint8(11, 0x45); // 'E'

  // fmt subchunk
  byteData.setUint8(12, 0x66); // 'f'
  byteData.setUint8(13, 0x6D); // 'm'
  byteData.setUint8(14, 0x74); // 't'
  byteData.setUint8(15, 0x20); // ' '
  byteData.setUint32(16, 16, Endian.little); // Subchunk1Size
  byteData.setUint16(20, 1, Endian.little); // AudioFormat (PCM)
  byteData.setUint16(22, 1, Endian.little); // NumChannels (Mono)
  byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
  byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
  byteData.setUint16(32, 2, Endian.little); // BlockAlign
  byteData.setUint16(34, 16, Endian.little); // BitsPerSample

  // data subchunk
  byteData.setUint8(36, 0x64); // 'd'
  byteData.setUint8(37, 0x61); // 'a'
  byteData.setUint8(38, 0x74); // 't'
  byteData.setUint8(39, 0x61); // 'a'
  byteData.setUint32(40, numSamples * 2, Endian.little); // Subchunk2Size

  // Generate samples
  int offset = 44;
  for (int i = 0; i < numSamples; i++) {
    double time = i / sampleRate;
    
    // Envelope: 1 second ON, 4 seconds OFF
    double env = (time % 5.0) < 1.0 ? 1.0 : 0.0;
    
    double sampleValue = sin(2 * pi * frequency * time) * amplitude * env;
    
    // Convert to 16-bit signed integer
    int intSample = (sampleValue * 32767).toInt();
    if (intSample > 32767) intSample = 32767;
    if (intSample < -32768) intSample = -32768;
    
    byteData.setInt16(offset, intSample, Endian.little);
    offset += 2;
  }

  file.writeAsBytesSync(byteData.buffer.asUint8List());
  print('Generated ringback tone at ${file.path}');
}
