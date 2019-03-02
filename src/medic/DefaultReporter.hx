package medic;

import StringBuf;

class DefaultReporter implements Reporter {

  public function new() {}

  public function report(result:Result) {
    var errors:Array<TestStatus> = [];
    var total:Int = 0;
    var success:Int = 0;
    var failed:Int = 0;
    var buf = new StringBuf();

    for (c in result.cases) {
      var out = new StringBuf();
      out.add('[${c.name}] ');
      for (test in c.tests) {
        total++;
        if (test.success) {
          success++;
          out.add('.');
        } else {
          failed++;
          errors.push(test);
          switch (test.error) {
            case Warning(_): out.add('W');
            case Failed(_, _): out.add('F');
            case UnhandledException(_, _): out.add('E');
          }
        }
      }
      buf.add('${out.toString()}\n');
    }

    buf.add('\n');
    if (failed == 0) {
      buf.add('OK ');
    } else {
      buf.add('FAILED ');
    }
    buf.add('${total} tests, ${success} success, ${failed} failed');
    
    if (errors.length > 0) {
      buf.add('\n');
      for (status in errors) { 
        var out = new StringBuf();
        var description = status.description.length > 0 ? ' "${status.description}"' : '';
        out.add('[${status.name}::${status.field}()${description}] ');
        switch (status.error) {
          case Warning(message): out.add('(warning) ${message}');
          case Failed(message, pos): out.add('(failed) ${pos.fileName}:${pos.lineNumber} - ${message}');
          case UnhandledException(message, backtrace): out.add('(unhandled exception) ${message} ${backtrace}');
        }
        buf.add(out.toString() + '\n');
      }
    }

    print(buf.toString());
  }

  function print(v:Dynamic) {
    #if js
      js.Syntax.code('
        var msg = {0};
        var safe = {1};
        var d;
        if (typeof document != "undefined"
          && (d = document.getElementById("medic-trace")) != null
        ) {
          d.innerHTML += safe; 
        } else if (typeof process != "undefined"
          && process.stdout != null
          && process.stdout.write != null
        ) {
          process.stdout.write(msg);
        } else if (typeof console != "undefined") {
          console.log(msg);
        }
      ', Std.string(v), StringTools.htmlEscape(v).split('/n').join('</br>'));
    #else 
      Sys.print(Std.string(v));
    #end
  }

}