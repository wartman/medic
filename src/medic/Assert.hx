package medic;

import haxe.PosInfos;

class Assert {

  static var count:Int = 0;
  public static var asserted(get, never):Int;
  static function get_asserted() return count;
  static var errors:Array<AssertionError> = [];

  public static function getErrors() {
    return errors;
  }

  public static function resetErrors() {
    errors = [];
  }

  public static function increment() {
    count++;
  }

  public static function fail(message:String, ?p:PosInfos) {
    increment();
    errors.push(new AssertionError(message, p));
  }

  public static function pass() {
    increment();
  }

  public static function isTrue(a:Bool, ?p:PosInfos) {
    increment();
    if (!a) {
      errors.push(new AssertionError('expected `true` but was `false`', p));
    }
  }
  
  public static function isFalse(a:Bool, ?p:PosInfos) {
    increment();
    if (a) {
      errors.push(new AssertionError('expected `false` but was `true`', p));
    }
  }

  public static function equals<T>(expected:T, actual:T, ?p:PosInfos) {
    increment();
    if (expected != actual) {
      errors.push(new AssertionError('expected `${expected}` but was `${actual}`', p));
    }
  }

}
