library dsyn_web_audio;
import 'dsyn_core.dart';
import 'dart:web_audio';

class WAConnection extends Connection {
  final AudioNode node;
  final int output;

  WAConnection(this.node, this.output) {
    
  }
}

class WANodeInput extends Input {
  final AudioNode node;
  final int input;
  
  WANodeInput(this.node, this.input) {}
  
  WAConnection _connection = null;
  
  @override
  void acceptConnection(Connection connection) {
    assert(connection is WAConnection);
    assert(_connection == null);
    _connection = connection;
    _connection.node.connectNode(node, _connection.output, input);
  }

  @override
  Connection get connection => _connection;

  @override
  void disconnect() {
    assert(_connection != null);
    _connection.node.disconnect(_connection.output);
    _connection = null;    
  }
}

class WAParamInput extends Input {
  final AudioParam param;
  
  
  WAParamInput(this.param);

  WAConnection _connection = null;

  @override
  void acceptConnection(Connection connection) {
    assert(connection is WAConnection);
    assert(_connection == null);
    _connection = connection;
    _connection.node.connectParam(param, _connection.output);
  }
  
  @override
  Connection get connection => _connection;

  @override
  void disconnect() {
    assert(_connection != null);
    _connection.node.disconnect(_connection.output);
    _connection = null;    
  }
}

class WAOutput extends Output {
  final AudioNode node;
  final int output;
  
  WAOutput(this.node, this.output);


  @override
  WAConnection issueConnection() {
    return new WAConnection(node, output);
  }
  
}