import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double width;
  final double height;
  final double fontSize;


  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.deepPurple,
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height = 50.0,
    this.fontSize = 18.0,
  });


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

