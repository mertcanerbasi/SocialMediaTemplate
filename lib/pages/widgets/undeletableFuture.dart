import 'package:flutter/material.dart';

import '../../models/users.dart';

class UndeletableFutureBuilder extends StatefulWidget {
  final Future<AppUsers?> future;
  final AsyncWidgetBuilder builder;
  const UndeletableFutureBuilder({Key? key, required this.future, required this.builder}) : super(key: key);

  @override
  State<UndeletableFutureBuilder> createState() => _UndeletableFutureBuilderState();
}

class _UndeletableFutureBuilderState extends State<UndeletableFutureBuilder> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<AppUsers?>(
      future: widget.future,
      builder: widget.builder,
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
