import 'package:stagexl/stagexl.dart';

import 'colors.dart';

class CountdownView extends DisplayObjectContainer implements Animatable {
  Duration _currentDuration;
  final Duration duration;
  final num initialHeight;
  Function _onComplete;
  bool _stopping = false;

  void set onComplete(void x()) {
    _onComplete = x;
  }

  CountdownView(this.duration, num width, this.initialHeight) : super() {
    Shape background = new Shape();
    background.graphics
      ..rect(0, 0, width, initialHeight)
      ..fillColor(accent);
    addChild(background);

    mask = new Mask.rectangle(0, 0, width, height);
  }

  bool advanceTime(num time) {
    if (_stopping) {
      _stopping = false;
      return false;
    }
    _currentDuration += new Duration(seconds: time);
    if (_currentDuration >= duration) {
      if (_onComplete != null) _onComplete();
      return false;
    }
    Duration difference = duration - _currentDuration;

    num scaleBy = height / duration.inMilliseconds * difference.inMilliseconds;
    num moveBy = height / duration.inMilliseconds * _currentDuration.inMilliseconds;
    mask = new Mask.rectangle(0, moveBy, width, scaleBy);
    return true;
  }

  void increaseTimerBy(Duration x) {
    Duration zeroSeconds = new Duration(seconds: 0);
    if (_currentDuration - x < zeroSeconds) _currentDuration = zeroSeconds;
    else _currentDuration -= x;
  }

  void startTimer() {
    _stopping = false;
    resetTimer();
    stage.juggler.add(this);
  }

  void stopTimer() {
    _stopping = true;
    resetTimer();
  }

  void resetTimer() {
    _currentDuration = new Duration(seconds: 0);
    mask = new Mask.rectangle(0, 0, width, height);
  }
}
