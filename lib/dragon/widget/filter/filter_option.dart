import 'package:common/common/defaults/filter_option_decor_defaults.dart';
import 'package:common/common/model.dart';
import 'package:common/common/widget/string.dart';
import 'package:common/common/widget/theme.dart';
import 'package:common/dragon/widget/two_letter_icon.dart';
import 'package:flutter/cupertino.dart';

class FilterOptionWidget extends StatefulWidget {
  final Option option;
  final List<String> selections;
  final Function(bool) onSelect;

  const FilterOptionWidget(
      {super.key,
      required this.option,
      required this.selections,
      required this.onSelect});

  @override
  State<StatefulWidget> createState() => FilterOptionWidgetState();
}

class FilterOptionWidgetState extends State<FilterOptionWidget> {
  bool selected = false;

  @override
  void initState() {
    super.initState();
    selected = widget.selections.contains(widget.option.optionName);
  }

  @override
  void didUpdateWidget(FilterOptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      selected = widget.selections.contains(widget.option.optionName);
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        child: Container(
            child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              TwoLetterIconWidget(name: widget.option.optionName, big: true),
              const SizedBox(width: 12.0),
              Text(_getDecor(widget.option.optionName)),
              Expanded(child: Container()),
              CupertinoSwitch(
                activeColor: context.theme.accent,
                value: selected,
                onChanged: (bool? value) {
                  setState(() {
                    selected = value!;
                    widget.onSelect(selected);
                  });
                },
              ),
            ],
          ),
        )),
      );

  String _getDecor(String option) {
    return filterOptionDecorDefaults[option] ?? option.firstLetterUppercase();
  }
}