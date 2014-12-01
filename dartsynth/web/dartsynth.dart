import 'dart:html';
import 'dart:web_audio';
import 'dart:typed_data';
import 'dart:math';

AudioContext actx;
Random rnd = new Random();

void main() {
  actx = new AudioContext();
  ScriptProcessorNode processor = actx.createScriptProcessor(512, 0, 2);
  processor.on['audioprocess'].listen(process);
  
  var filter = actx.createBiquadFilter();
  filter.type = 'lowpass';
  filter.frequency.setValueAtTime(1000, actx.currentTime);
  filter.Q.setValueAtTime(0.1, actx.currentTime);
  
  processor.connectNode(filter);
  filter.connectNode(actx.destination);
}

class Knob {
  CanvasElement _canvas;
  
  double minValue = 0.0;
  double maxValue = 1.0;
  double value = 0.0;
  double step = 0.01;
  
  String color = "black";
  String bgcolor = "white";
  
  Knob(this._canvas) {
    draw();
  }
  
  void draw() {
    CanvasRenderingContext2D ctx = _canvas.getContext("2d");
    num size = min(_canvas.width, _canvas.height);
    ctx.strokeStyle = color;
    ctx.arc(_canvas.width / 2, _canvas.height/ 2 , size / 2, 0, 2 * PI);
  }
}



void process(AudioProcessingEvent e) {
  AudioBuffer buffer = e.outputBuffer;
  for (int c = 0; c < buffer.numberOfChannels; c++) {
    Float32List data = buffer.getChannelData(c);
    for (int i = 0; i < data.length; i++) {
      data[i] = rnd.nextDouble() - 0.5;
    }
  }
}
