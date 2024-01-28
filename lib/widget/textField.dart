// ignore_for_file: file_names

import 'package:flutter/material.dart';

class FormText extends StatelessWidget {
  final String label;
  final TextEditingController? controller;

  const FormText({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: false,
        fillColor: const Color.fromARGB(
            255, 255, 255, 255), // Change the background color here
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          borderRadius: BorderRadius.circular(60),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 94, 197, 212),
          ),
          borderRadius: BorderRadius.circular(60),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 94, 197, 212),
          ),
          borderRadius: BorderRadius.circular(60),
        ),
        labelText: label,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 94, 197, 212),
        ),
      ),
    );
  }
}
