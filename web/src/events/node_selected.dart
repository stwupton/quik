import 'package:quik/level.dart';

import '../level_view.dart';

class NodeSelectedEvent {
  final Level level;
  final LevelView view;
  final int x;
  NodeSelectedEvent(this.x, this.view, this.level);
}
