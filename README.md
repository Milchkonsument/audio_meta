### audio_meta: Leightweight Audio Information Extraction
![License](https://img.shields.io/github/license/Milchkonsument/audio_meta)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Milchkonsument/audio_meta)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/Milchkonsument/audio_meta)
[![Free PS](https://img.shields.io/badge/free%20palestine%20-DD1111)](https://donate.unrwa.org/int/en/general)

<a href="https://www.paypal.com/donate/?hosted_button_id=T4TYU28529KSL"><img src="https://raw.githubusercontent.com/andreostrovsky/donate-with-paypal/925c5a9e397363c6f7a477973fdeed485df5fdd9/blue.svg" height="38"/></a>&nbsp;<a href="https://ko-fi.com/S6S7SIR1N"><img src="https://ko-fi.com/img/githubbutton_sm.svg" height="38"/></a>

## Notice
> _This package DOES NOT extract audio metadata like ID3 tags (e.g. Label, Release Year). This package DOES extract information about the audio stream, like duration or bit rate._

> ⚠️ _This package is still in ACTIVE DEVELOPMENT and currently serves more as a preview. First stable, thoroughly tested version will be 2.0.0. You have been warned._

## Content
* 💯 100% cross-platform
* 💯 100% pure dart
* 🙅‍♂️ 0 dependencies
* ✅ Uniform audio information for all file types
* ✅ No need for external tools like ffprobe

### Current Support For:
* ✅ mp3
* ✅ wav
* ✅ aac
* ✅ ogg
* ✅ flac
* ✅ opus
* 🚧 m4a

### Metadata Available Through This Package:
* 🔊 Track Duration
* 🔊 Sample Rate
* 🔊 Bit Rate
* 🔊 Bit Depth
* 🔊 Channel Count
* 🔊 Encoding

## Getting Started
### Get from pub.dev
```
dart pub add audio_meta
```

### Include in Project
```dart
import 'package:audio_meta/audio_meta.dart';
```

### Constructors
```dart
// sync

// unsupported on web
AudioMeta.fromFile(File file)
AudioMeta.fromPath(String path)

// supported on web
AudioMeta.fromBytes(Uint8list bytes)

// async

// unsupported on web
AudioMeta.fromFileAsync(File file)
AudioMeta.fromPathAsync(String path)

// supported on web
AudioMeta.fromBytesAsync(Uint8list bytes)
```

### Basic Example
```dart
import 'dart:io';
import 'package:audio_meta/audio_meta.dart';

final meta = AudioMeta.fromFile(File('audio.mp3'));
print(meta.type); // AudioType.mp3
print(meta.sampleRate); // 44100
print(meta.bitRate); // 128000
print(meta.duration); // Duration(seconds: 180)
```

## Example Project
An example project can be found in the `example` folder of the repository.

## FAQ
Nothing here yet!

## Contribution
Feel free to support me by working on open issues,
or making a feature request / opening an issue.
