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

  public final className:String;
  public final field:String;
  public final description:String;
  public final cb:(done:()->Void)->Void;
  public final isAsync:Bool;
  public final expectErrorToBeThrown:Bool;
  public final timeout:Int;
  public var status:TestStatus = Passed;

  public function new(className:String, field, description, cb, expectErrorToBeThrown, isAsync, ?timeout) {
    this.className = className;
    this.field = field;
    this.description = description;
    this.cb = cb;
    this.expectErrorToBeThrown = expectErrorToBeThrown;
    this.isAsync = isAsync;
    this.timeout = timeout;
  }

}
