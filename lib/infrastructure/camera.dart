import 'package:agora_rtc_engine/agora_rtc_engine.dart';

enum CameraType {
  cameraRear,
  cameraFront,
}


Future<CameraType> switchCameraType(RtcEngine agoraEngine, CameraType type) async {

  // switch camera type
  switch(type) {
    case CameraType.cameraRear:
      type = CameraType.cameraFront;
    case CameraType.cameraFront:
      type = CameraType.cameraRear;
  }

  if (type == CameraType.cameraRear) {
    await agoraEngine.setCameraCapturerConfiguration(
        const CameraCapturerConfiguration(
            cameraDirection: CameraDirection.cameraRear
        )
    );
  }

  if (type == CameraType.cameraFront) {
    await agoraEngine.setCameraCapturerConfiguration(
        const CameraCapturerConfiguration(
            cameraDirection: CameraDirection.cameraFront
        )
    );
  }

  return type;
}