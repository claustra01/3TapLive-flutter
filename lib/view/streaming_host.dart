import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:hackz_tyranno/component/video_panel.dart';
import 'package:hackz_tyranno/view/home.dart';

class StreamingHostPage extends ConsumerStatefulWidget {
  final String channelName;
  final String token;
  const StreamingHostPage({Key? key, required this.channelName, required this.token}) : super(key: key);

  @override
  StreamingHostPageState createState() => StreamingHostPageState();
}

class StreamingHostPageState extends ConsumerState<StreamingHostPage> {

  String appId = dotenv.get('AGORA_APP_ID');

  int uid = 0;

  int? _remoteUid;
  bool _isJoined = false;
  final bool _isHost = true;
  late RtcEngine agoraEngine;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey
  = GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    super.initState();
    setupVideoSDKEngine();

  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    super.dispose();
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(
        appId: appId
    ));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage("Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  void join() async {

    // Set channel options
    ChannelMediaOptions options;

    // Set channel profile and client role
    if (_isHost) {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await agoraEngine.startPreview();
    } else {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
    }

    await agoraEngine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  void _redirectToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          children: [
            if (_isJoined)
              Container(
                height: 480,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(
                  child: videoPanel(
                    agoraEngine,
                    widget.channelName,
                    uid,
                    _remoteUid,
                    _isHost,
                  ),
                ),
              )
            else
              Container(
                height: 480,
                decoration: BoxDecoration(border: Border.all()),
                child: const Center(
                  child: Text('Press start button'),
                )
              ),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    child: const Text("Start"),
                    onPressed: () => {join()},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    child: const Text("Stop"),
                    onPressed: () => {leave()},
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.all(30),
          child: FloatingActionButton(
            onPressed: _redirectToHome,
            child: const Icon(Icons.close),
          ),
        ),
      ),
    );
  }

}