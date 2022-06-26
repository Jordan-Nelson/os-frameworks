import 'dart:convert';
import 'dart:io';

import '../key_chain.dart';

enum InputMode {
  read,
  write,
  delete,
}

final keyChain = KeyChain();

Future<void> main() async {
  InputMode? inputMode;

  while (inputMode == null) {
    final rawInput = _prompt(
      'Would you like to read (r), write (w), or delete (d): ',
    );
    final input = rawInput[0].toLowerCase();
    if (input == 'r') {
      inputMode = InputMode.read;
    } else if (input == 'w') {
      inputMode = InputMode.write;
    } else if (input == 'd') {
      inputMode = InputMode.delete;
    }
  }

  switch (inputMode) {
    case InputMode.read:
      _read();
      break;
    case InputMode.write:
      _write();
      break;
    case InputMode.delete:
      _delete();
      break;
  }
}

void _read() {
  final key = _prompt('Enter the key to read: ');

  final value = keyChain.read(key: key);

  stdout.writeln('The value of $key is $value');
}

void _write() {
  final key = _prompt('Enter the key to write to: ');
  final value = _prompt('Enter the value to write: ');

  keyChain.write(key: key, value: value);

  stdout.writeln('Wrote $key:$value to KeyChain.');
}

void _delete() {
  final key = _prompt('Enter the key to delete: ');

  keyChain.delete(key: key);

  stdout.writeln('The value of $key has been deleted.');
}

String _prompt(String prompt) {
  String? value;
  while (value == null) {
    stdout.write(prompt);
    value = stdin.readLineSync(encoding: utf8);
  }
  return value;
}
