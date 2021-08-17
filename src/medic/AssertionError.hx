package medic;

import haxe.Exception;
import haxe.PosInfos;

class AssertionError extends Exception {

  public final pos:PosInfos;

  public function new(message, pos:PosInfos) {
    super(message);
    this.pos = pos;
  }

}
