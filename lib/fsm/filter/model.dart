class Filter {
  final String filterName;
  final List<Option> options;

  Filter(this.filterName, this.options);
}

class FilterSelection {
  final String filterName;
  final List<String> options;

  FilterSelection(this.filterName, this.options);

  @override
  String toString() =>
      "FilterSelection{filterName: $filterName, options: $options}";
}

class Option {
  final String optionName;
  final Action action;
  final List<String> actionParams;

  Option(this.optionName, this.action, this.actionParams);
}

enum Action { list, config }

enum FilterConfigKey { safeSearch }
