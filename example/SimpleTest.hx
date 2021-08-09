import medic.DefaultReporter;
import haxe.Timer;

using Medic;

class SimpleTest {

  public static function main() {
    var runner = new Runner(new DefaultReporter({
      title: 'This is what a passing test looks like:',
      trackProgress: true,
      verbose: false
    }));
    runner.add(new TestPasses());
    runner.add(new TestExtends());
    runner.run(() -> {
      var failing = new Runner(new DefaultReporter({
        title: 'This is what a failing test looks like:',
        trackProgress: true,
        verbose: false
      }));
      failing.add(new TestFails());
      failing.run();
    });
  }

}

class TestPasses implements TestCase {

  public function new() {}

  // @:test.before
  // public function runsBefore() {
  //   trace('before');
  // }

  // @:test.after
  // public function runsAfter() {
  //   trace('after');
  // }

  @:test
  public function pass() {
    Assert.pass();
  }

  @:test
  public function fooIsFoo() {
    'foo'.equals('foo');
  }

  @:test
  public function fooIsNotBar() {
    'foo'.notEquals('bar');
  }
 
  @:test
  @:test.async
  public function trueIsTrue(done) {
    Timer.delay(() -> {
      true.isTrue();
      done();
    }, 200);
  }
  
  @:test
  public function falseIsFalse() {
    false.isFalse();
  }

  @:test
  @:test.throws
  public function shouldThrow() {
    throw 'this should pass';
  }

}

class TestExtends extends TestPasses {

  @:test
  public function additionalTest() {
    'this is fine'.equals('this is fine');
  }

}

class TestFails implements TestCase {

  public function new() {}

  @:test public var notAMethod:String; 

  @:test
  public function noAssert() {}

  @:test
  public function custom() {
    Assert.fail('Just fail a thing if you need to');
  }

  @:test('Foo is not bar, it turns out')
  public function fooIsBar() {
    'foo'.equals('bar');
  }

  @:test
  public function falseIsTrue() {
    false.isTrue();
  }
 
  @:test
  public function trueIsFalse() {
    true.isFalse();
  }

  @:test('This test should fail because it has no assertions')
  @:test.async(100)
  public function asyncNoAssert(done) {
    Timer.delay(() -> {
      done();
    }, 100);
  }
  
  @:test('This test should fail because it is WRONG')
  @:test.async(100)
  public function asyncFalseIsTrue(done) {
    Timer.delay(() -> {
      true.isFalse();
      done();
    }, 100);
  }

  @:test('This test should fail because it waits too long')
  @:test.async(100)
  public function waitsTooLong(done) {
    Timer.delay(() -> {
      true.isTrue();
      done();
    }, 500);
  }
  
  @:test('This test should fail because `done` is never called')
  @:test.async
  public function neverDone(done) {
    true.isTrue();
  }

  @:test('This should fail!')
  public function shouldFail() {
    true.equals(false);
  }

  @:test
  public function throws() {
    throw 'testing';
  }

}
