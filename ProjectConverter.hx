import haxe.Exception;
import haxe.io.Path;
import sys.io.File;
import haxe.xml.Access;
using StringTools;

class ProjectConverter {
	private static var indent = 0;

	public static function convert(projectPath: Path, rootDirectory: Path): ProjectData {
		// Read and parse XML
		var rawContent: String = "";
		try {
			rawContent = File.getContent(projectPath.toString());
		}
		catch(e) {
			trace("ERROR: Could not open project file " + projectPath + "!");
			Sys.exit(1);
		}
		var content = rawContent.replace("xsi:type", "xsitype");
		var xml = new Access(Xml.parse(content).firstElement());

		// Here we go!
		var json = "{\n";
		indent++;

		// Misc metadata
		json = assignString(json, "name", xml.node.Name.innerData);
		json = assignString(json, "ogmoVersion", "3.3.0");

		// Level paths
		var path = (rootDirectory == null || rootDirectory.toString() == "") ? "." : rootDirectory.toString();
		json = assign(json, "levelPaths", "[\"" + path + "\"]");

		// Settings
		json = assignString(json, "backgroundColor", colorToString(xml.node.BackgroundColor));
		json = assignString(json, "gridColor", colorToString(xml.node.GridColor));
		json = assignAny(json, "anglesRadians", xml.node.AngleMode.innerData == "Radians");
		json = assignAny(json, "directoryDepth", 5);

		// Sizes
		json = assignSize(json, "layerGridDefaultSize", 16, 16);
		json = assignSize(
			json,
			"levelDefaultSize",
			Std.parseInt(xml.node.LevelDefaultSize.node.Width.innerData),
			Std.parseInt(xml.node.LevelDefaultSize.node.Height.innerData)
		);
		json = assignSize(
			json,
			"levelMinSize",
			Std.parseInt(xml.node.LevelMinimumSize.node.Width.innerData),
			Std.parseInt(xml.node.LevelMinimumSize.node.Height.innerData)
		);
		json = assignSize(
			json,
			"levelMaxSize",
			Std.parseInt(xml.node.LevelMaximumSize.node.Width.innerData),
			Std.parseInt(xml.node.LevelMaximumSize.node.Height.innerData)
		);

		// Level values
		json = assign(json, "levelValues", getValuesArray(xml.node.LevelValueDefinitions));

		// More metadata!
		json = assignString(json, "defaultExportMode", ".json");
		json = assignAny(json, "compactExport", false);
		json = assignString(json, "externalScript", "");
		json = assignString(json, "playCommand", "");

		// Tags, which OE2 doesn't have
		json = assign(json, "entityTags", "[]");

		// Layers
		json = assign(json, "layers", getLayersArray(xml.node.LayerDefinitions));

		// Entities
		json = assign(json, "entities", getEntitiesArray(xml.node.EntityDefinitions));

		// Tilesets
		json = assign(json, "tilesets", getTilesetsArray(xml.node.Tilesets));

		// Strip trailing comma...
		json = json.substring(0, json.length - 2);
		json += "\n";

		// We're done!
		json += "}\n";
		trace(json);

		// TODO: Return struct containing only relevant bits for level files
		return null;
	}

	private static function assignString(json:String, name:String, val:String): String {
		for (i in 0...indent) {
			json += "  ";
		}
		json += "\"" + name + "\": \"" + val + "\",\n";
		return json;
	}

	private static function assignAny(json:String, name:String, val:Any): String {
		for (i in 0...indent) {
			json += "  ";
		}
		json += "\"" + name + "\": " + val + ",\n";
		return json;
	}

	private static function assignSize(json:String, name:String, x:Int, y:Int): String {
		for (i in 0...indent) {
			json += "  ";
		}
		json += "\"" + name + "\": {\"x\": " + x + ", \"y\": " + y + "},\n";
		return json;
	}

	private static function assign(json:String, name:String, val:String): String {
		for (i in 0...indent) {
			json += "  ";
		}
		json += "\"" + name + "\": " + val + ",\n";
		return json;
	}

	private static function colorToString(colorNode: Access): String {
		var r = Std.parseInt(colorNode.att.R);
		var g = Std.parseInt(colorNode.att.G);
		var b = Std.parseInt(colorNode.att.B);
		var a = Std.parseInt(colorNode.att.A);
		var str = "#" + StringTools.hex(r, 2) +
				StringTools.hex(g, 2) +
				StringTools.hex(b, 2) +
				StringTools.hex(a, 2);
		return str.toLowerCase();
	}

	private static function defToString(attrib: String): String {
		switch (attrib) {
			case "IntValueDefinition":
				return "Integer";
			case "BoolValueDefinition":
				return "Boolean";
			case "FloatValueDefinition":
				return "Float";
			case "StringValueDefinition":
				return "String";
			case "EnumValueDefinition":
				return "Enum";
			case "ColorValueDefinition":
				return "Color";

			case "TileLayerDefinition":
				return "tile";
			case "EntityLayerDefinition":
				return "entity";
			case "GridLayerDefinition":
				return "grid";
		}

		throw new Exception("Unknown layer definition: " + attrib);
	}

	private static function drawModeToInt(mode:String): Int {
		switch (mode) {
			case "Path":
				return 0;
			case "Circuit":
				return 1;
			case "Fan":
				return 2;
			case "None":
				return 3;
		}

		throw new Exception("Unknown draw mode: " + mode);
	}

	private static function getShapeString(): String {
		var str = "{\n";
		indent++;
		str = assignString(str, "label", "Rectangle");
		str += "        \"points\": [\n";
		str += "          {\"x\": -1, \"y\": -1},\n";
		str += "          {\"x\": 1, \"y\": -1},\n";
		str += "          {\"x\": -1, \"y\": 1},\n";
		str += "          {\"x\": 1, \"y\": -1},\n";
		str += "          {\"x\": -1, \"y\": 1},\n";
		str += "          {\"x\": 1, \"y\": 1}\n";
		str += "        ]\n";
		str += "      }";
		indent--;
		return str;
	}

	private static function getValuesArray(root:Access): String {
		var valuesStr = "[]";
		if (root.elements.hasNext()) {
			valuesStr = "[\n";
			for (e in root.elements) {
				indent++;
				for (i in 0...indent) {
					valuesStr += "  ";
				}
				valuesStr += "{\n";
				indent ++;

				valuesStr = assignString(
					valuesStr,
					"name",
					e.att.Name
				);

				var defString = defToString(e.att.xsitype);
				if (e.has.MultiLine && e.att.MultiLine == "true") {
					// Multiline strings are now "Text" in OE3
					defString = "Text";
				}
				valuesStr = assignString(
					valuesStr,
					"definition",
					defString
				);

				// Definition-specific members
				if (defString == "Integer") {
					valuesStr = assignAny(
						valuesStr,
						"defaults",
						Std.parseInt(e.att.Default)
					);
					valuesStr = assignAny(
						valuesStr,
						"bounded",
						false
					);
					valuesStr = assignAny(
						valuesStr,
						"min",
						Std.parseInt(e.att.Min)
					);
					valuesStr = assignAny(
						valuesStr,
						"max",
						Std.parseInt(e.att.Max)
					);
				}
				else if (defString == "Boolean") {
					valuesStr = assignAny(
						valuesStr,
						"defaults",
						(e.att.Default == "true")
					);
				}
				else if (defString == "Float") {
					valuesStr = assignAny(
						valuesStr,
						"defaults",
						Std.parseFloat(e.att.Default)
					);
					valuesStr = assignAny(
						valuesStr,
						"bounded",
						false
					);
					valuesStr = assignAny(
						valuesStr,
						"min",
						Std.parseFloat(e.att.Min)
					);
					valuesStr = assignAny(
						valuesStr,
						"max",
						Std.parseFloat(e.att.Max)
					);
				}
				else if (defString == "String") {
					valuesStr = assignString(
						valuesStr,
						"defaults",
						e.att.Default
					);
					valuesStr = assignAny(
						valuesStr,
						"maxLength",
						Math.max(Std.parseInt(e.att.MaxChars), 0)
					);
					valuesStr = assignAny(
						valuesStr,
						"trimWhitespace",
						true
					);
				}
				else if (defString == "Enum") {
					var choices = "[";
					if (e.hasNode.Elements) {
						for (c in e.node.Elements.elements) {
							choices += "\"" + c.innerData + "\", ";
						}
						choices = choices.substring(0, choices.length - 2);
					}
					choices += "]";
					valuesStr = assign(
						valuesStr,
						"choices",
						choices
					);
					valuesStr = assignAny(
						valuesStr,
						"defaults",
						0
					);
				}
				else if (defString == "Color") {
					valuesStr = assignString(
						valuesStr,
						"defaults",
						colorToString(e.node.Default)
					);
					valuesStr = assignAny(
						valuesStr,
						"includeAlpha",
						true
					);
				}
				else if (defString == "Text") {
					valuesStr = assignString(
						valuesStr,
						"defaults",
						e.att.Default
					);
				}

				// Strip trailing comma
				valuesStr = valuesStr.substring(0, valuesStr.length - 2);
				valuesStr += "\n";

				indent--;
				for (i in 0...indent) {
					valuesStr += "  ";
				}
				valuesStr += "},\n";
				indent--;
			}

			// Strip trailing comma
			valuesStr = valuesStr.substring(0, valuesStr.length - 2);
			valuesStr += "\n";

			for (i in 0...indent) {
				valuesStr += "  ";
			}
			valuesStr += "]";
		}
		return valuesStr;
	}

	private static function getLayersArray(root:Access): String {
		var layerStr = "[]";
		if (root.elements.hasNext()) {
			var eid = 0;
			layerStr = "[\n";
			for (e in root.elements) {
				indent++;
				for (i in 0...indent) {
					layerStr += "  ";
				}
				layerStr += "{\n";
				indent ++;

				layerStr = assignString(
					layerStr,
					"definition",
					defToString(e.att.xsitype)
				);
				layerStr = assignString(
					layerStr,
					"name",
					e.node.Name.innerData
				);
				layerStr = assignSize(
					layerStr,
					"gridSize",
					Std.parseInt(e.node.Grid.node.Width.innerData),
					Std.parseInt(e.node.Grid.node.Height.innerData)
				);
				layerStr = assignString(
					layerStr,
					"exportID",
					Std.string(eid++)
				);

				// Definition-specific members
				if (e.att.xsitype == "GridLayerDefinition") {
					layerStr = assignAny(
						layerStr,
						"arrayMode",
						0 // FIXME: Depends on ExportMode... I think?
					);
					layerStr = assignAny(
						layerStr,
						"legend",
						"{\"0\": \"#00000000\", \"1\": \"" + colorToString(e.node.Color) + "\"}"
					);
				}
				else if (e.att.xsitype == "TileLayerDefinition") {
					layerStr = assignAny(
						layerStr,
						"exportMode",
						0 // FIXME: Depends on ExportMode!
					);
					layerStr = assignAny(
						layerStr,
						"arrayMode",
						0
					);
					layerStr = assignString(
						layerStr,
						"defaultTileset",
						""
					);
				}
				else if (e.att.xsitype == "EntityLayerDefinition") {
					layerStr = assign(
						layerStr,
						"requiredTags",
						"[]"
					);
					layerStr = assign(
						layerStr,
						"excludedTags",
						"[]"
					);
				}

				// Strip trailing comma
				layerStr = layerStr.substring(0, layerStr.length - 2);
				layerStr += "\n";

				indent--;
				for (i in 0...indent) {
					layerStr += "  ";
				}
				layerStr += "},\n";
				indent--;
			}

			// Strip trailing comma
			layerStr = layerStr.substring(0, layerStr.length - 2);
			layerStr += "\n";

			for (i in 0...indent) {
				layerStr += "  ";
			}
			layerStr += "]";
		}
		return layerStr;
	}

	private static function getTilesetsArray(root: Access): String {
		var tilesetStr = "[]";
		if (root.elements.hasNext()) {
			tilesetStr = "[\n";
			for (e in root.elements) {
				indent++;
				for (i in 0...indent) {
					tilesetStr += "  ";
				}
				tilesetStr += "{\n";
				indent ++;

				tilesetStr = assignString(
					tilesetStr,
					"label",
					e.node.Name.innerData
				);
				tilesetStr = assignString(
					tilesetStr,
					"path",
					Path.normalize(e.node.FilePath.innerData).toString()
				);
				tilesetStr = assignString(
					tilesetStr,
					"image",
					"" // FIXME
				);
				tilesetStr = assignAny(
					tilesetStr,
					"tileWidth",
					Std.parseInt(e.node.TileSize.node.Width.innerData)
				);
				tilesetStr = assignAny(
					tilesetStr,
					"tileHeight",
					Std.parseInt(e.node.TileSize.node.Height.innerData)
				);
				tilesetStr = assignAny(
					tilesetStr,
					"tileSeparationX",
					Std.parseInt(e.node.TileSep.innerData)
				);
				tilesetStr = assignAny(
					tilesetStr,
					"tileSeparationY",
					Std.parseInt(e.node.TileSep.innerData)
				);

				// Strip trailing comma
				tilesetStr = tilesetStr.substring(0, tilesetStr.length - 2);
				tilesetStr += "\n";

				indent--;
				for (i in 0...indent) {
					tilesetStr += "  ";
				}
				tilesetStr += "},\n";
				indent--;
			}

			// Strip trailing comma
			tilesetStr = tilesetStr.substring(0, tilesetStr.length - 2);
			tilesetStr += "\n";

			for (i in 0...indent) {
				tilesetStr += "  ";
			}
			tilesetStr += "]";
		}
		return tilesetStr;
	}

	private static function getEntitiesArray(root: Access): String {
		var entitiesStr = "[]";
		if (root.elements.hasNext()) {
			var eid = 0;
			entitiesStr = "[\n";
			for (e in root.elements) {
				entitiesStr += "    {\n";
				indent += 2;

				entitiesStr = assignString(
					entitiesStr,
					"exportID",
					Std.string(eid++)
				);
				entitiesStr = assignString(
					entitiesStr,
					"name",
					e.att.Name
				);
				entitiesStr = assignAny(
					entitiesStr,
					"limit",
					Std.parseInt(e.att.Limit)
				);
				entitiesStr = assignSize(
					entitiesStr,
					"size",
					Std.parseInt(e.node.Size.node.Width.innerData),
					Std.parseInt(e.node.Size.node.Height.innerData)
				);
				entitiesStr = assignSize(
					entitiesStr,
					"origin",
					Std.parseInt(e.node.Origin.node.X.innerData),
					Std.parseInt(e.node.Origin.node.Y.innerData)
				);
				entitiesStr = assignAny(
					entitiesStr,
					"originAnchored",
					true
				);
				entitiesStr = assign(
					entitiesStr,
					"shape",
					getShapeString()
				);
				entitiesStr = assignString(
					entitiesStr,
					"color",
					colorToString(e.node.ImageDefinition.node.RectColor)
				);
				entitiesStr = assignAny(
					entitiesStr,
					"tileX",
					(e.node.ImageDefinition.att.Tiled == "true")
				);
				entitiesStr = assignAny(
					entitiesStr,
					"tileY",
					(e.node.ImageDefinition.att.Tiled == "true")
				);
				entitiesStr = assignSize(
					entitiesStr,
					"tileSize",
					Std.parseInt(e.node.Size.node.Width.innerData),
					Std.parseInt(e.node.Size.node.Height.innerData)
				);
				entitiesStr = assignAny(
					entitiesStr,
					"resizeableX",
					(e.att.ResizableX == "true")
				);
				entitiesStr = assignAny(
					entitiesStr,
					"resizeableY",
					(e.att.ResizableY == "true")
				);
				entitiesStr = assignAny(
					entitiesStr,
					"rotatable",
					(e.att.Rotatable == "true")
				);
				entitiesStr = assignAny(
					entitiesStr,
					"rotationDegrees",
					360
				);
				entitiesStr = assignAny(
					entitiesStr,
					"canFlipX",
					false // FIXME: Is this right?
				);
				entitiesStr = assignAny(
					entitiesStr,
					"canFlipY",
					false // FIXME: Is this right?
				);
				entitiesStr = assignAny(
					entitiesStr,
					"canSetColor",
					false // FIXME: Is this right?
				);
				entitiesStr = assignAny(
					entitiesStr,
					"hasNodes",
					(e.node.NodesDefinition.att.Enabled == "true")
				);
				entitiesStr = assignAny(
					entitiesStr,
					"nodeLimit",
					Math.max(Std.parseInt(e.node.NodesDefinition.att.Limit), 0)
				);
				entitiesStr = assignAny(
					entitiesStr,
					"nodeDisplay",
					drawModeToInt(e.node.NodesDefinition.att.DrawMode)
				);
				entitiesStr = assignAny(
					entitiesStr,
					"nodeGhost",
					(e.node.NodesDefinition.att.Ghost == "true")
				);
				entitiesStr = assign(
					entitiesStr,
					"tags",
					"[]"
				);
				entitiesStr = assign(
					entitiesStr,
					"values",
					getValuesArray(e.node.ValueDefinitions)
				);

				if (e.node.ImageDefinition.att.DrawMode == "Image") {
					entitiesStr = assignString(
						entitiesStr,
						"texture",
						Path.normalize(e.node.ImageDefinition.att.ImagePath).toString()
					);
					entitiesStr = assignString(
						entitiesStr,
						"textureImage",
						"" // FIXME
					);
				}

				// Strip trailing comma
				entitiesStr = entitiesStr.substring(0, entitiesStr.length - 2);
				entitiesStr += "\n";

				indent--;
				for (i in 0...indent) {
					entitiesStr += "  ";
				}
				entitiesStr += "},\n";
				indent--;
			}

			// Strip trailing comma
			entitiesStr = entitiesStr.substring(0, entitiesStr.length - 2);
			entitiesStr += "\n";

			for (i in 0...indent) {
				entitiesStr += "  ";
			}
			entitiesStr += "]";
		}
		return entitiesStr;
	}
}