import 'dart:math';

import 'package:quik/node.dart';

class Level {
  final int columns;
  final int rows;
  List<List<Node>> _nodes;

  List<List<Node>> get nodes => new List.from(_nodes);

  Level(this.columns, this.rows) {
    _generate();
  }

  void _generate() {
    // Create node list.
    _nodes = new List.generate(columns,
        (_) => new List.generate(rows, (_) => new Node(), growable: false),
        growable: false);

    // Create random order to generate the nodes in.
    List<int> xOrder = new List.generate(columns, (int i) => i, growable: false)
      ..shuffle();

    for (int x in xOrder) {
      if (x + 1 == columns) continue;

      Random r = new Random();
      int toPick = (rows / 2).round();
      for (int i = 0; i < toPick; i++) {
        int y = r.nextInt(rows);

        // Get random node.
        Node n = _nodes[x][y];

        // Get previous node.
        Node pn;
        if (x == 0) pn = new Node();
        else pn = _nodes[x - 1][y];

        // Get next node.
        Node nn = _nodes[x + 1][y];

        if (n.redirects || pn.redirects || nn.redirects)
          continue;

        _nodes[x][y] = new Node(redirects: true);
      }
    }
  }

  int getWinningColumn(int x) {
    for (int y = 0; y < rows; y++) {
      int direction = 0;

      // Check if this node redirects.
      if (_nodes[x][y].redirects)
        direction = 1;

      // Check if the node to the left redirects.
      else if (x != 0 && _nodes[x - 1][y].redirects) direction = -1;

      x += direction;
    }

    return x;
  }
}
