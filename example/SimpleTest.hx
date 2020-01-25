import haxe.Timer;

using Medic;

class SimpleTest {

  public static function main() {
    var runner = new Runner();
    runner.add(new TestFails());
    runner.add(new TestPasses());
    runner.run();
  }

}

class TestPasses implements TestCase {

  public function new() {}

  // @before
  // public function runsBefore() {
  //   trace('before');
  // }

  // @after
  // public function runsAfter() {
  //   trace('after');
  // }

  @test
  public function pass() {
    Assert.pass();
  }

  @test
  public function fooIsFoo() {
    'foo'.equals('foo');
  }
 
  @test
  @async
  public function trueIsTrue(done) {
    Timer.delay(() -> {
      true.isTrue();
      done();
    }, 200);
  }
  
  @test
  public function falseIsFalse() {
    false.isFalse();
  }

  @test
  @throws
  public function shouldThrow() {
    throw 'this should pass';
  }

}

class TestFails implements TestCase {

  public function new() {}

  @test public var notAMethod:String; 

  @test
  public function noAssert() {}

  @test
  public function custom() {
    Assert.fail('Just fail a thing if you need to');
  }

  @test('Foo is not bar, it turns out')
  public function fooIsBar() {
    'foo'.equals('bar');
  }

  @test
  public function falseIsTrue() {
    false.isTrue();
  }
 
  @test
  public function trueIsFalse() {
    true.isFalse();
  }

  @test('This test should fail because it has no assertions')
  @async(100)
  public function asyncNoAssert(done) {
    Timer.delay(() -> {
      done();
    }, 100);
  }
  
  @test('This test should fail because it is WRONG')
  @async(100)
  public function asyncFalseIsTrue(done) {
    Timer.delay(() -> {
      true.isFalse();
      done();
    }, 100);
  }

  @test('This test should fail because it waits too long')
  @async(100)
  public function waitsTooLong(done) {
    Timer.delay(() -> {
      true.isTrue();
      done();
    }, 500);
  }
  
  @test('This test should fail because `done` is never called')
  @async
  public function neverDone(done) {
    true.isTrue();
  }

  @test('This should fail!')
  public function shouldFail() {
    true.equals(false);
  }

  @test
  public function throws() {
    throw 'testing';
  }

}
