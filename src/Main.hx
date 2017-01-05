import Assertion.*;
using Literals;
using StringTools;

class Main {
	static var usage = "
		plan timetracker – ptt

		Usage:
		  ptt <file> [<file> ...]
		  ptt generate-test-file <test file> <file> [<file> ...]
		  ptt unit-test <test file>
		  ptt --help".doctrim();

	static function main()
	{
		switch Sys.args() {
		case ["--help"|"-h"]:
			Sys.print(usage);
			Sys.exit(0);
		case []:
			Sys.println(usage);
			Sys.exit(1);
		case ["unit-test", testFile]:
			var r = new utest.Runner();
			var p = utest.ui.Report.create(r);
			var t = Test.prepare(testFile);
			r.addCase(t);
			r.run();
		case _.slice(0, 3) => ["generate-test-file", testFile, file]:
			var buf = new haxe.io.BytesOutput();
			Analyzer.dump = buf;
			Analyzer.run(Sys.args().slice(2));
			sys.io.File.saveBytes(testFile, buf.getBytes());
		case args:
			Analyzer.run(args);
		}
	}
}

