part of '../audio_meta.dart';

AudioType? _getType(Uint8List bytes) {
  // Check for AAC (ADTS format, 0xFFF syncword)
  if (bytes.length > 2 && bytes[0] == 0xFF && (bytes[1] & 0xF0) == 0xF0) {
    return AudioType.aac;
  }

  // Check for MP3 (Frame Sync Word: 0xFFE or ID3 tag "ID3")
  if (bytes.length > 2 && (bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0)) {
    return AudioType.mp3;
  }

  if (bytes.length > 3 &&
      bytes[0] == 0x49 &&
      bytes[1] == 0x44 &&
      bytes[2] == 0x33) {
    return AudioType.mp3; // ID3v2 tag detected
  }

  // Check for OGG ("OggS")
  if (bytes.length > 4 &&
      bytes[0] == 0x4F &&
      bytes[1] == 0x67 &&
      bytes[2] == 0x67 &&
      bytes[3] == 0x53) {
    return AudioType.ogg;
  }

  // Check for WAV ("RIFF" followed by "WAVE")
  if (bytes.length > 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x41 &&
      bytes[10] == 0x56 &&
      bytes[11] == 0x45) {
    return AudioType.wav;
  }

  // Check for FLAC ("fLaC")
  if (bytes.length > 4 &&
      bytes[0] == 0x66 &&
      bytes[1] == 0x4C &&
      bytes[2] == 0x61 &&
      bytes[3] == 0x43) {
    return AudioType.flac;
  }

  return null;
}
