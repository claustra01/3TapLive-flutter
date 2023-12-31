import 'package:flutter/material.dart';

import 'package:hackz_tyranno/component/image.dart';
import 'package:hackz_tyranno/view/streaming_audience.dart';

Widget channelPanel(BuildContext context, final channelData) {

  return InkWell(
    onTap: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StreamingAudiencePage(channelName: channelData['name'], token: channelData['token'])), (_) => false);
    },
    child: Container(
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade600,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children:[
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: profileIcon(channelData['ownerIcon'], 50),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, top: 5, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${channelData['title']}',
                      style: const TextStyle(fontSize: 25.0),
                    ),
                    Text(
                      '${channelData['ownerName']}',
                      style: const TextStyle(fontSize: 15.0),
                    ),
                  ],
                )
              ),
            ]
          ),
        ],
      )
    )
  );
}

