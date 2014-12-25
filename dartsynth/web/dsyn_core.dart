library dsyn_core;
import 'dart:async';

abstract class Module {
  Map<Pos, ModuleCell> get cells;
  
  Module clone();
}

abstract class ModuleCell {
  final Module module;
  
  final Input leftInput;
  final Input topInput;
  final Output rightOutput;
  final Output bottomOutput;
  
  final CellControl cellControl;
  
  ModuleCell(this.module, 
      this.leftInput, 
      this.topInput,
      this.rightOutput,
      this.bottomOutput,
      this.cellControl);
}

abstract class Connection {
  
}


abstract class Input {
  void acceptConnection(Connection connection);
  void disconnect();
  Connection get connection;
}


abstract class Output {
  Connection issueConnection();
}

abstract class CellControl {
  
}

class Pos {
  final int row;
  final int col;
  
  const Pos(this.row, this.col);
  
  bool operator ==(other) {
    if (other is !Pos) {
      return false;
    }
    return row == other.row && col == other.col;
  }
  
  int get hashCode => row.hashCode * 29 + col.hashCode;
  
  @override 
  String toString() {
    return "{$row, $col}";
  }
  
  Pos get right => new Pos(row, col + 1);
  Pos get left => new Pos(row, col - 1);
  Pos get up => new Pos(row - 1, col);
  Pos get down => new Pos(row + 1, col);
}

abstract class Grid {
  GridCell getCell(Pos pos);
  Iterable<Pos> get cellPositions;
  Iterable<ModuleGridInstallation> get installations;
  
  ModuleGridInstallation install(Module module, Pos pos, bool transposed);
  void uninstall(ModuleGridInstallation installation);
}

class ModuleGridInstallation {
  final Module module;
  final Pos pos;
  final bool transposed;
  
  ModuleGridInstallation(this.module, this.pos, this.transposed);
}

abstract class GridCell {
  ModuleCell get moduleCell;
  bool get isTransposed;
  
  
  void install(ModuleCell moduleCell, bool transposed);
  void uninstall();
}

class BaseGridCell extends GridCell {
  ModuleCell _cell = null;
  bool _transposed = false;
  
  @override
  bool get isTransposed => _transposed;

  @override
  ModuleCell get moduleCell => _cell;

  @override
  void install(ModuleCell cell, bool transposed) {
    assert(cell != null);
    assert(_cell == null);

    _cell = cell;
    _transposed = transposed;
  }
  
  @override
  void uninstall() {
    assert(_cell != null);
    _cell = null;
    _transposed = false;
  }
}

typedef GridCell CellFactory();

GridCell BaseCellFactory() {
  return new BaseGridCell();
}


Pos calcCellPos(Pos basePos, Pos relPos, bool transposed) {
  if (!transposed) {
    return new Pos(basePos.row + relPos.row, basePos.col + relPos.col);
  } else {
    return new Pos(basePos.row + relPos.col, basePos.col + relPos.row);
  }
}


abstract class BaseGrid extends Grid {
  Set<Module> _installedModules= new Set();
  Set<ModuleGridInstallation> _installations = new Set();
  
  final CellFactory cellFactory_;
  
  BaseGrid([this.cellFactory_ = BaseCellFactory]);
 
  @override
  Iterable<ModuleGridInstallation> get installations => _installations;
  
  @override
  ModuleGridInstallation install(Module module, Pos basePos, bool transposed) {
    assert(!_installedModules.contains(module));
    _installedModules.add(module);
    var installation = new ModuleGridInstallation(module, basePos, transposed);
    _installations.add(installation);
    return installation;
  }
  
  @override
  void uninstall(ModuleGridInstallation installation) {
    assert(_installations.contains(installation));
    _installedModules.remove(installation.module);
    _installations.remove(installation);
  }
}

class BaseDynamicGrid extends BaseGrid {
  Map<Pos, GridCell> _cells = new Map();
  
  BaseDynamicGrid([CellFactory cellFactory = BaseCellFactory]) : super(cellFactory);
  
  @override
  Iterable<Pos> get cellPositions => _cells.keys;

  @override
  GridCell getCell(Pos pos) {
    return _cells[pos];
  }
  
  @override
  ModuleGridInstallation install(Module module, Pos basePos, bool transposed) {
    var installation = super.install(module, basePos, transposed);
    
    var moduleMap = module.cells;
    for (Pos relPos in moduleMap.keys) {
      Pos cellPos = calcCellPos(basePos, relPos, transposed);
      assert(!_cells.containsKey(cellPos));
      GridCell cell = cellFactory_();
      _cells[cellPos] = cell;
      cell.install(moduleMap[relPos], transposed);
    }
    return installation;
  }

  @override
  void uninstall(ModuleGridInstallation installation) {
    super.uninstall(installation);
    var moduleMap = installation.module.cells;
    for (Pos relPos in moduleMap.keys) {
      Pos cellPos = calcCellPos(installation.pos, relPos, installation.transposed);
      var cell = _cells[cellPos];
      cell.uninstall();
      _cells.remove(cellPos);
    }
  }
}

class BaseFixedGrid extends BaseGrid {
  final int height;
  final int width;
  
  List<List<GridCell>> _cells;
  
  BaseFixedGrid(this.height, this.width, [CellFactory cellFactory = BaseCellFactory]) : super(cellFactory) 
  {
    assert(height > 0 && width > 0);
    _cells = new List(height);
    for (int row = 0; row < height; row++) {
      _cells[row] = new List(width);
      for (int col = 0; col < width; col++) {
        _cells[row][col] = cellFactory();
      }
    }
  }
  
  @override
  Iterable<Pos> get cellPositions {
    List<Pos> result = new List();
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        result.add(new Pos(row, col));
      }
    }
    return result;
  }
  
  bool _posWithinLimits(Pos pos) {
    return pos.col >= 0 && pos.col < width && pos.row >= 0 && pos.row < height;
  }
  
  @override
  GridCell getCell(Pos pos) {
    if (_posWithinLimits(pos)) {
      return _cells[pos.row][pos.col];
    } else {
      return null;
    }
  }
  
  @override
  ModuleGridInstallation install(Module module, Pos basePos, bool transposed) {
    var installation = super.install(module, basePos, transposed);
    
    var moduleMap = module.cells;
    for (Pos relPos in moduleMap.keys) {
      Pos cellPos = calcCellPos(basePos, relPos, transposed);
      GridCell cell = getCell(relPos);
      assert(cell != null);
      assert(cell.moduleCell == null);
      cell.install(moduleMap[relPos], transposed);
    }
    
    return installation;
  }

  @override
  void uninstall(ModuleGridInstallation installation) {
    super.uninstall(installation);
    var moduleMap = installation.module.cells;
    for (Pos relPos in moduleMap.keys) {
      Pos cellPos = calcCellPos(installation.pos, relPos, installation.transposed);
      GridCell cell = getCell(relPos);
      assert(cell != null);
      cell.uninstall();
    }
  }
}

class ConnectingGrid extends Grid {
  final Grid _del;
  
  ConnectingGrid(this._del) { }
  
  @override
  Iterable<Pos> get cellPositions => _del.cellPositions;

  @override
  GridCell getCell(Pos pos) => _del.getCell(pos);

  void _connect(Input input, Output output) {
    if (input != null && output != null) {
      var connection = output.issueConnection();
      input.acceptConnection(connection);
    }
  }

  void _disconnect(Input input, Output output) {
    if (input != null && output != null) {
      assert(input.connection != null);
      input.disconnect();
    }
  }
  
  @override
  ModuleGridInstallation install(Module module, Pos pos, bool transposed) {
    var installation = _del.install(module, pos, transposed);
    var moduleMap = module.cells;
    for (var relPos in moduleMap.keys) {
      var cellPos = calcCellPos(pos, relPos, transposed);
      _connect(topInput(getCell(cellPos)), bottomOutput(getCell(cellPos.up)));
      _connect(leftInput(getCell(cellPos)), rightOutput(getCell(cellPos.left)));
      _connect(topInput(getCell(cellPos.down)), bottomOutput(getCell(cellPos)));
      _connect(leftInput(getCell(cellPos.right)), rightOutput(getCell(cellPos)));
    }
    return installation;
  }

  @override
  Iterable<ModuleGridInstallation> get installations => _del.installations;

  @override
  void uninstall(ModuleGridInstallation installation) {
    assert(_del.installations.contains(installation));
    var moduleMap = installation.module.cells;
    for (var relPos in moduleMap.keys) {
      var cellPos = calcCellPos(installation.pos, relPos, installation.transposed);
      _disconnect(topInput(getCell(cellPos)), bottomOutput(getCell(cellPos.up)));
      _disconnect(leftInput(getCell(cellPos)), rightOutput(getCell(cellPos.left)));
      _disconnect(topInput(getCell(cellPos.down)), bottomOutput(getCell(cellPos)));
      _disconnect(leftInput(getCell(cellPos.right)), rightOutput(getCell(cellPos)));
    }
    _del.uninstall(installation);
  }
}

Input topInput(GridCell cell) {
  if (cell == null || cell.moduleCell == null) {
    return null;
  } else if (!cell.isTransposed) {
    return cell.moduleCell.topInput;
  } else {
    return cell.moduleCell.leftInput;
  }
}

Input leftInput(GridCell cell) {
  if (cell == null ||cell.moduleCell == null) {
    return null;
  } else if (!cell.isTransposed) {
    return cell.moduleCell.leftInput;
  } else {
    return cell.moduleCell.topInput;
  }
}

Output rightOutput(GridCell cell) {
  if (cell == null ||cell.moduleCell == null) {
    return null;
  } else if (!cell.isTransposed) {
    return cell.moduleCell.rightOutput;
  } else {
    return cell.moduleCell.bottomOutput;
  }
}

Output bottomOutput(GridCell cell) {
  if (cell == null ||cell.moduleCell == null) {
    return null;
  } else if (!cell.isTransposed) {
    return cell.moduleCell.bottomOutput;
  } else {
    return cell.moduleCell.rightOutput;
  }
}



