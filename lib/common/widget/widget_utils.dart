part of '../widget.dart';

Color genColor(String id) {
  final bytes = utf8.encode(id);
  final hash = sha256.convert(bytes);
  final hashBytes = hash.bytes;

  double red = hashBytes[0] / 255.0;
  double green = hashBytes[1] / 255.0;
  double blue = hashBytes[2] / 255.0;

  return Color.fromRGBO(
      (red * 255).round(), (green * 255).round(), (blue * 255).round(), 1);
}

extension StringExtension on String {
  String firstLetterUppercase() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}

extension ThemeOnWidget on BuildContext {
  BlokadaTheme get theme => Theme.of(this).extension<BlokadaTheme>()!;
}
