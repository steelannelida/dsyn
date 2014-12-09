import 'dart:html';
import '../gui/dsyn_gui.dart';


void main() {
  InputArrow inputTop = new InputArrow(querySelector("#inputtop"));
  inputTop.direction = 'down';
  InputArrow inputLeft = new InputArrow(querySelector("#inputleft"));
  inputLeft.direction = 'right';
  Knob knob = new Knob(querySelector("#knob"));
  knob.color2 = "#ff9900";
  knob.color = "#000000";
}
