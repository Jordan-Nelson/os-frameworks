import 'dart:ffi';

import 'package:core_foundation_framework/core_foundation_framework.dart';
import 'package:ffi/ffi.dart';

extension CFDataRefX on CFDataRef {
  static final coreFoundation = CoreFoundation(DynamicLibrary.executable());

  /// Converts a [CFDataRef] to a Dart String.
  String? toDartString() {
    if (this == nullptr) return null;
    final bytePtr = coreFoundation.CFDataGetBytePtr(this);
    if (bytePtr == nullptr) return null;
    return bytePtr.cast<Utf8>().toDartString();
  }
}

extension CFStringPointerX on CFStringRef {
  static final coreFoundation = CoreFoundation(DynamicLibrary.executable());

  /// Converts a [CFStringRef] to a Dart String.
  String? toDartString() {
    if (this == nullptr) return null;
    final cStringPtr = coreFoundation.CFStringGetCStringPtr(
      this,
      kCFStringEncodingUTF8,
    );
    if (cStringPtr == nullptr) return null;
    return cStringPtr.cast<Utf8>().toDartString();
  }
}
