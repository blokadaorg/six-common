import 'package:common/common/module/customlist/customlist.dart';
import 'package:common/common/module/journal/journal.dart';
import 'package:common/common/navigation.dart';
import 'package:common/common/widget/common_divider.dart';
import 'package:common/common/widget/stats/activity_item.dart';
import 'package:common/common/widget/theme.dart';
import 'package:common/core/core.dart';
import 'package:common/family/module/device_v3/device.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class StatsSection extends StatefulWidget {
  final DeviceTag? deviceTag;
  final bool primary;

  const StatsSection({Key? key, required this.deviceTag, this.primary = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StatsSectionState();
}

class StatsSectionState extends State<StatsSection> with Disposables {
  late final _journal = DI.get<JournalActor>();
  late final _filter = DI.get<JournalFilterValue>();
  late final _entries = DI.get<JournalEntriesValue>();
  late final _customlist = DI.get<CustomlistPayloadValue>();

  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    disposeLater(_filter.onChange.listen(rebuild));
    disposeLater(_entries.onChange.listen(rebuildEntries));

    _customlist.onChange.listen(rebuild);
    rebuild(null);
  }

  @override
  rebuild(dynamic it) async {
    if (!mounted) return;
    await _journal.fetch(Markers.stats, tag: widget.deviceTag);
  }

  rebuildEntries(dynamic it) {
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        primary: widget.primary,
        children: [
              SizedBox(height: getTopPadding(context)),
              Container(
                decoration: BoxDecoration(
                  color: context.theme.bgMiniCard,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                height: 12,
              ),
            ] +
            (!_isReady || _entries.now.isEmpty
                ? _buildEmpty(context)
                : _buildItems(context)) +
            [
              Container(
                decoration: BoxDecoration(
                  color: context.theme.bgMiniCard,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
                ),
                height: 12,
              ),
            ],
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    return _entries.now.mapIndexed((index, it) {
      return Container(
        color: context.theme.bgMiniCard,
        child: Column(children: [
          ActivityItem(entry: it),
          index < _entries.now.length - 1
              ? const CommonDivider(indent: 60)
              : Container(),
        ]),
      );
    }).toList();
  }

  List<Widget> _buildEmpty(BuildContext context) {
    return [
      Container(
        color: context.theme.bgMiniCard,
        child: Center(
          child: Text(
            (!_isReady || _journal.allEntries.isEmpty)
                ? "universal status waiting for data".i18n
                : "family search empty".i18n,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];
  }
}
