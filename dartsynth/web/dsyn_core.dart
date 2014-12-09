library dsyn_core;
import 'dart:html';



class Grid {
  Element _parent;
  DivElement _element;
  
  int _row_count;
  int _col_count;
  
  List<DivElement> _rows = [];
  List<List<DivElement>> _cells = [];
  
  List<Module> _modules = [];
  List<List<Module>> _cellIndex = [];
  List<List<Cell>> _cellDivs = [];
  
  
  
  Grid(this._parent, this._row_count, this._col_count) {
    _element = new DivElement();
    _element.classes.add("grid");
    _parent.children.add(_element);
    
  }
  
  void installModule(Module m, int row, int col, bool transposed);
  bool canInstallModule(Module m, int row, int col, bool transposed);
  
  Module moduleAt(int row, int col);
  
  void uninstallModule(Module m);
}

abstract class VisibleItem {
  void install(Element parent);
  void installTransponed(Element parent) {
    install(element);
  }
  void uninstall();
  
  void draw();
}

abstract class Cell extends VisibleItem {
  
}

abstract class Input extends VisibleItem {
  void acceptConnection(Connection connection);
}

abstract class Connection {
  void disconnect();
}

abstract class Output extends VisibleItem {
  Connection makeConnection(); 
}

abstract class Control extends VisibleItem {
  
}

class Context {
  
}

abstract class ModuleMapper {
  void addCell(int row, int col, Cell cell);

  void addLeftInput(int row, int col, Input input);
  void addTopInput(int row, int col, Input input);
  
  void addRightOutput(int row, int col, Output output);
  void addBottomOutput(int row, int col, Output output);
  
  void addCellControl(int row, int col, Control control);
}

abstract class ModuleType {
  Module makeDefault();
}

abstract class Module {
  void Map(ModuleMapper mapper);
}