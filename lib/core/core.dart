import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension_importer/i18n_extension_importer.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

part 'config/act.dart';
part 'config/config.dart';
part 'config/platform_info.dart';
part 'di.dart';
part 'emitter.dart';
part 'i18n.dart';
part 'logger/logger.dart';
part 'logger/marker.dart';
part 'logger/output.dart';
part 'logger/trace.dart';
part 'persistence.dart';
part 'scheduler.dart';
part 'util/async.dart';
part 'util/json.dart';
part 'util/list_extensions.dart';