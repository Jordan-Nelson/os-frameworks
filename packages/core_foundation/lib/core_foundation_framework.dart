import 'dart:ffi';

import 'src/core_foundation.bindings.dart' as core_foundation;

export 'src/core_foundation.bindings.dart' hide CoreFoundationBindings;

/// Bindings for the CoreFoundation Framework.
///
/// Framework Documentation: https://developer.apple.com/documentation/corefoundation
class CoreFoundation extends core_foundation.CoreFoundationBindings {
  CoreFoundation(super.dynamicLibrary);
  static final instance = CoreFoundation(DynamicLibrary.executable());
}
