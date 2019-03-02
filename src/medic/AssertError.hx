package medic;

import haxe.PosInfos;

class AssertError {

  public final message:String;
  public final pos:PosInfos;

  public function new(message, pos:PosInfos) {
    this.message = message;
    this.pos = pos;
  }

}
