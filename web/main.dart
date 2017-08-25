import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:stagexl/stagexl.dart';

import 'package:quik/level.dart';

import 'src/colors.dart';
import 'src/countdown_view.dart';
import 'src/level_reel.dart';
import 'src/level_view.dart';
import 'src/scoreboard_view.dart';
import 'src/sounds.dart';

// Stage properties.
final num height = 1920;
final num width = 1080;

// Level properties.
final num levelPaddingX = 40;
final num levelPaddingY = 80;

String getProperty(String key, [String defaultValue]) =>
    Uri.base.queryParameters[key] ?? defaultValue;

// Level properties.
int get columns => int.parse(getProperty('columns', '3'));
int get rows => int.parse(getProperty('rows', '2'));

// Timer properties.
num get totalSeconds => num.parse(getProperty('totalSeconds', '6'));
num get appendingSeconds => num.parse(getProperty('appendingSeconds', '.6'));

// Create level reel.
final LevelReel levelReel = new LevelReel();

// Create dummy level view to get base node radius.
final LevelView dummyLevel = new LevelView(new Level(columns, rows),
    width - levelPaddingX * 2, height - levelPaddingY * 2);
final num baseNodeRadius = dummyLevel.baseNodeRadius;

// Create countdown view.
final CountdownView countdownView = new CountdownView(
    new Duration(seconds: totalSeconds), width, height)
  ..alignPivot(HorizontalAlign.Left, VerticalAlign.Bottom)
  ..y = height;

final ScoreboardView scoreboard = new ScoreboardView();

Future main() async {
  // Preload sounds.
  swish = await Sound.load('sounds/swish.mp3');
  wrong = await Sound.load('sounds/wrong.mp3');
  highScore = await Sound.load('sounds/high_score.mp3');

  // Create canvas.
  CanvasElement canvas = new CanvasElement(width: width, height: height);
  document.body.nodes = [canvas];

  // Set stage default options.
  Stage.defaultOptions
    ..antialias = true
    ..stageScaleMode = StageScaleMode.EXACT_FIT
    ..backgroundColor = base;

  // Create StageXL context.
  Stage stage = new Stage(canvas);
  RenderLoop loop = new RenderLoop();
  loop.addStage(stage);

  // Pick a random column to start from.
  int startingColumn = new Random().nextInt(columns);

  // Create levels.
  Level currentLevel;
  int totalLevels = 10;

  // Boolean to maintain state if game is being played or not.
  bool playing = false;

  void _restart() {
    playing = false;
    wrong.play();
    countdownView.stopTimer();
    scoreboard.showBest();
  }

  TextFormat scoreTextFormat = new TextFormat('Share Tech Mono', height / 3,
      accent, align: TextFormatAlign.CENTER,
      verticalAlign: TextFormatVerticalAlign.CENTER);

  // Create background score text.
  TextField scoreText1 = new TextField('0', scoreTextFormat)
    ..width = width
    ..height = height;
  scoreboard.registerText(scoreText1);
  stage.addChild(scoreText1);

  // Create foreground score text for countdown view.
  scoreTextFormat.color = base;
  TextField scoreText2 = new TextField('0', scoreTextFormat)
    ..width = width
    ..height = height;
  scoreboard.registerText(scoreText2);

  // Update scoreboard with initial score.
  scoreboard.showBest();

  // Add countdown to stage;
  countdownView.onComplete = _restart;
  countdownView.addChild(scoreText2);
  stage.addChild(countdownView);

  // Add level reel to stage.
  stage.addChild(levelReel);

  // Number to keep track of the level reels y position.
  num currentReelY = 0;
  void _onNodeSelectedCallback(NodeSelectedEvent e) {
    if (e.view.hasSelected) return;

    if (currentLevel.getWinningColumn(startingColumn) == e.x) {
      e.view.select(e.x);
      startingColumn = e.x;

      swish.play();

      if (!playing) {
        countdownView.startTimer();
        playing = true;
      }

      // Move levels to show next level.
      Tween moveLevelTween = new Tween(levelReel, .28,
          Transition.easeOutQuartic);
      currentReelY -= e.view.height;
      moveLevelTween.animate.y.to(currentReelY);
      stage.juggler.add(moveLevelTween);

      countdownView.increaseTimerBy(new Duration(seconds: appendingSeconds));
      scoreboard.increment();

      int i = levelReel.getChildIndex(e.view);
      if (i > 2) {
        LevelView levelView = _appendLevel(totalLevels++,
            new Level(columns, rows));
        levelReel.removeChildAt(0);
        levelView.onNodeSelected.listen(_onNodeSelectedCallback);
      }

      currentLevel = e.level;
    } else {
      _restart();
    }
  }

  for (int i = 0; i < totalLevels; i++) {
    Level level = new Level(columns, rows);
    LevelView levelView = _appendLevel(i, level, i == 0 ? startingColumn : null);
    if (i == 0) currentLevel = level;

    levelView.onNodeSelected.listen(_onNodeSelectedCallback);
  }
}

LevelView _appendLevel(int i, Level level, [int startingColumn]) {
  LevelView levelView = new LevelView(level, width - levelPaddingX * 2,
      height - (levelPaddingY + baseNodeRadius) * 2,
      preSelected: startingColumn);
  levelView
    ..x = levelPaddingX
    ..y = levelPaddingY + levelView.height * i;
  levelReel.addChild(levelView);
  return levelView;
}
