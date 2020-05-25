import haxe.xml.Access;

class Converter {
        private var indent = 0;

        private function assignString(json:String, name:String, val:String): String {
		for (i in 0...indent) {
			json += "  ";
		}
		json += "\"" + name + "\": \"" + val + "\",\n";
		return json;
	}

	private function assignAny(json:String, name:String, val:Any): String {
		for (i in 0...indent) {
			json += "  ";
		}
		json += "\"" + name + "\": " + val + ",\n";
		return json;
	}

	private function assignSize(json:String, name:String, x:Int, y:Int): String {
		for (i in 0...indent) {
			json += "  ";
		}
		json += "\"" + name + "\": {\"x\": " + x + ", \"y\": " + y + "},\n";
		return json;
	}

	private function assign(json:String, name:String, val:String): String {
		for (i in 0...indent) {
			json += "  ";
		}
		json += "\"" + name + "\": " + val + ",\n";
		return json;
	}

	private function colorToString(colorNode: Access): String {
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
}