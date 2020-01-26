package medic;

import medic.TestInfo;

typedef DefaultReporterOptions = {
  ?title:String,
  trackProgress:Bool,
  verbose:Bool,
};

class DefaultReporter implements Reporter {

  final options:DefaultReporterOptions;
  var started:Bool = false;

  public function new(?options) {
    this.options = options != null ? options : {
      trackProgress: true,
      verbose: false
    };
  }

  public function progress(info:TestInfo):Void {
    if (!started) {
      started = true;
      if (options.title != null) print('\n' + options.title + '\n');
    }
    if (!options.trackProgress) return;
    switch info.status {
      case Passed: print('.');
      case Failed(e): switch e {
        case Warning(_): print('W');
        case Assertion(_, _): print('F');
        case UnhandledException(_, _): print('E');
        case Multiple(_): print('E');
      }
    }
  }

  public function report(result:Result) {
    var errors:Array<TestInfo> = [];
    var total:Int = 0;
    var success:Int = 0;
    var failed:Int = 0;
    var buf = '';

    for (c in result.cases) {
      for (test in c.tests) {
        total++;
        switch test.status {
          case Passed: success++;
          case Failed(_):
            failed++;
            errors.push(test);
        }
      }
    }

    buf += '\n${failed == 0 ? 'OK' : 'FAILED'} ${total} tests, ${success} success, ${failed} failed';
    
    if (errors.length > 0) {
      buf += '\n';
      for (info in errors) { 
        var description = info.description.length > 0 ? ' "${info.description}"' : '';
        var out = '[${info.className}::${info.field}()${description}] ';
        function display(status:TestStatus) {
          switch (status) {
            case Passed:
            case Failed(e): switch e {
              case Warning(message): out += '(warning) ${message}';
              case Assertion(message, pos): out += '(failed) ${pos.fileName}:${pos.lineNumber} - ${message}';
              case UnhandledException(message, backtrace) if (options.verbose): out += '(unhandled exception) ${message} ${backtrace}';
              case UnhandledException(message, _): out += '(unhandled exception) ${message}';
              case Multiple(errors): for (e in errors) display(Failed(e)); 
            }
          }
        }
        display(info.status);
        buf += '${out}\n';
      }
    }

    print(buf);
  }

  function print(v:Dynamic) {
    #if js
      js.Syntax.code('
        var msg = {0};
        var safe = {1};
        var d;
        if (
          typeof document != "undefined"
          && (d = document.getElementById("medic-trace")) != null
        ) {
          d.innerHTML += safe; 
        } else if (
          typeof process != "undefined"
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