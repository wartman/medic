package medic;

import haxe.PosInfos;

class Assert {

  static var count:Int = 0;

  public static function reset() {
    count = 0;
  }

  public static function wasUsed() {
    return count > 0;
  }

  public static function markUse() {
    count++;
  }

  public static function fail(message:String, ?p:PosInfos) {
    markUse();
    throw new AssertionError(message, p);
  }

  public static function isTrue(a:Bool, ?p:PosInfos) {
    markUse();
    if (!a) {
      throw new AssertionError('expected `true` but was `false`', p);
    }
  }
  
  public static function isFalse(a:Bool, ?p:PosInfos) {
    markUse();
    if (a) {
      throw new AssertionError('expected `false` but was `true`', p);
    }
  }

  public static function equals<T>(expected:T, actual:T, ?p:PosInfos) {
    markUse();
    if (expected != actual) {
      throw new AssertionError('expected `${expected}` but was `${actual}`', p);
    }
  }

}
