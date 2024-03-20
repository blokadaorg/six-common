import 'package:common/common/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

import '../../common/defaults/filter_decor_defaults.dart';
import '../../common/model.dart';
import '../../common/widget/family/home/top_bar.dart';
import '../../util/config.dart';
import '../../util/di.dart';

class EditProfileSheet extends StatefulWidget {
  final String profile;

  const EditProfileSheet({Key? key, required this.profile}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditProfileSheetState();
}

class EditProfileSheetState extends State<EditProfileSheet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    Provider.of<TopBarController>(context, listen: false)
        .updateScrollPos(_scrollController.offset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.bgColorCard,
      body: Container(
        color: context.theme.bgColor,
        child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 100),
              Column(
                children: [
                  Text("Parent",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                  Text("Edit name",
                      style: TextStyle(color: context.theme.family)),
                ],
              ),
              GestureDetector(
                  onTap: () {
                    Provider.of<TopBarController>(context, listen: false)
                        .goNext("Profiles ${++counter}");
                  },
                  child:
                      _buildFilter(context, 0, color: const Color(0xFFA9CCFE))),
              GestureDetector(
                  onTap: () {
                    Provider.of<TopBarController>(context, listen: false)
                        .goBack();
                  },
                  child: _buildFilter(context, 1)),
              _buildFilter(context, 2, color: const Color(0xFFF4B1C6)),
              _buildFilter(context, 3, color: const Color(0XFFFDB39C)),
              _buildFilter(context, 4),
              _buildFilter(context, 5),
              _buildFilter(context, 6),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text("Delete this profile",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              SizedBox(height: 48),
            ]),
      ),
      //),
    );
  }

  Widget _buildFilter(BuildContext context, int index, {Color? color}) {
    final filter = getKnownFilters(cfg.act)[index];
    final texts = filterDecorDefaults
        .firstWhere((it) => it.filterName == filter.filterName);
    return FilterWidget(filter: filter, texts: texts, bgColor: color);
  }
}
