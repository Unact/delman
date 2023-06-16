import 'package:flutter/material.dart';

class ExpandingText extends StatefulWidget {
  final String content;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ExpandingText(this.content, {
    Key? key,
    this.style,
    this.textAlign
  }) : super(key: key);

  @override
  ExpandingTextState createState() => ExpandingTextState();
}

class ExpandingTextState extends State<ExpandingText> {
  static const int _kLimit = 40;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: RichText(
        textAlign: widget.textAlign ?? TextAlign.right,
        text: TextSpan(
          children: [
            TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 13).merge(widget.style),
              text: widget.content.length > _kLimit && !_showAll ?
                widget.content.substring(0, _kLimit) :
                widget.content
            ),
            widget.content.length <= _kLimit ? const TextSpan() : WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAll = true;
                  });
                },
                child: Text(
                  _showAll ? '' : '...',
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            )
          ]
        )
      )
    );
  }
}
