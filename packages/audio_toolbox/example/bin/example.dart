import 'dart:ffi';

import 'package:audio_toolbox/audio_toolbox_framework.dart';

final audioToolbox = AudioToolbox(DynamicLibrary.executable());
main() async {
  for (var i = 0; i < 4; i++) {
    for (var i = 0; i < 4; i++) {
      await Future.delayed(Duration(milliseconds: 250));
      audioToolbox.AudioServicesPlayAlertSound(
        kSystemSoundID_UserPreferredAlert,
      );
    }
    for (var i = 0; i < 8; i++) {
      await Future.delayed(Duration(milliseconds: 125));
      audioToolbox.AudioServicesPlayAlertSound(
        kSystemSoundID_UserPreferredAlert,
      );
    }
  }
}
