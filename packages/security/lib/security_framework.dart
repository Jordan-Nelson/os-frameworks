import 'dart:ffi';

import 'src/security.bindings.dart' as security;

export 'src/security.bindings.dart' hide SecurityBindings;

/// Bindings for the Security Framework.
///
/// Framework Documentation: https://developer.apple.com/documentation/security
class Security extends security.SecurityBindings {
  Security(super.dynamicLibrary);
  static final instance = Security(DynamicLibrary.executable());
}
