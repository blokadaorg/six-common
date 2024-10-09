part of 'logger.dart';

class FileLoggerOutput extends LogOutput {
  late final _ops = dep<LoggerOps>();

  FileLoggerOutput() {
    const template = '''
\t\t\t
''';
    _ops.doUseFilename(getLogFilename());
  }

  @override
  void output(OutputEvent event) {
    if (kReleaseMode) {
      developer.log(
        "\n${event.lines.join("\n")}",
        time: event.origin.time,
        level: event.level.value,
      );
    } else {
      for (var line in event.lines) {
        print(line);
      }
    }

    // Save batch to file
    if (event.level == Level.trace && kReleaseMode) return;
    _ops.doSaveBatch(getLogFilename(), "${event.lines.join("\n")}\n");
  }
}

final _printer = PrefixPrinter(PrettyPrinter(
  colors: PlatformInfo().getCurrentPlatformType() != PlatformType.iOS,
  printEmojis: false,
  stackTraceBeginIndex: 0,
  methodCount: 2,
  errorMethodCount: 16,
  dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  excludePaths: ["package:common/logger"],
));
