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

Widget iconButton(IconData icon, Function func) {
  return ElevatedButton(
    onPressed: () {func();},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
    ),
    child: Icon(icon),
  );
}
