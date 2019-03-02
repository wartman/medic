package medic;

import haxe.CallStack;
import haxe.DynamicAccess;
import haxe.rtti.Meta;

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
    var tc = new CaseStatus(Type.getClassName(cls));

    for (status in tests) {
      var field:Dynamic = t.field(status.field);
      if (field.isFunction()) {
        Assert.reset();
        try {
          before();
          t.callMethod(field, []);
          after();
          if (Assert.wasUsed()) {
            status.success = true;
          } else {
            status.error = Warning('no assert');
            status.success = false; 
          }
        } catch (e:AssertError) {
          status.success = false;
          status.error = Failed(e.message, e.pos);
        } catch (e:Dynamic) {
          status.success = false;
          var backtrace = CallStack.toString(CallStack.exceptionStack());
          #if js
            if (e.message != null) {
              status.error = UnhandledException(e.message, backtrace);
            } else {
              status.error = UnhandledException(e, backtrace);
            }
          #else
            status.error = UnhandledException(e, backtrace);
          #end
        }
        tc.add(status);
      } else {
        status.error = Warning('not a function');
        status.success = false;
        tc.add(status);
      }
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

  function getTestInfos(cls:Class<Dynamic>):Array<TestStatus> {
    var name = Type.getClassName(cls);
    var tests:Array<TestStatus> = [];
    var fields:DynamicAccess<Dynamic> = cast Meta.getFields(cls);
    for (key in fields.keys()) {
      var field:DynamicAccess<Dynamic> = cast fields.get(key);
      if (field.exists('test')) {
        var meta:Array<String> = field.get('test');
        tests.push(new TestStatus(
          name,
          key,
          meta == null ? '' : meta[0]
        ));
      }
    }
    return tests;
  }

}
