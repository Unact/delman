import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final Widget? title;
  final Widget? trailing;

  const InfoRow({
    Key? key,
    this.title,
    this.trailing
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Flexible(
            child: SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: title
              )
            ),
          ),
          Flexible(
            child: SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing
              )
            )
          )
        ]
      ),
    );
  }
}
