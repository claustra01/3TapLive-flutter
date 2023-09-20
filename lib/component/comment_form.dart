import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentForm extends ConsumerStatefulWidget {
  final String channelName;
  const CommentForm({Key? key, required this.channelName}) : super(key: key);

  @override
  CommentFormState createState() => CommentFormState();
}

class CommentFormState extends ConsumerState<CommentForm> {
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                label: Text('Comment'),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              ),
              controller: commentController,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: ElevatedButton(
            onPressed: () {},
            child: const Icon(Icons.send),
          ),
        ),
      ],
    );
  }
}
