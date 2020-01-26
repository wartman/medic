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

  public static function build() {
    var fields = Context.getBuildFields();
    var cls = Context.getLocalClass().get();
    var before:Array<Expr> = [];
    var after:Array<Expr> = [];
    var tests:Array<Expr> = [];

    for (f in fields) switch f.kind {
      case FFun(_) if (f.meta.exists(m -> m.name == 'test')):
        var name = f.name;
        var aboutMeta = f.meta.find(m -> m.name == 'test');
        var about = switch aboutMeta.params {
          case []: name;
          case [ { expr: EConst(CString(s, _) ), pos: _ } ]: s;
          default: Context.error('`@test` may have one string description or no params', aboutMeta.pos);
        }
        var expectThrows = f.meta.exists(m -> m.name == 'throws') ? macro true : macro false;
        var asyncMeta = f.meta.find(m -> m.name == 'async');
        var isAsync = asyncMeta != null;
        var asyncTimeout = isAsync ? switch asyncMeta.params {
          case []: 200;
          case [ { expr: EConst(CInt(i)), pos: _ } ]: Std.parseInt(i);
          default: Context.error('@async may have one integer param or no params', asyncMeta.pos);
        } : null;
        if (isAsync) {
          tests.push(macro @:pos(f.pos) runner.addTest($v{name}, $v{about}, this.$name, ${expectThrows}, true, $v{asyncTimeout}));
        } else {
          tests.push(macro @:pos(f.pos) runner.addTest($v{name}, $v{about}, _ -> this.$name(), ${expectThrows}));
        }
      case FFun(_) if (f.meta.exists(m -> m.name == 'before')):
        var name = f.name;
        before.push(macro @:pos(f.pos) runner.addBefore(this.$name));
      case FFun(_) if (f.meta.exists(m -> m.name == 'after')):
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