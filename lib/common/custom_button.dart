// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:whats_app_clone/common/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: tabColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            minimumSize: const Size(double.infinity, 50)),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ));
  }
}
