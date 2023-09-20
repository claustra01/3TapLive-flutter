import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hackz_tyranno/infrastructure/graphql.dart';
import 'package:hackz_tyranno/component/dialog.dart';

class CommentForm extends ConsumerStatefulWidget {
  final String channelName;
  const CommentForm({Key? key, required this.channelName}) : super(key: key);

  @override
  CommentFormState createState() => CommentFormState();
}

class CommentFormState extends ConsumerState<CommentForm> {
  final commentController = TextEditingController();

  void _sendComment() async {

    // input validation
    if (commentController.text == '') {
      if (!mounted) return;
      showAlertDialog(context, "Note", "Enter a Comment");
      return;
    } else if (commentController.text.length > 60) {
      if (!mounted) return;
      showAlertDialog(context, "Note", "Comment is too long");
      return;
    }

    // build graphql query
    User? user = FirebaseAuth.instance.currentUser;
    final String query = """
      mutation {
        createComment(body: "${commentController.text}", channel: "${widget.channelName}", owner: "${user?.displayName}") {
          body
        }
      }
    """;

    // fetch graphql api
    // なぜか2回叩くと上手くいく
    final response = await fetchGraphql(query);
    final response2 = await fetchGraphql(query);
    if (response != null && response2 != null) {
      commentController.clear();
    } else {
      if (!mounted) return;
      showAlertDialog(context, "Error", "Server error");
    }

  }

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
            onPressed: _sendComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.indigo,
            ),
            child: const Icon(Icons.send),
          ),
        ),
      ],
    );
  }
}
