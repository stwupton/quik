import 'dart:async';

import 'package:stagexl/stagexl.dart';

import 'package:quik/level.dart';

import 'base_node.dart';
import 'colors.dart';
import 'events/node_selected.dart';

export 'events/node_selected.dart';

class LevelView extends DisplayObjectContainer {
  List<BaseNode> _baseNodes = [];
  final num baseNodePaddingX = 30;
  num _baseNodeRadius;
  StreamController<NodeSelectedEvent> _nodeSelectedController =
      new StreamController.broadcast();
  final num controlNodeRadius = 12;
  final num height;
  final Level level;
  final num width;

  num get baseNodeRadius => _baseNodeRadius;
  bool get hasSelected =>
      _baseNodes.where((BaseNode bn) => bn.selected).isNotEmpty;
  Stream<NodeSelectedEvent> get onNodeSelected =>
      _nodeSelectedController.stream;

  LevelView(this.level, this.width, this.height, {int preSelected}) : super() {
    // Calculate the radius of the base nodes.
    _baseNodeRadius =
        (width - (baseNodePaddingX * 2 * level.columns)) / level.columns / 2;

    // Calculate the x positions of the nodes in each column.
    final List<num> baseNodeXPositions =
        new List.generate(level.columns, (int i) {
      num start = (baseNodeRadius + baseNodePaddingX) * 2 * i;
      return start + baseNodePaddingX + baseNodeRadius;
    });

    // Get the spacing that's inbetween node columns.
    final num nodeSpacing = baseNodeXPositions[1] - baseNodeXPositions[0];

    // Draw level.
    for (int x = 0; x < level.columns; x++) {
      // Create top node.
      BaseNode baseNode =
          new BaseNode(baseNodeRadius, selected: preSelected == x)
            ..alignPivot()
            ..x = baseNodeXPositions[x]
            ..y = baseNodeRadius;
      _baseNodes.add(baseNode);
      addChild(baseNode);

      GlassPlate glassPlate = new GlassPlate(baseNode.width, baseNode.height)
        ..alignPivot()
        ..x = baseNode.x
        ..y = baseNode.y;
      addChild(glassPlate);

      if (preSelected == null) {
        glassPlate.onMouseDown.listen((MouseEvent _) {
          _nodeSelectedController.add(new NodeSelectedEvent(x, this, level));
        });
      }

      // Draw line.
      num lineStart = baseNodeRadius * 2;
      num lineLength = height - baseNodeRadius * 2;
      Shape line = new Shape()
        ..alignPivot()
        ..x = baseNodeXPositions[x]
        ..y = lineStart;
      line.graphics
        ..beginPath()
        ..moveTo(0, 0)
        ..lineTo(0, lineLength)
        ..closePath()
        ..strokeColor(primary, 5);
      addChild(line);

      // Get the spacing between each row of control nodes.
      num controlNodeY = lineLength / (level.rows + 1);

      // Draw control flow nodes.
      for (int y = 0; y < level.rows; y++) {
        num yPosition = lineStart + controlNodeY * (y + 1);
        Shape controlNode = new Shape()
          ..alignPivot()
          ..x = baseNodeXPositions[x]
          ..y = yPosition;
        controlNode.graphics
          ..circle(0, 0, controlNodeRadius)
          ..fillColor(primary);
        addChild(controlNode);

        if (level.nodes[x][y].redirects) {
          Shape flowLine = new Shape()
            ..alignPivot()
            ..x = baseNodeXPositions[x]
            ..y = yPosition;
          flowLine.graphics
            ..beginPath()
            ..moveTo(0, 0)
            ..lineTo(nodeSpacing, 0)
            ..closePath()
            ..strokeColor(primary, 5);
          addChild(flowLine);
        }
      }
    }
  }

  void select(int x) {
    _baseNodes[x].selected = !_baseNodes[x].selected;
  }
}
