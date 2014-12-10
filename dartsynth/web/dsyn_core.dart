library dsyn_core;
import 'dart:html';

class GridCell {
  GridCell(DivElement row) {
  }
}

class Grid {
  Element _parent;
  DivElement _element;
  
  int _row_count;
  int _col_count;
  
  
  List<Module> _modules = [];
  
  List<DivElement> _rows = [];
  List<List<GridCell>> _cells = [];
  
  Grid(this._parent, this._row_count, this._col_count) {
    _element = new DivElement();
    _element.classes.add("grid");
    _parent.children.add(_element);
    
    for (int r = 0; r < _row_count; ++r) {
      var row = new DivElement();
      row.classes.add("grid-row");
      _element.children.add(row);
      _rows.add(row);
      
      _cells.add([]);
      for (int c = 0; c < _col_count; ++c) {
        _cells[r].add(new GridCell(row));
      }
    }
  }

  void installModule(Module m, int row, int col, bool transposed) {
    
  }
  
  Module moduleAt(int row, int col);
  
  void uninstallModule(Module m);
}

abstract class VisibleItem {
  void install(Element parent);
  void installTransponed(Element parent) {
    install(parent);
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
  void addCell(int row, int col, Cell cell, bool transposed);

  void addLeftInput(int row, int col, Input input);
  void addTopInput(int row, int col, Input input);
  
  void addRightOutput(int row, int col, Output output);
  void addBottomOutput(int row, int col, Output output);
  
  void addCellControl(int row, int col, Control control);
}

class OffsetModuleMapper extends ModuleMapper {
  ModuleMapper _delegate;
  int _rowoff;
  int _coloff;
  
  OffsetModuleMapper(this._delegate, this._rowoff, this._coloff) {}
  
  @override
  void addBottomOutput(int row, int col, Output output) {
    _delegate.addBottomOutput(row + _rowoff, col + _coloff, output);
  }

  @override
  void addCell(int row, int col, Cell cell, bool transposed) {
    _delegate.addCell(row + _rowoff, col + _coloff, cell, transposed);
  }

  @override
  void addCellControl(int row, int col, Control control) {
    _delegate.addCellControl(row + _rowoff, col + _coloff, control);
  }

  @override
  void addLeftInput(int row, int col, Input input) {
    _delegate.addLeftInput(row + _rowoff, col + _coloff, input);
  }

  @override
  void addRightOutput(int row, int col, Output output) {
    _delegate.addRightOutput(row + _rowoff, col + _coloff, output);
  }

  @override
  void addTopInput(int row, int col, Input input) {
    _delegate.addTopInput(row + _rowoff, col + _coloff, input);
  }
}

class TransposeModuleMapper extends ModuleMapper {
  ModuleMapper _delegate;
  
  TransposeModuleMapper(this._delegate) {}
  
  @override
  void addBottomOutput(int row, int col, Output output) {
    _delegate.addRightOutput(col, row, output);
  }

  @override
  void addCell(int row, int col, Cell cell, bool transposed) {
    _delegate.addCell(col, row, cell, !transposed);
  }

  @override
  void addCellControl(int row, int col, Control control) {
    _delegate.addCellControl(col, row, control);
  }

  @override
  void addLeftInput(int row, int col, Input input) {
    _delegate.addTopInput(col, row, input);
  }

  @override
  void addRightOutput(int row, int col, Output output) {
    _delegate.addRightOutput(col, row, output);
  }

  @override
  void addTopInput(int row, int col, Input input) {
    _delegate.addLeftInput(col, row, input);
  }
}

class ValidateModuleMapper extends ModuleMapper {
  ModuleMapper _delegate;
  
  ValidateModuleMapper(this._delegate) {}
  
  @override
  void addBottomOutput(int row, int col, Output output) {
    _delegate.addRightOutput(col, row, output);
  }

  @override
  void addCell(int row, int col, Cell cell, bool transposed) {
    _delegate.addCell(col, row, cell, !transposed);
  }

  @override
  void addCellControl(int row, int col, Control control) {
    _delegate.addCellControl(col, row, control);
  }

  @override
  void addLeftInput(int row, int col, Input input) {
    _delegate.addTopInput(col, row, input);
  }

  @override
  void addRightOutput(int row, int col, Output output) {
    _delegate.addRightOutput(col, row, output);
  }

  @override
  void addTopInput(int row, int col, Input input) {
    _delegate.addLeftInput(col, row, input);
  }
}



abstract class ModuleType {
  Module makeDefault();
}

abstract class Module {
  void Map(ModuleMapper mapper);
}