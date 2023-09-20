import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

PreferredSizeWidget customAppBar(BuildContext context, String text) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: Text(
      text,
      style: GoogleFonts.delaGothicOne(
        fontSize: 30,
      ),
    ),
  );
}