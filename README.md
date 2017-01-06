# ppt – plan time-tracker

**ptt** is an utility for time tracking analysis based on simple text file annotations.

It was originally created to summarize the annotations in my (J. Carmack inspired) plan files, but it's general enough to be used with other input sources.

## Example

```
$ ptt 2017/01/0[2-3].md
```

```
ptt – plan timetracker


=> 2017/01/02.md
 -> #online-brt-guide: 3h06'
 -> #admin: 1h40'
 -> #staff-meetings: 1h00'
 -> #team: 0h33'
 -> #imply: 0h02'
    6h21' in total
=> 2017/01/03.md
 -> #online-brt-guide: 3h49'
 -> #team: 2h06'
 -> #marketing: 0h40'
 -> #admin: 0h12'
 -> #staff-meetings: 0h05'
    6h52' in total
=> Summary:
 -> #online-brt-guide: 6h55'
 -> #team: 2h39'
 -> #admin: 1h52'
 -> #staff-meetings: 1h05'
 -> #marketing: 0h40'
 -> #imply: 0h02'
    13h13' in total
```

## Supported annotation format

Annotations should look something like:

```
`/log from <time> to <time> on #<tag>[optional ignored information]`
`/log <duration> on #<tag>[optional ignored information`
```

Splitting into it's components:

 - backtick
 - `/log` keyword (`\log` is also supported)
 - time span:
    + `from` keyword
    + time: `16h20`, `16:20` or `16.20`, optionally terminated with a `'` minute marker (for example `16h20'`)
    + `to` keyword
    + time: _(same as before)_
 - _or_ duration: `0h05`, `5'`, `5 min`, `5 minutes`, `2h` or `2 hours`
 - `on` keyword (`to` also works)
 - tag prefixed by a hash (`#`): a tag can only contain ASCII letters, numbers, underscores and hyphens
 - (optional information that will be ignored)
 - another backtick

_**ptt** will check and warn for potentially malformed annotations that could otherwise be lost._

## Usage

The basic usage is:

```
ptt <file> [<file> ...]
```

You can run `ptt --help` to view more options.

This works particularly well when combined with shell globbing and basic unix tools...

 - basic use case: `ptt ~/plan/2017`
 - only process md/txt files (useful to get rid of garbage such as Vim .swp files): `ptt ~/plan/2017/**/*.{md,txt} 2>/dev/null`
 - discard the per day (file) output and other auxiliary information: `ptt ~/plan/2017/**/*.{md,txt} 2>/dev/null`
 - pipe to grep to check for warnings: `ptt ~/plan/2017/**/*.{md,txt} 2>&1 | grep`
 - or to less to analyze the warnings: `ptt ~/plan/2017/**/*.{md,txt} 2>&1 | less`

## Installing

Currently this is not packaged. You need to build it from the sources, but that's easy: check the next section.

## Building

This is written in Haxe, and runs on the Neko VM.

To install the dependencies:

```
haxelib git https://github.com/protocubo/assertion.hx
haxelib git https://github.com/protocubo/literals.hx
haxelib install utest
```

To build:

```
haxe build.hxml
```

## Running or generating tests

Running the included tests:

```
ptt unit-test fixtures.test
```

You can also generate tests from your own files by running `ptt generate-test-file <test file> <annotation file> [<annotation file> ...]` and adjusting the resulting file by hand.

