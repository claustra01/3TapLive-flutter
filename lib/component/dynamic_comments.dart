import 'dart:convert';

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
        comments.insert(0, data);
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.white],
                stops: [0.0, 0.75],
              ).createShader(bounds);
            },
            child: ListView.builder(
              itemCount: comments.length,
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                final commentData = jsonDecode(comments[index]);
                if (commentData['type'] == 'data') {
                  final data = commentData['payload']['data']['comments'];
                  return _commentBox(data['owner'], data['body']);
                }
                return const SizedBox();
              },
            ),
          )
        ),
      ],
    );
  }
}

Widget _commentBox(String owner, String body) {
  return Container(
    margin: const EdgeInsets.only(left: 10, bottom: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          owner,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
          ),
        ),
        Text(
          body,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ]
    ),
  );
}
