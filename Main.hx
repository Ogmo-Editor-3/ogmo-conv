import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

class Main {
	static var numLevelsConverted:Int = 0;

	static public function main():Void {
		var args = Sys.args();
		if (args.length == 0 || args[0] == "--help") {
			trace("Usage: ogmo-conv.py [-p projectFile] [-l levelFile] [-r rootLevelDirectory]");
			Sys.exit(0);
		}

		var projectFile: String = "";
		var levelFiles: Array<String> = new Array<String>();
		var rootDirectory: String = "";

		// Process arguments
		var flagType = "";
		for (arg in args) {

			// Read flags
			if (arg == "-p" || arg == "-l" || arg == "-r") {
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
		var projectConverter = new ProjectConverter();
		projectConverter.convert(projectFile, rootDirectory);

		// Convert any levels specified
		var levelConverter = new LevelConverter();
		for (level in levelFiles) {
			levelConverter.convert(level, projectConverter.projectData);
			numLevelsConverted++;
		}

		// Convert all levels in the root directory and its subdirectories
		if (rootDirectory != "") {
			convertDirectoryRecursive(
				projectConverter,
				levelConverter,
				rootDirectory
			);
		}

		// Display a "done!" message
		trace("Finished! Converted " + numLevelsConverted + " levels!");
	}

	private static function convertDirectoryRecursive(
		projConv:ProjectConverter,
		levelConv:LevelConverter,
		rootDirectory:String
	) {
		var paths = FileSystem.readDirectory(rootDirectory);
		for (path in paths) {
			var fullPath = Path.addTrailingSlash(rootDirectory) + path;
			if (Path.extension(fullPath) == "oel") {
				levelConv.convert(fullPath, projConv.projectData);
				numLevelsConverted++;
			}
			else if (FileSystem.isDirectory(fullPath)) {
				convertDirectoryRecursive(projConv, levelConv, fullPath);
			}
		}
	}
}