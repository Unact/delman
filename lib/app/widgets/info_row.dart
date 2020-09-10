import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final Widget title;
  final Widget trailing;

  InfoRow({
    Key key,
    this.title,
    this.trailing
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: title
              )
            ),
          ),
          Flexible(
            child: Container(
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
