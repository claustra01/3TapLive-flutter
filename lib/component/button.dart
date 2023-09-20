import 'package:flutter/material.dart';

Widget textButton(String text, Function func) {
  return ElevatedButton(
    onPressed: () {func();},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
    ),
    child: Text(text),
  );
}

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