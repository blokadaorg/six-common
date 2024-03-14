part of '../widget.dart';

mixin ViaTools<T extends StatefulWidget> on State<T> {
  rebuild() => setState(() {});
}

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

class StandardRoute extends MaterialWithModalsPageRoute {
  StandardRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
}

void showInputDialog(
  BuildContext context, {
  required String title,
  required String desc,
  required String inputValue,
  required Function(String) onConfirm,
}) {
  final TextEditingController _ctrl = TextEditingController(text: inputValue);

  showDefaultDialog(
    context,
    title: Text(title),
    content: Column(
      children: [
        Text(desc),
        const SizedBox(height: 16),
        Material(
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: context.theme.panelBackground,
              focusColor: context.theme.panelBackground,
              hoverColor: context.theme.panelBackground,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.divider, width: 1.0),
                borderRadius: BorderRadius.circular(2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.divider, width: 1.0),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Cancel"),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          onConfirm(_ctrl.text);
        },
        child: const Text("Save"),
      ),
    ],
  );
}

void showDefaultDialog(
  context, {
  required Text title,
  required Widget content,
  required List<Widget> actions,
}) {
  Platform.isIOS || Platform.isMacOS
      ? showCupertinoDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions,
          ),
        )
      : showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) => AlertDialog(
            title: title,
            content: content,
            actions: actions,
          ),
        );
}
