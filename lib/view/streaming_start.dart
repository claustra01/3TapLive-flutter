import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hackz_tyranno/infrastructure/graphql.dart';
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
      showAlertDialog(context, "Error", "Enter a title");
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
      print(response);
      final data = response.data['createChannel'];
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => StreamingHostPage(channelName: data['name'], token: data['token'])));
    } else {
      // view error dialog
      if (!mounted) return;
      showAlertDialog(context, "Error", "Server error");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Streaming'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
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
            ElevatedButton(
                onPressed: _startStreaming,
                child: const Text('Streaming Start!')
            ),
          ],
        ),
      ),
    );
  }

}