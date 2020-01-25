package medic;

import haxe.Timer;
import haxe.CallStack;
import medic.TestInfo;

using Type;

class TestCaseRunner<T:TestCase> {

  final before:Array<()->Void> = [];
  final after:Array<()->Void> = [];
  final tests:Array<TestInfo> = [];
  final caseInfo:CaseInfo;

  public function new(testCase:T) {
    this.caseInfo = new CaseInfo(testCase.getClass().getClassName());
  }

  public inline function addBefore(cb) {
    before.push(cb);
  }

  public inline function addAfter(cb) {
    after.push(cb);
  }

  public inline function doBefore() {
    for (cb in before) cb();
  }

  public inline function doAfter() {
    for (cb in after) cb();
  }

  public inline function addTest(field:String, about:String, test:(done:()->Void)->Void, expectErrorToBeThrown:Bool, isAsync:Bool = false, timeout:Int = 200) {
    tests.push(new TestInfo(
      caseInfo.name,
      field,
      about,
      test,
      expectErrorToBeThrown,
      isAsync,
      timeout
    ));
  }

  public function run(result:Result, reporter:Reporter, complete:()->Void) {
    var tests = tests.copy();
    
    function doTest() {
      var info = tests.shift();
      if (info == null) {
        result.add(caseInfo);
        complete();
        return;
      }

      function progress() {
        reporter.progress(info);
        caseInfo.add(info);
        doTest();
      }

      var asserted = Assert.asserted;
      var asyncTimedOut:Bool = false;
      var asyncCompleted:Bool = false;

      function done() {
        if (asyncTimedOut) {
          return;
        }
        asyncCompleted = true;
        var errors = Assert.getErrors();
        doAfter();
        if (info.expectErrorToBeThrown) {
          info.status = Failed(Warning('Expected an error to be thrown but none was'));
        } else if (errors.length == 1) {
          var e = errors[0];
          info.status = Failed(Assertion(e.message, e.pos));
        } else if (errors.length > 0) {
          info.status = Failed(Multiple([ for (e in errors) Assertion(e.message, e.pos) ]));
        } else if (asserted < Assert.asserted) {
          info.status = Passed;
        } else {
          info.status = Failed(Warning('no assert'));
        }
        progress();
      }

      try {
        Assert.resetErrors();
        doBefore();
        if (info.isAsync) {
          info.cb(done);
          Timer.delay(() -> {
            asyncTimedOut = true;
            if (!asyncCompleted) {
              info.status = Failed(Warning('Timed out after ${info.timeout}ms with no assertions'));
              progress();
            }
          }, info.timeout + 10);
        } else {
          info.cb(()->null);
          done();
        }
      } catch (e:Dynamic) {
        if (info.expectErrorToBeThrown) {
          info.status = Passed;
          progress();
        } else {
          var backtrace = CallStack.toString(CallStack.exceptionStack());
          var err:TestError;
          #if js
            if (e.message != null) {
              err = UnhandledException(e.message, backtrace);
            } else {
              err = UnhandledException(e, backtrace);
            }
          #else
            err = UnhandledException(e, backtrace);
          #end
          info.status = Failed(err);
          progress();
        } 
      }
    }

    doTest();
  }

}