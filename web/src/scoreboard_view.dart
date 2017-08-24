import 'package:cookie/cookie.dart' as cookie;
import 'package:stagexl/stagexl.dart';

import 'sounds.dart';

class ScoreboardView extends DisplayObjectContainer {
  List<TextField> _texts = [];
  int _currentScore;
  int _bestScore;
  bool _soundPlayed = false;

  ScoreboardView() : super() {
    String score = cookie.get('best_score');
    if (score == null) _bestScore = 0;
    else _bestScore = int.parse(score);
  }

  void increment() {
    _currentScore ??= 0;
    _currentScore++;
    _updateText(_currentScore);

    if (_currentScore > _bestScore) {
      if (!_soundPlayed) {
        highScore.play();
        _soundPlayed = true;
      }

      _bestScore = _currentScore;
      cookie.set('best_score', _bestScore.toString(),
          expires: new DateTime.now().toUtc().add(new Duration(days: 365 * 5)));
    }
  }

  void registerText(TextField text) {
    _texts.add(text);
  }

  void showBest() {
    _soundPlayed = false;
    _currentScore = 0;
    _updateText(_bestScore);
  }

  void _updateText(int score) {
    for (TextField text in _texts) {
      text.text = score.toString();
    }
  }
}
