part of 'logger.dart';

class FileLoggerOutput extends LogOutput {
  late final _channel = Core.get<LoggerChannel>();

  FileLoggerOutput() {
    const template = '''
\t\t\t
''';
    _channel.doUseFilename(getLogFilename());
  }

  String getLogFilename() {
    final type = PlatformInfo().getCurrentPlatformType();
    final platform = type == PlatformType.iOS
        ? "i"
        : (type == PlatformType.android ? "a" : "z");
    final flavor = Core.act.isFamily ? "F" : "6";
    final build = Core.act.isRelease ? "R" : "D";

    return "blokada-$platform${flavor}x$build.log";
  }

  @override
  void output(OutputEvent event) {
    // if (kReleaseMode) {
    //   developer.log(
    //     "\n${event.lines.join("\n")}",
    //     time: event.origin.time,
    //     level: event.level.value,
    //   );
    // } else {
    for (var line in event.lines) {
      print(line);
    }
    // }

    // Save batch to file
    if (event.level == Level.trace && Core.act.isRelease) return;
    _channel.doSaveBatch("${event.lines.join("\n")}\n");
  }
}
