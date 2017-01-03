import Assertion.*;
import sys.FileSystem;
using Literals;
import Std.parseInt;

typedef Duration = Float; // in seconds

typedef Entry = {
	channel:String,
	duration:Duration,
	?start:Duration,
	?finish:Duration,
}

class Main {
	static function info(msg)
		Sys.stderr().writeString('$msg\n');

	static function warn(msg)
		info('WARN: $msg');

	static function error(msg)
	{
		info('ERROR: $msg\n\n');
		throw "Aborted";
	}

	static function getEntries(content)
	{
		var pat = ~/`[\/\\]log[ ]+((from[ ]+(\d+)[h:](\d+)'?[ ]+to[ ]+(\d+)[h:](\d+)'?)|(((\d+)[h:])?(\d+)'?))[ ]+on[ ]+(#[a-zA-Z0-9-]+)[^`]*`/g;
		var pos = 0, entries = [];
		while (pat.matchSub(content, pos)) {
			// show([for (i in 0...11) pat.matched(i+1)]);
			var entry:Entry = {
				channel : pat.matched(11),
				duration : 0
			}
			var precise = pat.matched(2) != null;
			if (pat.matched(2) != null) {
				entry.start = 60.*parseInt(pat.matched(4)) + 3600.*parseInt(pat.matched(3));
				entry.finish = 60.*parseInt(pat.matched(6)) + 3600.*parseInt(pat.matched(5));
				assert(entry.start <= entry.finish);
				entry.duration = entry.finish - entry.start;
			} else {
				entry.duration = 60.*parseInt(pat.matched(10)) + (pat.matched(8) != null ? 3600.*parseInt(pat.matched(9)) : 0);
			}
			// show(pat.matched(0), entry);
			entries.push(entry);
			var mpos = pat.matchedPos();
			pos = mpos.pos + mpos.len;
		}
		return entries;
	}

	static function prettyDuration(dur:Duration)
	{
		var hours = Math.floor(dur/3600);
		var minutes = (dur - hours*3600)/60;
		return '${hours}h${minutes}\'';
	}

	static function printSummary(summary:Map<String,Duration>, println)
	{
		var channels = [for (k in summary.keys()) k];
		channels.sort(Reflect.compare);
		var acc = 0.;
		for (c in channels) {
			var dur = summary[c];
			acc += dur;
			println('  $c: ${prettyDuration(dur)}');
		}
		println(' -> total: ${prettyDuration(acc)}');
	}

	static function absorbSummary(summary:Map<String,Duration>, by:Map<String,Duration>)
	{
		for (k in summary.keys())
			if (by.exists(k))
				by[k] += summary[k];
			else
				by[k] = summary[k];
	}

	static function main()
	{
		var files = Sys.args().copy();
		files.sort(Reflect.compare);
		if (files.length == 0) {
			Sys.println("
				plan timetracker – ptt

				Usage:
				  ptt <file> [<file> ..]
			".doctrim());
			Sys.exit(1);
		}

		var total = new Map();
		while (files.length > 0) {
			var file = files.shift();
			switch [FileSystem.exists(file), FileSystem.isDirectory(file)] {
			case [false, _]:
				warn('File does not exist: $file');
			case [true, true]:
				info('=> Entering directory $file');
				var dir = FileSystem.readDirectory(file).map(function (p) return haxe.io.Path.join([file, p]));
				dir.sort(Reflect.compare);
				files = dir.concat(files);
			case [true, false]:
				info('=> $file');
				var entries = getEntries(sys.io.File.getContent(file));
				var daily = new Map();
				for (e in entries) {
					if (daily.exists(e.channel))
						daily[e.channel] += e.duration;
					else
						daily[e.channel] = e.duration;
				}
				printSummary(daily, info);
				absorbSummary(daily, total);
			}
		}
		Sys.println("=> Summary:");
		printSummary(total, Sys.println);
	}
}

