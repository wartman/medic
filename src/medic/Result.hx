package medic;

import haxe.ds.List;

class Result {

  public var success(default, null):Bool = true;
  public final cases:List<CaseStatus> = new List();

  public function new() {}

  public function add(status:CaseStatus) {
    cases.add(status);
    if (!status.success) {
      success = false;
    }
  }

}
