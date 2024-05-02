import 'package:flutter/material.dart';

class TextWithIconLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final String text;

  const TextWithIconLabel(
      {super.key, required this.label, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 36,
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.headlineSmall),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
        ),
      ],
    );
  }
}
