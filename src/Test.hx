import utest.Assert;

using StringTools;

typedef Fixture = {
	input : String,
	output : Entry,
	pos : haxe.PosInfos
}

enum PrepareState {
	Reading;
	ReadingInput(start:Int, input:String);
	ReadingResult(start:Int, input:String, output:String);
}

class Test {
	var fixtures:Array<Fixture>;

	function new(fixtures)
	{
		this.fixtures = fixtures;
	}

	public function testEntryParsing()
	{
		for (f in fixtures)
			Assert.same([f.output], Analyzer.getEntries(f.input), f.pos);
	}

	public static function prepare(file:String)
	{
		var data = sys.io.File.getContent(file);
		var lines = ~/\r?\n/g.split(data);
		var fixtures = [], pos = 0, state = Reading;
		while (pos < lines.length) {
			var line = lines[pos];
			switch state {
			case Reading if (line != "" && !line.startsWith("%")):
				state = ReadingInput(pos, line);
			case ReadingInput(start, input) if (line != "---" && !line.startsWith("%")):
				state = ReadingInput(start, input + "\n" +  line);
			case ReadingInput(start, input) if (line == "---"):
				state = ReadingResult(start, input, "");
			case ReadingResult(start, input, output) if (line != "===" && !line.startsWith("%")):
				state = ReadingResult(start, input, output + "\n" + line);
			case ReadingResult(start, input, output) if (line == "==="):
				fixtures.push({
					input : input,
					output : haxe.Json.parse(output),
					pos : {
						fileName : file,
						lineNumber : cast '$file:${start + 1}',  // HACK : )
						className : "",
						methodName : "" } });
				state = Reading;
			case _:
				// ignore ...
			}
			pos++;
		}
		return new Test(fixtures);
	}
}

