package medic;

class CaseStatus {

  public final name:String;
  public final tests:Array<TestStatus> = [];
  public var success(default, null):Bool;
  public var done(default, null):Bool;

  public function new(name) {
    this.name = name;
    success = true;
    done = false;
  }

  public function add(status:TestStatus) {
    tests.push(status);
    done = true;
    if (!status.success) {
      success = false;
    }
  }

}