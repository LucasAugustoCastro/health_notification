import 'dart:ffi';

import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  MyTextField({
    Key? key,
    required this.fieldName,
    required this.myController,
    this.myIcon = Icons.verified_user_outlined,
    this.prefixIconColor = Colors.blueAccent,
    this.obscureText = false,
  });
  final TextEditingController myController;
  String fieldName;
  final IconData myIcon;
  Color prefixIconColor;
  bool obscureText;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: myController,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: fieldName,
            prefixIcon: Icon(myIcon),
            // prefixIcon: Icon(myIcon, color: prefixIconColor),
            border: const OutlineInputBorder(),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: Colors.deepPurple.shade300),
            // ),
            // labelStyle: const TextStyle(color: Colors.deepPurple)
          ),
        ),
        const SizedBox(height: 16), // Espaço de 16 pixels
      ],
    );
  }
}
