import 'dart:ffi';

import 'package:core_foundation_framework/core_foundation_framework.dart';
import 'package:ffi/ffi.dart';
import 'package:security_framework/security_framework.dart';

import 'exception.dart';
import 'utils.dart';

/// A wrapper around [Security] for performing basic KeyChain operations.
class KeyChain {
  const KeyChain({this.serviceName = 'com.example.app'});

  // static final security = Security(DynamicLibrary.executable());
  // static final coreFoundation = CoreFoundation(DynamicLibrary.executable());

  // The value of the service name attribute for all KeyChain items.
  final String serviceName;

  /// Write a key-value pair to KeyChain.
  void write({required String key, required String value}) {
    return using((Arena arena) {
      try {
        _add(key: key, value: value, arena: arena);
      } on DuplicateItemException {
        _update(key: key, value: value, arena: arena);
      }
    });
  }

  /// Read a key-value pair from KeyChain.
  String? read({required String key}) {
    return using((Arena arena) {
      try {
        return _getValue(key: key, arena: arena);
      } on ItemNotFoundException {
        return null;
      }
    });
  }

  /// Delete a key-value pair from KeyChain.
  void delete({required String key}) {
    using((Arena arena) {
      try {
        _remove(key: key, arena: arena);
      } on ItemNotFoundException {
        // do nothing if the item is not found
      }
    });
  }

  /// Updates an item in the KeyChain.
  ///
  /// throws [ItemNotFoundException] if the item is not in the KeyChain.
  void _update({
    required String key,
    required String value,
    required Arena arena,
  }) {
    final baseQueryAttributes = _getBaseAttributes(key: key, arena: arena);
    final query = _createCFDictionary(map: baseQueryAttributes, arena: arena);
    final data = _createCFData(value: value, arena: arena);
    final attributes = _createCFDictionary(
      map: {Security.instance.kSecValueData: data},
      arena: arena,
    );
    final status = Security.instance.SecItemUpdate(query, attributes);
    if (status != errSecSuccess) {
      throw _getExceptionFromResultCode(status);
    }
  }

  /// Adds a new item into the KeyChain.
  ///
  /// throws [DuplicateItemException] if an item with the same key
  /// is already present in the KeyChain
  void _add({
    required String key,
    required String value,
    required Arena arena,
  }) {
    final baseQueryAttributes = _getBaseAttributes(key: key, arena: arena);
    final secret = _createCFData(value: value, arena: arena);
    final query = _createCFDictionary(
      map: {
        ...baseQueryAttributes,
        Security.instance.kSecValueData: secret,
      },
      arena: arena,
    );
    final status = Security.instance.SecItemAdd(query, nullptr);
    if (status != errSecSuccess) {
      throw _getExceptionFromResultCode(status);
    }
  }

  /// Removes an item from the KeyChain.
  ///
  /// throws [ItemNotFoundException] if the item is not in the KeyChain.
  void _remove({
    required String key,
    required Arena arena,
  }) {
    final baseQueryAttributes = _getBaseAttributes(key: key, arena: arena);
    final query = _createCFDictionary(
      map: baseQueryAttributes,
      arena: arena,
    );
    final status = Security.instance.SecItemDelete(query);
    if (status != errSecSuccess) {
      throw _getExceptionFromResultCode(status);
    }
  }

  /// Returns the value for a given key in the KeyChain.
  ///
  /// throws [ItemNotFoundException] if the item is not in the KeyChain.
  String? _getValue({required String key, required Arena arena}) {
    final baseQueryAttributes = _getBaseAttributes(key: key, arena: arena);
    final query = _createCFDictionary(
      map: {
        ...baseQueryAttributes,
        Security.instance.kSecMatchLimit: Security.instance.kSecMatchLimitOne,
        Security.instance.kSecReturnData:
            CoreFoundation.instance.kCFBooleanTrue,
      },
      arena: arena,
    );
    final queryResult = arena<CFTypeRef>();
    final status = Security.instance.SecItemCopyMatching(query, queryResult);
    if (status != errSecSuccess) {
      throw _getExceptionFromResultCode(status);
    }
    try {
      final CFDataRef cfData = queryResult.value.cast();
      final value = cfData.toDartString();
      CoreFoundation.instance.CFRelease(cfData.cast());
      return value;
    } on Exception {
      throw UnknownException();
    }
  }

  /// Get the query attributes that are common to all queries.
  Map<Pointer<NativeType>, Pointer<NativeType>> _getBaseAttributes({
    required String key,
    required Arena arena,
  }) {
    final account = _createCFString(value: key, arena: arena);
    final service = _createCFString(value: serviceName, arena: arena);
    return {
      Security.instance.kSecClass: Security.instance.kSecClassGenericPassword,
      Security.instance.kSecAttrAccount: account,
      Security.instance.kSecAttrService: service,
    };
  }

  /// Creates a [CFDictionary] from a map of pointers, and registers
  /// a callback to release it from memory when the arena frees
  /// allocations.
  ///
  /// The attributes keys & values should be a pointer to a CF type such
  /// as Pointer<CFString> or Pointer<CFData>
  CFDictionaryRef _createCFDictionary({
    required Map<Pointer, Pointer> map,
    required Arena arena,
  }) {
    final keysPtr = arena<CFTypeRef>(map.length);
    final valuesPtr = arena<CFTypeRef>(map.length);
    var index = 0;
    for (final entry in map.entries) {
      keysPtr[index] = entry.key.cast();
      valuesPtr[index] = entry.value.cast();
      index++;
    }
    final cFDictionary = CoreFoundation.instance.CFDictionaryCreate(
      nullptr, // default allocator
      keysPtr,
      valuesPtr,
      map.length,
      nullptr, // no-op callback
      nullptr, // no-op callback
    );
    arena.onReleaseAll(() {
      CoreFoundation.instance.CFRelease(cFDictionary.cast());
    });
    return cFDictionary;
  }

  /// Creates a CFString Pointer from a Dart String and registers
  /// a callback to release it from memory when the arena frees
  /// allocations.
  CFStringRef _createCFString({
    required String value,
    required Arena arena,
  }) {
    final cfString = CoreFoundation.instance.CFStringCreateWithCString(
      nullptr, // default allocator
      value.toNativeUtf8(allocator: arena).cast<Char>(),
      kCFStringEncodingUTF8,
    );
    arena.onReleaseAll(() {
      CoreFoundation.instance.CFRelease(cfString.cast());
    });
    return cfString;
  }

  /// Creates a CFData Pointer from a Dart String and registers
  /// a callback to release it from memory when the arena frees
  /// allocations.
  CFDataRef _createCFData({
    required String value,
    required Arena arena,
  }) {
    final valuePtr = value.toNativeUtf8(allocator: arena);
    final length = valuePtr.length;
    final bytes = valuePtr.cast<UnsignedChar>();
    final cfData = CoreFoundation.instance.CFDataCreate(
      nullptr, // default allocator
      bytes,
      length,
    );
    arena.onReleaseAll(() {
      CoreFoundation.instance.CFRelease(cfData.cast());
    });
    return cfData;
  }

  /// Maps the result code to an [Exception].
  Exception _getExceptionFromResultCode(int code) {
    final securityFrameworkError = _SecurityFrameworkError.fromCode(code);
    return securityFrameworkError.toSecureStorageException();
  }
}

/// An error from the Security Framework.
class _SecurityFrameworkError {
  static final security = Security(DynamicLibrary.executable());
  static final coreFoundation = CoreFoundation(DynamicLibrary.executable());

  _SecurityFrameworkError({required this.code, required this.message});

  /// Creates an error from the given result code.
  factory _SecurityFrameworkError.fromCode(int code) {
    final cfString = Security.instance.SecCopyErrorMessageString(code, nullptr);
    if (cfString == nullptr) {
      return _SecurityFrameworkError(
        code: code,
        message: _noErrorStringMessage,
      );
    }
    try {
      final message = cfString.toDartString() ?? _noErrorStringMessage;
      return _SecurityFrameworkError(code: code, message: message);
    } on Exception {
      return _SecurityFrameworkError(
        code: code,
        message: 'The error string could not be parsed.',
      );
    } finally {
      if (cfString != nullptr) {
        CoreFoundation.instance.CFRelease(cfString.cast());
      }
    }
  }

  final int code;
  final String message;

  static const _noErrorStringMessage = 'No error string is available.';

  /// Maps the error to a [Exception].
  Exception toSecureStorageException() {
    print(toString());
    switch (code) {
      case errSecItemNotFound:
        return ItemNotFoundException();
      case errSecDuplicateItem:
        return DuplicateItemException();
      case errSecUserCanceled:
      case errSecAuthFailed:
      case errSecInteractionRequired:
        return AccessDeniedException();
      case errSecMissingEntitlement:
        return AccessDeniedException();
      default:
        return Exception();
    }
  }

  @override
  String toString() {
    return 'SecurityFrameworkError: {code: $code, message: $message}';
  }
}
