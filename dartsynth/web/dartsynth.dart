import 'dart:html';
import 'dart:web_audio';
import 'dart:typed_data';
import 'dart:math';
import 'knob.dart';

AudioContext actx;
Random rnd = new Random();

void main() {
  Knob knob = new Knob(querySelector("#knob"));
  knob.onChange.listen((d) => print(d));
  knob.value = 0.5;
  
  actx = new AudioContext();
  ScriptProcessorNode processor = actx.createScriptProcessor(512, 0, 2);
  processor.on['audioprocess'].listen(process);
  
  var osc = actx.createOscillator();
  osc..frequency.setValueAtTime(10, actx.currentTime);
  var gain = actx.createGain();
  gain.gain.setValueAtTime(200, actx.currentTime);
  osc.connectNode(gain);
  
  var filter = actx.createBiquadFilter();
  filter.type = 'bandpass';
  filter.frequency.setValueAtTime(1000, actx.currentTime);
  filter.Q.setValueAtTime(10, actx.currentTime);
  gain.connectParam(filter.frequency);
  
  processor.connectNode(filter);
  filter.connectNode(actx.destination);
  
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
