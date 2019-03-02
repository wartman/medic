package medic;

import haxe.PosInfos;

enum TestError {
  Warning(message:String);
  Failed(message:String, pos:PosInfos);
  UnhandledException(message:String, backtrace:String); 
}

class TestStatus {

  public final name:String;
  public final field:String;
  public final description:String;
  public var error:TestError;
  public var success:Bool = false;

  public function new(name, field, description) {
    this.name = name;
    this.field = field;
    this.description = description;
  }

}