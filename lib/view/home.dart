import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hackz_tyranno/infrastructure/graphql.dart';

import 'package:hackz_tyranno/component/channel_info.dart';
import 'package:hackz_tyranno/component/dialog.dart';
import 'package:hackz_tyranno/view/auth.dart';
import 'package:hackz_tyranno/view/streaming_start.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  dynamic channelList;

  void _getChannels() async {

    // build query
    const String query = """
      query {
        getChannelList {
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
      setState(() {
        channelList = response.data['getChannelList'];
      });
    } else {
      // view error dialog
      if (!mounted) return;
      showAlertDialog(context, "Error", "Server error");
    }

  }

  void _redirectToStartPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StreamingStartPage()), (_) => false);
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()), (_) => false);
    } catch (e) {
      // view error dialog
      if (!mounted) return;
      showAlertDialog(context, "Error", "Logout failed");
    }
  }

  @override
  void initState() {
    _getChannels();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Application for Tyranno-Cup'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: channelList != null ? channelList.length : 0,
          itemBuilder: (BuildContext context, int index) {
            final channelData = channelList[index];
            return channelPanel(context, channelData);
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              heroTag: 'startStreamButton',
              onPressed: _redirectToStartPage,
              child: const Icon(Icons.video_call_outlined),
            ),
          ),
          FloatingActionButton(
            heroTag: 'logoutButton',
            onPressed: _logout,
            child: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
