import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StreamingHostPage extends ConsumerStatefulWidget {
  final String name;
  final String token;
  const StreamingHostPage({Key? key, required this.name, required this.token}) : super(key: key);

  @override
  StreamingHostPageState createState() => StreamingHostPageState();
}

class StreamingHostPageState extends ConsumerState<StreamingHostPage> {

  @override
  Widget build(BuildContext context) {
    return Text(widget.name);
  }

}