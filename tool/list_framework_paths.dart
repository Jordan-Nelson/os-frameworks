import 'dart:io';

const frameworkDir =
    '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/';

main() async {
  final dir = Directory(frameworkDir);
  final List<FileSystemEntity> entities = await dir.list().toList();
  entities.forEach((element) {
    final frameworkName = element.path
        .replaceFirst(frameworkDir, '')
        .replaceFirst('.framework', '');
    print('- "$frameworkDir$frameworkName.framework/Headers/$frameworkName.h"');
  });
}
