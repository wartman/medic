package medic;

import haxe.PosInfos;

enum TestStatus {
  Passed;
  Failed(e:TestError);
}

enum TestError {
  Warning(message:String);
  Assertion(message:String, pos:PosInfos);
  UnhandledException(message:String, backtrace:String); 
}

class TestInfo {

  public final name:String;
  public final field:String;
  public final description:String;
  public var status:TestStatus = Passed;

  public function new(name, field, description) {
    this.name = name;
    this.field = field;
    this.description = description;
  }

}