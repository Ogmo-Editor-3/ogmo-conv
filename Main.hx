import haxe.io.Path;

class Main {
	static public function main():Void {
		var args = Sys.args();
		if (args.length == 0 || args[0] == "--help") {
			trace("Usage: ogmo-conv.py [-p projectFile] [-l levelFile] [-r rootLevelDirectory] [-o outDirectory]");
			Sys.exit(0);
		}

		var projectFile: String = "";
		var levelFiles: Array<String> = new Array<String>();
		var rootDirectory: String = "";
		var outDirectory: String = "";

		// Process arguments
		var flagType = "";
		for (arg in args) {

			// Read flags
			if (arg == "-p" || arg == "-l" || arg == "-r" || arg == "-o") {
				flagType = arg;
				continue;
			}

			// Read argument data
			if (flagType == "-p") {
				if (projectFile != "") {
					trace("ERROR: Only one project file can be specified at a time!");
					Sys.exit(1);
				}
				projectFile = arg;
			}
			else if (flagType == "-l") {
				levelFiles.push(arg);
			}
			else if (flagType == "-r") {
				rootDirectory = arg;
			}
			else if (flagType == "-o") {
				if (outDirectory != "") {
					trace("ERROR: Only one output directory can be specified at a time!");
					Sys.exit(1);
				}
				outDirectory = arg;
			}
			else {
				trace("ERROR: Unknown argument or flag '" + arg + "'.");
				Sys.exit(1);
			}

			// Reset
			flagType = "";
		}

		if (projectFile == "") {
			trace("ERROR: No project file specified!");
			Sys.exit(1);
		}

		// Convert the project file
		var projectData = ProjectConverter.convert(new Path(projectFile), new Path(rootDirectory));

		// Convert any levels specified
		var numLevelsConverted = 0;
		// for (level in levelFiles) {
		// 	LevelConverter.convert(new Path(level), projectData);
		// 	numLevelsConverted++;
		// }

		// Convert the directory recursively
		// TODO

		// Display a "done!" message
		trace("Finished! Converted " + numLevelsConverted + " levels!");
	}
}