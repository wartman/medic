import medic.Runner;

using medic.Assert;

class SimpleTest {

  public static function main() {
    var runner = new Runner();
    runner.add(new TestPasses());
    runner.add(new TestFails());
    runner.run();
  }

}

class TestPasses {

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
  public function trueIsTrue() {
    true.isTrue();
  }
  
  @test
  public function falseIsFalse() {
    false.isFalse();
  }

}

class TestFails {

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

  @test('This should fail!')
  public function shouldFail() {
    true.equals(false);
  }

  @test
  public function throws() {
    throw 'testing';
  }

}
