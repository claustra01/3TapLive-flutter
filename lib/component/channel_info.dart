import 'package:flutter/material.dart';

import 'package:hackz_tyranno/component/image.dart';
import 'package:hackz_tyranno/view/streaming_audience.dart';

Widget channelPanel(BuildContext context, final channelData) {

  return InkWell(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StreamingAudiencePage(channelName: channelData['name'], token: channelData['token'])));
    },
    child: Container(
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Column(
        children: [
          Row(
              children:[
                Container(
                  margin: const EdgeInsets.only(left: 7),
                  child: profileIcon(channelData['ownerIcon'], 60),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${channelData['title']}',
                          style: const TextStyle(fontSize: 35.0),
                        ),
                        Text(
                          '${channelData['ownerName']}',
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ],
                    )
                )
              ]
          ),
        ],
      )
    )
  );
}

