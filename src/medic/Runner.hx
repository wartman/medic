package medic;

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
    for (c in cases) {
      runCase(c, result);
    }
    reporter.report(result);
    return result.success;
  }

  function runCase(t:{}, result:Result) {
    var cls = Type.getClass(t);
    var tests = getTestInfos(cls);
    var before = getMatchingMethodRunner('before', t, cls);
    var after = getMatchingMethodRunner('after', t, cls);
    var tc = new CaseInfo(Type.getClassName(cls));

    for (info in tests) {
      var field:Dynamic = t.field(info.field);
      if (field.isFunction()) {
        var asserted = Assert.asserted;
        try {
          before();
          t.callMethod(field, []);
          after();
          if (asserted < Assert.asserted) {
            info.status = Passed;
          } else {
            info.status = Failed(Warning('no assert'));
          }
        } catch (e:AssertionError) {
          info.status = Failed(Assertion(e.message, e.pos));
        } catch (e:Dynamic) {
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
        }
      } else {
        info.status = Failed(Warning('not a function'));
      }
      reporter.progress(info);
      tc.add(info);
    }

    result.add(tc);
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
    return matching;
  }

  function getTestInfos(cls:Class<Dynamic>):Array<TestInfo> {
    var name = Type.getClassName(cls);
    var tests:Array<TestInfo> = [];
    var fields:DynamicAccess<Dynamic> = cast Meta.getFields(cls);
    for (key in fields.keys()) {
      var field:DynamicAccess<Dynamic> = cast fields.get(key);
      if (field.exists('test')) {
        var meta:Array<String> = field.get('test');
        tests.push(new TestInfo(
          name,
          key,
          meta == null ? '' : meta[0]
        ));
      }
    }
    return tests;
  }

}
