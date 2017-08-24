import 'package:stagexl/stagexl.dart';

class BaseNode extends DisplayObjectContainer {
  bool _selected;
  num _radius;

  bool get selected => _selected;
  void set selected(bool selected) {
    _selected = selected;
    _draw();
  }

  BaseNode(this._radius, {bool selected}) {
    _selected = selected;
    _draw();
  }

  void _draw() {
    children.clear();
    Shape shape = new Shape();
    shape.graphics
      ..circle(0, 0, _radius)
      ..strokeColor(Color.White, 5);
    if (selected) {
      shape.graphics.fillColor(Color.White);
    }
    addChild(shape);
  }
}
