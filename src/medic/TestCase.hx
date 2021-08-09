package medic;

@:allow(medic.Runner)
@:autoBuild(medic.TestCaseBuilder.build())
interface TestCase {
  private function getTestCaseRunner():TestCaseRunner<Dynamic>;
}
