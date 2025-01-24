import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final void Function(String)? onFieldSubmitted;

  const TextFormFieldWidget({
    super.key,
    required this.text,
    required this.controller,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$text : "),
        SizedBox(
          height: 60,
          width: 300,
          child: TextFormField(
            controller: controller,
            onFieldSubmitted: onFieldSubmitted,
            decoration: InputDecoration(
                enabled: true,
                hintText: text,
                contentPadding: const EdgeInsets.only(left: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.green))),
          ),
        ),
      ],
    );
  }
}
