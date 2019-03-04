package medic;

import haxe.ds.List;

class Result {

  public var success(default, null):Bool = true;
  public final cases:List<CaseInfo> = new List();

  public function new() {}

  public function add(c:CaseInfo) {
    cases.add(c);
    switch c.status {
      case Passed:
      case Failed: success = false;
    }
  }

}
