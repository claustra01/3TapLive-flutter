import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StreamingAudiencePage extends ConsumerStatefulWidget {
  final String name;
  final String token;
  const StreamingAudiencePage({Key? key, required this.name, required this.token}) : super(key: key);

  @override
  StreamingAudiencePageState createState() => StreamingAudiencePageState();
}

class StreamingAudiencePageState extends ConsumerState<StreamingAudiencePage> {

  @override
  Widget build(BuildContext context) {
    return Text(widget.name);
  }

}