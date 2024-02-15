part of '../../widget.dart';

class FilterWidget extends StatefulWidget {
  final Filter filter;
  final FilterDecor texts;
  final Color? bgColor;

  const FilterWidget({
    super.key,
    required this.filter,
    required this.texts,
    this.bgColor,
  });

  @override
  State<StatefulWidget> createState() => FilterWidgetState();
}

class FilterWidgetState extends State<FilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(6, 6),
              ),
            ],
            gradient: LinearGradient(
              colors: [
                widget.bgColor ?? context.theme.bgColor,
                widget.bgColor?.lighten(12) ?? context.theme.bgColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
            )),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.texts.tags.join(", ").toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.theme.textSecondary,
                          )),
                  const SizedBox(height: 8.0),
                  Text(widget.texts.title,
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                  Text(
                    widget.texts.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: (widget.bgColor == null)
                    ? Colors.transparent
                    : Colors.white38,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: _buildFilterOptions(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterOptions(BuildContext context) {
    return widget.filter.options
        .map((it) {
          return <Widget>[
            FilterOptionWidget(
              option: it,
              selections: [],
            ),
            Divider(
                indent: 16,
                endIndent: 16,
                thickness: 0.4,
                height: 4,
                color: context.theme.divider),
          ];
        })
        .flatten()
        .toList()
        .dropLast(1);
  }
}
