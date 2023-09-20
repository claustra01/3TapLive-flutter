import 'package:flutter/material.dart';

Widget closeButton(double margin, Function func) {
  return Container(
    alignment: Alignment.topLeft,
    margin: EdgeInsets.all(margin),
    child: FloatingActionButton(
      onPressed: () {func();},
      child: const Icon(Icons.close),
    ),
  );
}