package medic;

#if !macro

@:allow(medic.Runner)
@:autoBuild(medic.TestCase.build())
interface TestCase {
  @:noCompletion private function __getTestCaseRunner():TestCaseRunner<Dynamic>;
}

#else

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

class TestCase {

  static final META_TEST = ':test';
  static final META_ASYNC = ':test.async';
  static final META_THROWS = ':test.throws';
  static final META_BEFORE = ':test.before';
  static final META_AFTER = ':test.after';

  public static function build() {
    var fields = Context.getBuildFields();
    var cls = Context.getLocalClass().get();
    var before:Array<Expr> = [];
    var after:Array<Expr> = [];
    var tests:Array<Expr> = [];

    // The following is to assist in upgrading to version 0.2.0
    for (meta in [ META_TEST, META_ASYNC, META_THROWS, META_BEFORE, META_AFTER ]) {
      for (f in fields) {
        if (f.meta.exists(m -> m.name == meta.substr(1))) {
          var m = f.meta.find(m -> m.name == meta.substr(1));
          Context.warning('Warning: only @${meta} will work, make sure you use a `:` if you want the intended behavior', m.pos);
        }
        if (meta != META_TEST) {
          var withoutTest = meta.substr(META_TEST.length + 1);
          if (f.meta.exists(m -> m.name == withoutTest)) {
            var m = f.meta.find(m -> m.name == withoutTest);
            Context.warning('Warning: all test meta must be prefixed with `:test` (for example, `${meta}`). Change this if that\'s your intended behavior', m.pos);
          }
        }
      }
    }

    for (f in fields) switch f.kind {

      case FFun(_) if (f.meta.exists(m -> m.name == META_TEST)):
        var name = f.name;
        var aboutMeta = f.meta.find(m -> m.name == META_TEST);
        var about = switch aboutMeta.params {
          case []: name;
          case [ { expr: EConst(CString(s, _) ), pos: _ } ]: s;
          default: Context.error('`@${META_TEST}` may have one string description or no params', aboutMeta.pos);
        }
        var expectThrows = f.meta.exists(m -> m.name == META_THROWS) ? macro true : macro false;
        var asyncMeta = f.meta.find(m -> m.name == META_ASYNC);
        var isAsync = asyncMeta != null;
        var asyncTimeout = isAsync ? switch asyncMeta.params {
          case []: 200;
          case [ { expr: EConst(CInt(i)), pos: _ } ]: Std.parseInt(i);
          default: Context.error('@${META_ASYNC} may have one integer param or no params', asyncMeta.pos);
        } : null;
        if (isAsync) {
          tests.push(macro @:pos(f.pos) runner.addTest($v{name}, $v{about}, this.$name, ${expectThrows}, true, $v{asyncTimeout}));
        } else {
          tests.push(macro @:pos(f.pos) runner.addTest($v{name}, $v{about}, _ -> this.$name(), ${expectThrows}));
        }

      case FFun(_) if (f.meta.exists(m -> m.name == META_BEFORE)):
        var name = f.name;
        before.push(macro @:pos(f.pos) runner.addBefore(this.$name));

      case FFun(_) if (f.meta.exists(m -> m.name == META_AFTER)):
        var name = f.name;
        after.push(macro @:pos(f.pos) runner.addAfter(this.$name));

      default:

    }

    if (cls.superClass != null) {
      return fields.concat((macro class {

        override function __getTestCaseRunner() {
          var runner = super.__getTestCaseRunner();
          $b{before};
          $b{after};
          $b{tests};
          return runner;
        }
  
      }).fields);
    }    

    return fields.concat((macro class {

      function __getTestCaseRunner() {
        var runner = new medic.TestCaseRunner(this);
        $b{before};
        $b{after};
        $b{tests};
        return runner;
      }

    }).fields);
  }

}

#end