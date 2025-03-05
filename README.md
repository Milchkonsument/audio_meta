# audio_meta
### Lightweight audio metadata extraction library.

* 💯 100% cross-platform
* 💯 100% pure dart
* 🙅‍♂️ 0 dependencies
* ✅ Uniform metadata for all audio file types

### Current Support For:
* 🔊 mp3
* 🔊 wav
* 🔊 aac
* 🔊 ogg
* 🔊 flac
* 🚧 m4a
* 🚧 wma
* 🚧 mp4

### Metadata Available Through This Package:
* 🔊 Track Duration
* 🔊 Sample Rate
* 🔊 Bit Rate
* 🔊 Bit Depth
* 🔊 Channel Count
* 🔊 Encoding
* more to come

## Getting Started
### Get from pub.dev
```
dart pub add audio_meta
```

### Include in Project
```
import 'package:audio_meta/audio_meta.dart';
```

### Constructors
```
// sync
AudioMeta.fromFile(File file)
AudioMeta.fromPath(String path)
AudioMeta.fromBytes(Uint8list bytes)

// async (not blocking main isolate for large files)
AudioMeta.fromFileAsync(File file)
AudioMeta.fromPathAsync(String path)
AudioMeta.fromBytesAsync(Uint8list bytes)
```

### Basic Example
```
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
Feel free to support me and work on open issues by making a pull request.

## Consider Donating
I'd be really grateful if you could support my work. Thanks.
[ko-fi](https://ko-fi.com/milchkonsument)
[paypal](https://www.paypal.com/paypalme/Milchbub)
