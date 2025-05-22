## 1.0.0

- Initial version. Support for mp3, wav, aac, ogg, flac.

## 1.0.1
- Replaced calls to Isolate with Futures to ensure web compat
- Updated readme

## 1.0.2
- Updated readme to clarify package usage

## 1.0.3
- Audio type & encoding extraction now single pass
- Updated readme disclaimer to show early development status

## 1.1.0
- Fixed grave bugs when distinguishing encodings based on header sync words

## 1.1.1
- Added web support
- Added byte indexing guards to avoid range exceptions
- Fixed bug where VBR MP3s would be read as CBR
- Improved extraction speed through seek offsets
- Deleted deprecated source files
- Updated readme

### 1.1.2
- Added web support (frfr)
