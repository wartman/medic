package medic;

import haxe.PosInfos;

enum TestStatus {
  Passed;
  Failed(e:TestError);
}

enum TestError {
  Warning(message:String);
  Assertion(message:String, pos:PosInfos);
  Multiple(errors:Array<TestError>);
  UnhandledException(message:String, backtrace:String); 
}

class TestInfo {

  public final name:String;
  public final field:String;
  public final description:String;
  public final isAsync:Bool;
  public final expectErrorToBeThrown:Bool;
  public final waitFor:Int;
  public var status:TestStatus = Passed;

  public function new(name, field, description, expectErrorToBeThrown, isAsync, ?waitFor) {
    this.name = name;
    this.field = field;
    this.description = description;
    this.expectErrorToBeThrown = expectErrorToBeThrown;
    this.isAsync = isAsync;
    this.waitFor = waitFor;
  }

}
