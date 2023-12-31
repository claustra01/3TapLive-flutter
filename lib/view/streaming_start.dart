import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hackz_tyranno/infrastructure/graphql.dart';
import 'package:hackz_tyranno/component/appbar.dart';
import 'package:hackz_tyranno/component/button.dart';
import 'package:hackz_tyranno/component/dialog.dart';
import 'package:hackz_tyranno/view/streaming_host.dart';

class StreamingStartPage extends ConsumerStatefulWidget {
  const StreamingStartPage({Key? key}) : super(key: key);

  @override
  StreamingStartPageState createState() => StreamingStartPageState();
}

class StreamingStartPageState extends ConsumerState<StreamingStartPage> {

  final titleController = TextEditingController();

  void _startStreaming() async {

    // input validation
    if (titleController.text == '') {
      if (!mounted) return;
      showAlertDialog(context, "Note", "Enter a title");
      return;
    } else if (titleController.text.length > 20) {
      if (!mounted) return;
      showAlertDialog(context, "Note", "Title is too long");
      return;
    }

    // build graphql query
    User? user = FirebaseAuth.instance.currentUser;
    final String query = """
      mutation {
        createChannel(title: "${titleController.text}", ownerName: "${user?.displayName}", ownerIcon: "${user?.photoURL}") {
          name
          token
          title
          ownerName
          ownerIcon
        }
      }
    """;

    final response = await fetchGraphql(query);
    if (response != null) {
      // create new streaming
      final data = response.data['createChannel'];
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StreamingHostPage(channelName: data['name'], token: data['token'])), (_) => false);
    } else {
      // view error dialog
      if (!mounted) return;
      showAlertDialog(context, "Error", "Server error");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Let\'s start!'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(32),
              child: TextField(
                decoration: const InputDecoration(
                  label: Text('Streaming Title'),
                  border: OutlineInputBorder(),
                ),
                controller: titleController,
              ),
            ),
            textButton('Streaming start!', _startStreaming),
          ],
        ),
      ),
    );
  }

}