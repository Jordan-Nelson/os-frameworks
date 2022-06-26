import 'dart:io';

const frameworkDir =
    '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/';

main() async {
  final dir = Directory(frameworkDir);
  final List<FileSystemEntity> entities = await dir.list().toList();
  final frameworks = entities
      .map((e) =>
          e.path.replaceFirst(frameworkDir, '').replaceFirst('.framework', ''))
      .toList();
  frameworks.sort();
  frameworks.forEach((name) {
    print('- [ ] $name');
  });
}
