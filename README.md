# ogmo-conv
Converts your Ogmo Editor 2 project/level XML files to work with Ogmo Editor 3!

**CAUTION:** This mostly works, but it still has some known issues! Don't expect a 100% accurate conversion yet! See the Progress section of the README for more details.

The logic is written in Haxe but compiles to a Python 3 script for convenient use.

## Usage:

`python ogmo-conv.py [-p projectFile] [-l levelFile] [-r rootLevelDirectory]`

You must specify a project file. You can specify individual levels with the `-l` flag, or a root directory that will recursively convert all levels in its subdirectories, or both. The generated files will appear next to their .oel/.oep counterparts.

## Build steps:
1. Install [Haxe](https://haxe.org/) and [Python 3](https://www.python.org/downloads/).
2. Navigate to the project directory.
3. Run `haxe build.hxml`
4. Behold the newly-created `ogmo-conv.py`

## Progress:

What works:
* Command line interface
* Project (.oep) conversion
* Level (.oel) conversion
* Automatically saving converted projects/levels to disk
* Directory-recursive conversion

What doesn't work:
* Tilemap layers using export modes other than CSV
* Grid layers using export modes other than Bitstring
* Probably other stuff
