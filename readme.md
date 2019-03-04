Medic
=====
A bare-bones unit testing framework.

About
-----

`Medic` is a simple unit testing framework for Haxe, designed for
when you don't need anything fancy. It has no dependencies and the
bare minimum functionality needed, the same as the old `haxe.unit.*`
framework.

Usage
-----

Tests are based on annotations, not on inheritance. Any class will do. Assertions are
handled by `medic.Assert`, which is best used with `using`.

```haxe
package test;

using medic.Assert;

class FooTest {

  public function new() {}

  @before
  public function runsBefore() {
    trace('Methods marked with `@before` will run before every test');
  }

  @after
  public function runsAfter() {
    trace('Methods marked with `@after` will run after every test');
  }

  @test('You can put a description of you test here!')
  public function testFoo() {
    'foo'.equals('foo');
  }

}
```

To run tests, simply add your test cases to `medic.Runner`. This should
all feel familiar if you've used the `haxe.unit.*` framework.

```haxe
import medic.Runner;

class Main {

  public static function main() {
    var runner = new Runner();
    runner.add(new test.FooTest());
    runner.run();
  }

}
```

And that's basically it! Simple!

Advanced
--------

Adding your own assertions:

```haxe
package my.test;

import haxe.PosInfos;
import medic.Assert;
import medic.AssertionError;

class ExtraAssert {

  public static function isFoo(item:String, ?p:PosInfos) {
    Assert.markUse(); // This must be called in every assertion, or Medic will
                      // fail the test and warn that no assertion was detected.
    if (item != 'foo') {
      // Always throw a `medic.AssertionError`
      throw new AssertionError('${item} should have been foo', p);
    }
  }

}
```

Using your own `Reporter`:

```haxe
import medic.Result;
import medic.Runner;
import medic.Reporter;

class Main {
 
  public static function main() {
    var runner = new Runner(new MyReporter());
    // or
    runner.useReporter(new MyReporter());
  }

}

class MyReporter implements Reporter {

  public function new() {}

  public function progress(info:TestInfo) {
    // Realtime progress can be logged here.
  }

  public function report(result:Result) {
    // We won't go into implementation details here -- check
    // the `medic.DefaultReporter` to get an idea of what's happening,
    // it's pretty self-explainitory.
    trace(result);
  }

}
```
