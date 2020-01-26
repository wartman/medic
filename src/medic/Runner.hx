package medic;

class Runner {

  var reporter:Reporter;
  var cases:Array<TestCase> = [];

  public function new(?reporter:Reporter) {
    if (reporter == null) reporter = new DefaultReporter();
    this.reporter = reporter;
  }

  public function setReporter(reporter:Reporter) {
    this.reporter = reporter;
  }

  public function add(c:TestCase) {
    cases.push(c);
    return this;
  }

  public function run(?done:()->Void) {
    var result = new Result();
    var cs = cases.copy();

    function doCase() {
      var c = cs.shift();
      if (c == null) {
        reporter.report(result);
        if (done != null && result.success) {
          done();
        } else {
          #if js
            js.Syntax.code('if (typeof process != "undefined" && process.exit) process.exit({0} ? 0 : 1)', result.success);
          #else
            Sys.exit(result.success ? 0 : 1);
          #end
        }
        return;
      }
      c.__getTestCaseRunner().run(result, reporter, doCase);
    }

    doCase();
  }

}
