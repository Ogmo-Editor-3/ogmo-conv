# ogmo-conv
Converts your Ogmo Editor 2 project/level XML files to work with Ogmo Editor 3!

Still EXTREMELY early in development, please don't use this yet unless you know 100% for sure what you're doing!

The logic is written in Haxe but compiles to a Python 3 script for convenient use.

## Usage:

`python ogmo-conv.py [-p projectFile] [-l levelFile] [-r rootLevelDirectory] [-o outDirectory]`

## Build steps:
1. Install [Haxe](https://haxe.org/) and [Python 3](https://www.python.org/downloads/).
2. Navigate to the project directory.
3. Run `haxe build.hxml`
4. Behold the newly-created `ogmo-conv.py`

## Progress:

What works:
* Command line interface
* Project (.oep) conversion

What doesn't work:
* Automatically saving converted projects to disk
* Converting levels
* Probably other stuff
