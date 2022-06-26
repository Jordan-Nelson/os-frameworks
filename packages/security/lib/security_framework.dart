import 'dart:ffi';

import 'src/security.bindings.dart' as security;

export 'src/security.bindings.dart' hide Security;

/// Bindings for the Security Framework.
///
/// Framework Documentation: https://developer.apple.com/documentation/security
class Security extends security.Security {
  Security(super.dynamicLibrary);
  static final instance = Security(DynamicLibrary.executable());
}
