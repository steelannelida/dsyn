part of dsyn_gui;

class Knob {
  CanvasElement _canvas;
  
  double _minValue = 0.0;
  double _maxValue = 1.0;
  double _value = 0.0;
  
  double step = 0.003;
  
  
  String _color = "black";
  String _grayColor = "darkgray";

  StreamController _changeController = new StreamController();
  
  Knob(this._canvas) {
    draw();
    _canvas.onMouseDown.listen(_mouseDown);
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
  String get color => _color;
         set color(String v) {
           _color = v;
           draw();
         }
  String get color2 => _grayColor;
         set color2(String v) {
           _grayColor = v;
           draw();
         }
   
  Stream<double> get onChange => _changeController.stream;
         
  
  void draw() {
    CanvasRenderingContext2D ctx = _canvas.getContext("2d");
    num w = _canvas.clientWidth;
    num h = _canvas.clientHeight;
    num r = min(w, h) / 2 - 5;
    num c_x = w / 2;
    num c_y =  w/ 2;
    num angle = (_value - _minValue) / (_maxValue - _minValue) * 1.5 * PI + 0.75 * PI;

    ctx.clearRect(0, 0, w, h);
    ctx.lineWidth = r ~/ 20;
    ctx.strokeStyle = _color;
    ctx.beginPath();
    ctx.arc(c_x, c_y, r, 0.75 * PI, angle);
    ctx.lineTo(c_x, c_y);
    ctx.stroke();

    ctx.strokeStyle = _grayColor;
    ctx.beginPath();
    ctx.arc(c_x, c_y, r, 2.25 * PI, angle, true);
    ctx.stroke();
  }
  
  List<StreamSubscription<MouseEvent>> _subscriptions = [];
  
  void _mouseDown(MouseEvent e) {
    if (e.button == 0) {
      _subscriptions.add(document.onMouseMove.listen(_move));
      _subscriptions.add(document.onMouseUp.listen(_release));
      _subscriptions.add(document.onMouseLeave.listen(_release));
    }
  }


  
  void _move(MouseEvent e) {
    value -= step * e.movement.y;
    draw();
  }
  
  void _release(MouseEvent e) {
    _subscriptions.forEach((StreamSubscription<MouseEvent> s) => s.cancel());
    _subscriptions.clear();
  }
}
