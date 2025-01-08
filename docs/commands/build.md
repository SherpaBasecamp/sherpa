# Build

Create the script from partials, generate docs, optimize.

## Overview

To be used from the root of a Sherpa project,
created with "sherpa new myProject".

It will:

* Generate a list of paths to be combined
* Extract paths from `use "collection/lib"` in bin.sh
* Put every partials together in a single file
* Generates docs from the shdoc comments
* Remove all full line comments
* Remove all empty lines
* Remove leading and trailing spaces
* Add the /usr/bin/env shebang
* Place the resulted script in target/local
* Make it executable
* Symlnk it to ~/.sherpa/bin for global availability

Usage: sherpa b, build


**Next: Flags to diferenciate build type**

Usage: sherpa b -t "lib"

- bin: Default. Creating an executable
- lib: Raw .sh files for fn() libraries


