import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

Widget videoPanel(RtcEngine agoraEngine, String channelName, int uid, int? remoteUid, bool isHost) {
  if (isHost) {
    // Show local video preview
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine,
        canvas: VideoCanvas(uid: uid),
      ),
    );
  } else {
    // Show remote video
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

Widget offVideoInfo(bool isInit) {
  if (isInit) {
    return const Center(
      child: Text(
        'Press the play button',
        style: TextStyle(
          fontSize: 25,
        ),
      ),
    );
  } else {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
