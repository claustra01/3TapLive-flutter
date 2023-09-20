import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:hackz_tyranno/component/video_panel.dart';
import 'package:hackz_tyranno/component/dynamic_comments.dart';
import 'package:hackz_tyranno/component/comment_form.dart';
import 'package:hackz_tyranno/component/button.dart';
import 'package:hackz_tyranno/view/home.dart';

class StreamingAudiencePage extends ConsumerStatefulWidget {
  final String channelName;
  final String token;
  const StreamingAudiencePage({Key? key, required this.channelName, required this.token}) : super(key: key);

  @override
  StreamingAudiencePageState createState() => StreamingAudiencePageState();
}

class StreamingAudiencePageState extends ConsumerState<StreamingAudiencePage> {

  String appId = dotenv.get('AGORA_APP_ID');

  int uid = 0;

  int? _remoteUid;
  bool _isJoined = false;
  bool _isInitial = true;
  final bool _isHost = false;
  late RtcEngine agoraEngine;

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
    // create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(appId: appId));
    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  void _join() async {

    setState(() {
      _isInitial = false;
    });

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

  void _leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  void _redirectToHome() {
    // stop streaming
    _leave();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isJoined)
            Container(
              margin: const EdgeInsets.only(left: 5, right: 5),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              height: deviceHeight * 0.75,
              decoration: BoxDecoration(border: Border.all()),
              child: Center(
                child: Stack(
                    children: [
                      videoPanel(
                        agoraEngine,
                        widget.channelName,
                        uid,
                        _remoteUid,
                        _isHost,
                      ),
                      DynamicComments(channelName: widget.channelName),
                    ]
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(left: 5, right: 5),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              height: deviceHeight * 0.75,
              decoration: BoxDecoration(border: Border.all()),
              child: offVideoInfo(_isInitial),
            ),
          CommentForm(channelName: widget.channelName),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10, right:10),
                child: iconButton(Icons.arrow_back, _redirectToHome),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right:10),
                child: iconButton(Icons.play_circle_outline, _join),
              ),
            ]
          ),
        ],
      ),
    );
  }

}