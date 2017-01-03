plan-timetracker – ptt
======================

An utility to summarize time tracking annotations in my (J. Carmack inspired) plan files.

The basic usage is: ptt <file> [<file>..]

This works particularly well when combined with shell globbing and basic unix tools:

# Basic usage
$ bin/ptt ~/plan/2017
# Only md/txt files (usefull to get rid of garbage such as Vim .swp files)
$ bin/ptt ~/plan/2017/**/*.{md,txt} 2>/dev/null
# Discard the per day (file) output and other auxiliary information
$ bin/ptt ~/plan/2017/**/*.{md,txt} 2>/dev/null
# Pipe to grep to check for warnings
$ bin/ptt ~/plan/2017/**/*.{md,txt} 2>&1 | grep
# Or to less to analyze the warnings
$ bin/ptt ~/plan/2017/**/*.{md,txt} 2>&1 | less

