import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

import 'package:hackz_tyranno/infrastructure/graphql.dart';

class DynamicComments extends ConsumerStatefulWidget {
  final String channelName;
  const DynamicComments({Key? key, required this.channelName}) : super(key: key);

  @override
  DynamicCommentsState createState() => DynamicCommentsState();
}

class DynamicCommentsState extends ConsumerState<DynamicComments> {

  List<String> comments = [];
  WebSocketChannel? subscription;

  WebSocketChannel? connectSubscription() {
    final String connId = const Uuid().v4().toString();
    final String query = """
      subscription {
        comments(channel: \\"${widget.channelName}\\") {
          body
          owner
        }
      }
    """;
    final channel = connectGqlSubscription(query, connId);
    return channel;
  }

  @override
  void initState() {
    super.initState();
    subscription = connectSubscription();
    subscription?.stream.listen((data) {
      setState(() {
        comments.add(data);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('こんにちは'),
        Text('コメントの数: ${comments.length}'),
        Expanded(
          child: ListView.builder(
            itemCount: comments.length,
            itemBuilder: (BuildContext context, int index) {
              final commentData = comments[index];
              return Text(commentData);
            },
          ),
        ),
      ],
    );
  }
}