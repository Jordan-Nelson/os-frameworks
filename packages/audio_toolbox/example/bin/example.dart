import 'package:audio_toolbox_framework/audio_toolbox_framework.dart';

main() async {
  for (var i = 0; i < 4; i++) {
    for (var i = 0; i < 4; i++) {
      await Future.delayed(Duration(milliseconds: 250));
      AudioToolbox.instance.AudioServicesPlayAlertSound(
        kSystemSoundID_UserPreferredAlert,
      );
    }
    for (var i = 0; i < 8; i++) {
      await Future.delayed(Duration(milliseconds: 125));
      AudioToolbox.instance.AudioServicesPlayAlertSound(
        kSystemSoundID_UserPreferredAlert,
      );
    }
  }
}
