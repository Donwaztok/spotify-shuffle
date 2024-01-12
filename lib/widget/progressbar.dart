import 'dart:async';

import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  final int duration;

  const ProgressBar({super.key, required this.duration});

  @override
  // ignore: library_private_types_in_public_api
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  int _progress = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_progress == widget.duration) {
            timer.cancel();
          } else {
            _progress = _progress + 1000;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      color: Colors.green,
      value: _progress / widget.duration,
    );
  }
}
