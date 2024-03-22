import 'package:common/journal/channel.pg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../widget.dart';

class ActivityItem extends StatefulWidget {
  final JournalEntry entry;

  const ActivityItem({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ActivityItemState();
}

class ActivityItemState extends State<ActivityItem> {
  @override
  Widget build(BuildContext context) {
    return Touch(
      //onLongTap: () => _copyEntry(entry.tld, context),
      onTap: () {
        Navigator.of(context)
            .pushNamed("/device/stats/detail", arguments: widget.entry);
      },
      decorationBuilder: (value) {
        return BoxDecoration(
          color: context.theme.bgColorHome3.withOpacity(value),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            widget.entry.isBlocked()
                ? Container(
                    color: Colors.red,
                    width: 4,
                    height: 52,
                  )
                : Container(width: 4),
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(CupertinoIcons.shield,
                    color: widget.entry.isBlocked() ? Colors.red : Colors.green,
                    size: 52),
                Transform.translate(
                  offset: const Offset(0, -3),
                  child: Text(
                    (widget.entry.requests > 99)
                        ? "99"
                        : widget.entry.requests.toString(),
                    style: TextStyle(
                        color: context.theme.textPrimary, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.entry.domainName,
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis),
                  Text(
                    widget.entry.time,
                    style: TextStyle(
                        color: context.theme.textSecondary, fontSize: 12),
                  ),
                  Text(
                    (widget.entry.isBlocked() ? "blocked" : "allowed") +
                        " ${widget.entry.requests} times",
                    style: TextStyle(
                        color: context.theme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: context.theme.divider,
            )
          ],
        ),
      ),
    );
  }
}
