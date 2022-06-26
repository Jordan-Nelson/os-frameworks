import 'dart:ffi';

import 'src/audio_toolbox.bindings.dart' as audio_toolbox;

export 'src/audio_toolbox.bindings.dart' hide AudioToolbox;

/// Bindings for the AudioToolbox Framework.
///
/// Framework Documentation: https://developer.apple.com/documentation/audiotoolbox
class AudioToolbox extends audio_toolbox.AudioToolbox {
  AudioToolbox(super.dynamicLibrary);
  static final instance = AudioToolbox(DynamicLibrary.executable());
}
