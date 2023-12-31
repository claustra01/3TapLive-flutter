import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:hackz_tyranno/infrastructure/graphql.dart';
import 'package:hackz_tyranno/infrastructure/camera.dart';

import 'package:hackz_tyranno/component/video_panel.dart';
import 'package:hackz_tyranno/component/dynamic_comments.dart';
import 'package:hackz_tyranno/component/comment_form.dart';
import 'package:hackz_tyranno/component/button.dart';
import 'package:hackz_tyranno/component/dialog.dart';
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
  bool _isInitial = true;
  final bool _isHost = true;
  CameraType _cameraType = CameraType.cameraRear;
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
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    // create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(appId: appId));
    await agoraEngine.enableVideo();

    // set rear camera
    await agoraEngine.setCameraCapturerConfiguration(
      const CameraCapturerConfiguration(
        cameraDirection: CameraDirection.cameraRear
      )
    );

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

  void _switchCamera() async {
    // only when joined
    if (!_isJoined) return;

    _leave();
    // switch camera
    CameraType type = await switchCameraType(agoraEngine, _cameraType);
    setState(() {
      _cameraType = type;
    });
    _join();
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

  void _removeChannel() async {
    // stop streaming
    _leave();

    // build query
    final String query = """
      query {
        deleteChannel(name: "${widget.channelName}")
      }
    """;

    final response = await fetchGraphql(query);
    if (response != null) {
      if (response.data['deleteChannel'] == true) {
        _redirectToHome();
      }
    } else {
      // view error dialog
      if (!mounted) return;
      showAlertDialog(context, "Error", "Server error");
    }
  }

  void _redirectToHome() {
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
                child: iconButton(Icons.arrow_back, _removeChannel),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right:10),
                child: iconButton(Icons.play_circle_outline, _join),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right:10),
                // TODO: add switch camera feature
                child: iconButton(Icons.switch_video_outlined, _switchCamera),
              ),
            ]
          ),
        ],
      ),
    );
  }

}