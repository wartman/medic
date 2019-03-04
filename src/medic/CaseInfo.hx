package medic;

enum CaseStatus {
  Passed;
  Failed;
}

class CaseInfo {

  public final name:String;
  public final tests:Array<TestInfo> = [];
  public var status(default, null):CaseStatus = Passed;

  public function new(name) {
    this.name = name;
  }

  public function add(info:TestInfo) {
    tests.push(info);
    switch info.status {
      case Failed(_): status = Failed;
      default:
    }
  }

}
