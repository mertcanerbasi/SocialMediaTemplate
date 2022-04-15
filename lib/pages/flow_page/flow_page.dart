import 'package:flutter/material.dart';

class FlowPage extends StatefulWidget {
  const FlowPage({Key? key}) : super(key: key);

  @override
  State<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends State<FlowPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Flow Page'),
    );
  }
}
