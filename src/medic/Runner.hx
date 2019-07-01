package medic;

import haxe.Timer;
import haxe.CallStack;
import haxe.DynamicAccess;
import haxe.rtti.Meta;
import medic.TestInfo;

using Reflect;

class Runner {

  var reporter:Reporter;
  var cases:Array<{}> = [];

  public function new(?reporter:Reporter) {
    if (reporter == null) reporter = new DefaultReporter();
    this.reporter = reporter;
  }

  public function setReporter(reporter:Reporter) {
    this.reporter = reporter;
  }

  public function add(c:{}) {
    cases.push(c);
    return this;
  }

  public function run() {
    var result = new Result();
    var cs = cases.copy();

    function doCase() {
      var c = cs.shift();
      if (c == null) {
        reporter.report(result);
        return;
      }
      runCase(c, result, doCase);
    }

    doCase();
  }

  function runCase(t:{}, result:Result, complete:()->Void) {
    var cls = Type.getClass(t);
    var tests = getTestInfos(cls);
    var before = getMatchingMethodRunner('before', t, cls);
    var after = getMatchingMethodRunner('after', t, cls);
    var tc = new CaseInfo(Type.getClassName(cls));

    function doTest() {
      var info = tests.shift();
      if (info == null) {
        result.add(tc);
        complete();
        return;
      }

      function progress() {
        reporter.progress(info);
        tc.add(info);
        doTest();
      }

      var field:Dynamic = t.field(info.field);
      if (field.isFunction()) {
        var asserted = Assert.asserted;
        var asyncTimedOut:Bool = false;
        var asyncCompleted:Bool = false;

        function done() {
          if (asyncTimedOut) {
            return;
          }
          asyncCompleted = true;
          var errors = Assert.getErrors();
          after();
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
          before();
          if (info.isAsync) {
            t.callMethod(field, [ done ]);
            Timer.delay(() -> {
              asyncTimedOut = true;
              if (!asyncCompleted) {
                info.status = Failed(Warning('Timed out after ${info.waitFor}ms with no assertions'));
                progress();
              }
            }, info.waitFor + 10);
          } else {
            t.callMethod(field, []);
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
      } else {
        info.status = Failed(Warning('not a function'));
        progress();
      }
    }

    doTest();
  }

  function getMatchingMethodRunner(meta:String, t:Dynamic, cls:Class<Dynamic>):()->Void {
    var methods = getMatchingMethods(meta, cls).map(name -> t.field(name));
    if (methods.length == 0) return () -> null;
    return () -> for (m in methods) t.callMethod(m, []);
  }

  function getMatchingMethods(meta:String, cls:Class<Dynamic>):Array<String> {
    var matching:Array<String> = [];
    var fields:DynamicAccess<Dynamic> = cast Meta.getFields(cls);
    for (key in fields.keys()) {
      var field:DynamicAccess<Dynamic> = cast fields.get(key);
      if (field.exists(meta)) {
        matching.push(key);
      }
    }
    var superclass = Type.getSuperClass(cls);
    if (superclass != null) {
      matching = matching.concat(getMatchingMethods(meta, superclass));
    }
    return matching;
  }

  function getTestInfos(cls:Class<Dynamic>):Array<TestInfo> {
    var name = Type.getClassName(cls);
    var tests:Array<TestInfo> = [];
    var fields:DynamicAccess<Dynamic> = cast Meta.getFields(cls);
    for (key in fields.keys()) {
      var field:DynamicAccess<Dynamic> = cast fields.get(key);
      if (field.exists('test')) {
        var testMeta:Array<String> = field.get('test');
        var asyncMeta:Array<Int> = field.get('async');
        tests.push(new TestInfo(
          name,
          key,
          testMeta == null ? '' : testMeta[0],
          field.exists('throws'),
          field.exists('async'),
          asyncMeta == null ? 200 : ( asyncMeta[0] == null ? 200 : asyncMeta[0] )  
        ));
      }
    }
    var superclass = Type.getSuperClass(cls);
    if (superclass != null) {
      tests = tests.concat(getTestInfos(superclass));
    }
    return tests;
  }

}
