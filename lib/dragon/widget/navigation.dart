import 'package:common/common/model.dart';
import 'package:common/common/widget/common_clickable.dart';
import 'package:common/common/widget/theme.dart';
import 'package:common/custom/custom.dart';
import 'package:common/dragon/journal/controller.dart';
import 'package:common/dragon/route.dart';
import 'package:common/dragon/widget/device/device_screen.dart';
import 'package:common/dragon/widget/dialog.dart';
import 'package:common/dragon/widget/filters_section.dart';
import 'package:common/dragon/widget/home/home_screen.dart';
import 'package:common/dragon/widget/home/top_bar.dart';
import 'package:common/dragon/widget/settings/exceptions_section.dart';
import 'package:common/dragon/widget/settings/settings_screen.dart';
import 'package:common/dragon/widget/stats/stats_detail_section.dart';
import 'package:common/dragon/widget/stats/stats_section.dart';
import 'package:common/dragon/widget/with_top_bar.dart';
import 'package:common/util/di.dart';
import 'package:common/util/trace.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Paths {
  home("/", false),
  device("/device", false),
  deviceFilters("/device/filters", true),
  deviceStats("/device/stats", true),
  deviceStatsDetail("/device/stats/detail", true),
  settings("/settings", false),
  settingsExceptions("/settings/exceptions", true);

  final String path;
  final bool openInTablet;

  const Paths(this.path, this.openInTablet);
}

bool isTabletMode(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth > 1000;
}

const maxContentWidth = 500.0;
const maxContentWidthTablet = 1500.0;

double getTopPadding(BuildContext context) {
  final topPadding = MediaQuery.of(context).padding.top;
  final noNotch = topPadding < 30;
  return (noNotch ? 100 : 68); // I don't get it either
}

class Navigation with TraceOrigin {
  late final journal = dep<JournalController>();
  late final _custom = dep<CustomStore>();

  static Function(Paths, Object?) openInTablet = (_, __) {};

  static open(BuildContext context, Paths path, {Object? arguments}) async {
    final isTablet = isTabletMode(context);
    if (isTablet && path.openInTablet) {
      openInTablet(path, arguments);
      return;
    }

    final ctrl = Provider.of<TopBarController>(context, listen: false);
    ctrl.navigatorKey.currentState!.pushNamed(path.path, arguments: arguments);
  }

  StandardRoute generateRoute(BuildContext context, RouteSettings settings,
      {Widget? homeContent}) {
    if (settings.name == Paths.device.path) {
      final device = settings.arguments as FamilyDevice;
      return StandardRoute(
          settings: settings,
          builder: (context) => DeviceScreen(tag: device.device.deviceTag));
    }

    if (settings.name == Paths.deviceStats.path) {
      final device = settings.arguments as FamilyDevice;

      return StandardRoute(
        settings: settings,
        builder: (context) => WithTopBar(
          title: "Activity",
          topBarTrailing: _getStatsAction(context, device.device.deviceTag),
          child: StatsSection(deviceTag: device.device.deviceTag),
        ),
      );
    }

    if (settings.name == Paths.deviceFilters.path) {
      final device = settings.arguments as FamilyDevice;

      return StandardRoute(
        settings: settings,
        builder: (context) => WithTopBar(
          title: "Blocklists",
          child: FiltersSection(profileId: device.profile.profileId),
        ),
      );
    }

    if (settings.name == Paths.deviceStatsDetail.path) {
      final entry = settings.arguments as UiJournalEntry;

      return StandardRoute(
        settings: settings,
        builder: (context) => WithTopBar(
          title: "Details",
          child: StatsDetailSection(entry: entry),
        ),
      );
    }

    if (settings.name == Paths.settings.path) {
      return StandardRoute(
          settings: settings, builder: (context) => SettingsScreen());
    }

    if (settings.name == Paths.settingsExceptions.path) {
      return StandardRoute(
        settings: settings,
        builder: (context) => WithTopBar(
          title: "My exceptions",
          topBarTrailing: _getExceptionsAction(context),
          child: ExceptionsSection(),
        ),
      );
    }

    return StandardRoute(
        settings: settings,
        builder: (context) => homeContent ?? const HomeScreen());
  }

  Widget? _getStatsAction(BuildContext context, DeviceTag tag) {
    return CommonClickable(
        onTap: () {
          showStatsFilterDialog(context, onConfirm: (filter) {
            journal.filter = filter;
            journal.fetch(tag);
          });
        },
        child: Text(
          "Search",
          style: TextStyle(
            color: context.theme.accent,
            fontSize: 17,
          ),
        ));
  }

  Widget? _getExceptionsAction(BuildContext context) {
    return CommonClickable(
        onTap: () {
          showAddExceptionDialog(context, onConfirm: (entry) {
            traceAs("addCustom", (trace) async {
              await _custom.allow(trace, entry);
            });
          });
        },
        child: Text(
          "Add",
          style: TextStyle(
            color: context.theme.accent,
            fontSize: 17,
          ),
        ));
  }
}
