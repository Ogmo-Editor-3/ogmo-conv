import ProjectData.ValueData;
import haxe.Exception;
import haxe.io.Path;
import sys.io.File;
import haxe.xml.Access;
using StringTools;

class LevelConverter extends Converter {
	public function new() { }

	public function convert(levelPath:String, data: ProjectData) {
		// Read and parse XML
		var rawContent: String = "";
		try {
			rawContent = File.getContent(levelPath);
		}
		catch(e) {
			trace("ERROR: Could not open project file " + levelPath + "!");
			Sys.exit(1);
		}
		var xml = new Access(Xml.parse(rawContent).firstElement());

		// Here we go!
		var json = "{\n";
		indent++;

		// Metadata
		json = assignString(json, "ogmoVersion", "3.3.0");
		json = assignAny(json, "width", Std.parseInt(xml.att.width));
		json = assignAny(json, "height", Std.parseInt(xml.att.height));
		json = assignAny(json, "offsetX", 0);
		json = assignAny(json, "offsetY", 0);

		// Layers
		json = assign(json, "layers", getLayersArray(xml, data));

		// Strip trailing comma...
		json = json.substring(0, json.length - 2);
		json += "\n";

		// We're done!
		json += "}\n";

		// Let's save the level to disk...
		var filename = Path.withoutExtension(Path.withoutDirectory(levelPath));
		var newPath = Path.addTrailingSlash(Path.directory(levelPath)) + filename + ".json";
		File.saveContent(newPath, json);
		trace("Saved " + newPath);
	}

	private function getLayersArray(root:Access, data:ProjectData): String {
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

				var gw = data.layers[e.name].cellWidth;
				var gh = data.layers[e.name].cellHeight;

				layerStr = assignString(
					layerStr,
					"name",
					e.name
				);
				layerStr = assignString(
					layerStr,
					"_eid",
					data.layers[e.name].eid
				);
				layerStr = assignAny(
					layerStr,
					"offsetX",
					0
				);
				layerStr = assignAny(
					layerStr,
					"offsetY",
					0
				);
				layerStr = assignAny(
					layerStr,
					"gridCellWidth",
					gw
				);
				layerStr = assignAny(
					layerStr,
					"gridCellHeight",
					gh
				);
				layerStr = assignAny(
					layerStr,
					"gridCellsX",
					Std.parseInt(root.att.width) / gw
				);
				layerStr = assignAny(
					layerStr,
					"gridCellsY",
					Std.parseInt(root.att.height) / gh
				);

				// Definition-specific members
				var def = data.layers[e.name].definition;
				if (def == "GridLayerDefinition") {
					layerStr = assign(
						layerStr,
						"grid",
						getGridDataString(e)
					);
					layerStr = assignAny(
						layerStr,
						"arrayMode",
						0 // FIXME
					);
				}
				else if (def == "TileLayerDefinition") {
					layerStr = assignString(
						layerStr,
						"tileset",
						e.att.tileset
					);
					layerStr = assign(
						layerStr,
						"data",
						getTilemapDataStr(e)
					);
					layerStr = assignAny(
						layerStr,
						"exportMode",
						0 // FIXME
					);
					layerStr = assignAny(
						layerStr,
						"arrayMode",
						0 // FIXME
					);
				}
				else if (def == "EntityLayerDefinition") {
					layerStr = assign(
						layerStr,
						"entities",
						getEntitiesArray(e, data)
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

	private function getGridDataString(xml:Access): String {
		// FIXME: Assumes bitstring!
		var str = "[";
		var data = xml.innerData.replace("\r\n", "").replace("\n", "");
		for (i in 0...data.length) {
			str += "\"" + data.charAt(i) + "\",";
		}
		str = str.substring(0, str.length - 1); // Remove trailing comma
		str += "]";
		return str;
	}

	private function getTilemapDataStr(xml:Access): String {
		// FIXME: Assumes CSV!
		return "[" + xml.innerData.replace("\r\n", ",").replace("\n", ",") + "]";
	}

	private function getEntitiesArray(root:Access, data:ProjectData): String {
		var entitiesStr = "[]";
		if (root.elements.hasNext()) {
			entitiesStr = "[\n";
			for (e in root.elements) {
				indent++;
				for (i in 0...indent) {
					entitiesStr += "  ";
				}
				entitiesStr += "{\n";
				indent++;

				entitiesStr = assignString(
					entitiesStr,
					"name",
					e.name
				);
				entitiesStr = assignAny(
					entitiesStr,
					"id",
					Std.parseInt(e.att.id)
				);
				entitiesStr = assignString(
					entitiesStr,
					"_eid",
					data.entities[e.name].eid
				);
				entitiesStr = assignAny(
					entitiesStr,
					"x",
					Std.parseInt(e.att.x)
				);
				entitiesStr = assignAny(
					entitiesStr,
					"y",
					Std.parseInt(e.att.y)
				);
				entitiesStr = assignAny(
					entitiesStr,
					"originX",
					data.entities[e.name].originX
				);
				entitiesStr = assignAny(
					entitiesStr,
					"originY",
					data.entities[e.name].originY
				);

				// Optional attributes
				if (e.has.width) {
					entitiesStr = assignAny(
						entitiesStr,
						"width",
						Std.parseInt(e.att.width)
					);
				}
				if (e.has.height) {
					entitiesStr = assignAny(
						entitiesStr,
						"height",
						Std.parseInt(e.att.height)
					);
				}
				if (e.has.angle) {
					entitiesStr = assignAny(
						entitiesStr,
						"rotation",
						Std.parseFloat(e.att.angle)
					);
				}

				// Nodes, if needed
				if (e.elements.hasNext()) {
					entitiesStr = assign(
						entitiesStr,
						"nodes",
						getNodeArray(e)
					);
				}

				// Values, if needed
				if (data.entities[e.name].values != null) {
					entitiesStr = assign(
						entitiesStr,
						"values",
						getValuesArray(e, data.entities[e.name].values)
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

	private function getValuesArray(xml:Access, values:Array<ValueData>) {
		var str = "{";
		for (v in values) {
			str += "\"" + v.name + "\": ";
			if (	v.definition == "IntValueDefinition"  ||
				v.definition == "BoolValueDefinition" ||
				v.definition == "FloatValueDefinition"
			) {
				str += xml.att.resolve(v.name);
			}
			else if (v.definition == "StringValueDefinition" ||
				 v.definition == "EnumValueDefinition"
			) {
				str += "\"" + xml.att.resolve(v.name) + "\"";
			}
			else if (v.definition == "ColorValueDefinition") {
				str += "\"" + formatColorValueStr(xml.att.resolve(v.name)) + "\"";
			}
			else {
				throw new Exception("Unknown value definition: " + v.definition);
			}
			str += ", ";
		}
		str = str.substring(0, str.length - 2);
		str += "}";
		return str;
	}

	private function formatColorValueStr(colstr:String): String {
		// OE2 color values are completely opaque
		return colstr.toLowerCase() + "ff";
	}

	private function getNodeArray(xml:Access): String {
		var str = "[\n";
		indent++;
		for (n in xml.elements) {
			for (i in 0...indent) {
				str += "  ";
			}
			str += "{\"x\": " + n.att.x + ", \"y\": " + n.att.y + "},\n";
		}
		indent--;

		// Strip trailing comma
		str = str.substring(0, str.length - 2);
		str += "\n";

		for (i in 0...indent) {
			str += "  ";
		}
		str += "]";
		return str;
	}
}