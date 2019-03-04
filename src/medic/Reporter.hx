package medic;

interface Reporter {
  public function progress(info:TestInfo):Void;
  public function report(result:Result):Void;
}
