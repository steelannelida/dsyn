part of dsyn_gui;

class _RGB {
  int r;
  int g;
  int b;
  
  _RGB(this.r, this.g, this.b);
  String toString() {
    return "rgb($r,$g,$b)";
  }
}

class InputArrow {
  
  
  CanvasElement _canvas;
  
  double _minValue = -5.0;
  double _maxValue = 5.0;
  double _value = 0.0;
  double step = 0.01;
  
  String _direction = "right";
  
  String _lineColor = "black";
  
  List<_RGB> _colorCurve = [new _RGB(192,0,0), 
                            new _RGB(255, 255, 255), 
                            new _RGB(0, 0x66, 0)];

  StreamController _changeController = new StreamController();
  
  InputArrow(this._canvas) {
    draw();
    _canvas.onMouseDown.listen(_mouseDown);
    _canvas.onMouseUp.listen(_mouseUp);
    
  }
  double get value => _value;
         set value(double v) {
            _value = min(max(v, _minValue), _maxValue); 
            draw();
            _changeController.add(_value);
         }
  double get minValue => _minValue;
         set minValue(double v) {
           _minValue = v;
           if (value < minValue) {
             value = minValue;
           }
         }
  double get maxValue => _minValue;
         set maxValue(double v) {
           _minValue = v;
           if (value > maxValue) {
             value = maxValue;
           }
         }
  String get direction => _direction;
         set direction(String v) {
           switch(v) {
             case 'up': case 'down': case 'right': case 'left':
                _direction = v;
                draw();
                break;
             default:
               throw new Exception("Unsupported direction: " + v);
           }
         }
   
  Stream<double> get onChange => _changeController.stream;
         
  
  void draw() {
    CanvasRenderingContext2D ctx = _canvas.getContext("2d");
    num w = _canvas.width;
    num h = _canvas.height;
    num tip_x, tip_y;
    num side1x, side1y;
    num side2x, side2y;
    switch (_direction) {
      case "up":
        tip_x = w / 2;
        tip_y = 0;
        side1x = 0;
        side2x = w;
        side1y = side2y = h;
        break;
      case "down":
        tip_x = w / 2;
        tip_y = h;
        side1x = 0;
        side2x = w;
        side1y = side2y = 0;
        break;
      case "right":
        tip_x = w;
        tip_y = h / 2;
        side1x = side2x = 0;
        side1y = 0; 
        side2y = h;
        break;
      case "left":
        tip_x = 0;
        tip_y = h / 2;
        side1x = side2x = w;
        side1y = 0; 
        side2y = h;
        break;
      default:
        assert(false);
    }
    ctx.clearRect(0, 0, _canvas.width, _canvas.height);
    ctx.lineWidth = 1;
    ctx.strokeStyle = _lineColor;
    
    int curveIndex = min(((_colorCurve.length - 1) * (_value - _minValue) / (_maxValue - _minValue)).floor(), 
        _colorCurve.length - 2);
    double lbound = _minValue + curveIndex / (_colorCurve.length - 1) * (_maxValue - _minValue);
    double ubound = _minValue + (curveIndex + 1) / (_colorCurve.length - 1) * (_maxValue - _minValue);
    double sc = (_value - lbound) / (ubound - lbound);
    _RGB lc = _colorCurve[curveIndex];
    _RGB uc = _colorCurve[curveIndex + 1];
    _RGB color = new _RGB((uc.r * sc + lc.r * (1 - sc)).round(), 
                          (uc.g * sc + lc.g * (1 - sc)).round(),
                          (uc.b * sc + lc.b * (1 - sc)).round());
    ctx.fillStyle = color.toString();
    ctx.beginPath();
    ctx.moveTo(side1x, side1y);
    ctx.lineTo(tip_x, tip_y);
    ctx.lineTo(side2x, side2y);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
  }
  
  List<StreamSubscription<MouseEvent>> _subscriptions = [];

  bool _have_dragged = false;
  
  void _mouseDown(MouseEvent e) {
    if (e.button == 0) {
      _have_dragged = false;
      _subscriptions.add(document.onMouseMove.listen(_move));
      _subscriptions.add(document.onMouseUp.listen(_release));
      _subscriptions.add(document.onMouseLeave.listen(_release));
    }
  }

  void _mouseUp(MouseEvent event) {
    if (!_have_dragged) {
      if (value.abs() > 0.0001) {
        value = 0.0;
      } else {
        value = 1.0;
      }
    }
    _have_dragged = false;
  }
  
  void _move(MouseEvent e) {
    
    value -= step * e.movement.y;
    draw();
    _have_dragged = true;
  }
  
  void _release(MouseEvent e) {
    _subscriptions.forEach((StreamSubscription<MouseEvent> s) => s.cancel());
    _subscriptions.clear();
  }
  
  
}
