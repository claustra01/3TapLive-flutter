import 'package:flutter/material.dart';

Widget profileIcon(final String ownerIcon, final double iconSize) {
  if (ownerIcon == '') {
    return SizedBox(
      width: iconSize,
      height: iconSize,
    );
  }
  return ClipOval(
    child: Image.network(
      ownerIcon,
      width: iconSize,
      height: iconSize,
    )
  );
}