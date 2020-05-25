import haxe.ds.Map;

class ValueData {
	public var definition:String;
	public var name:String;

	public function new(definition:String, name:String) {
		this.definition = definition;
		this.name = name;
	}
}

class EntityData {
	public var eid:String;
	public var originX:Int;
	public var originY:Int;
	public var values:Array<ValueData>;

	public function new(eid:String, originX:Int, originY:Int, values:Array<ValueData>) {
		this.eid = eid;
		this.originX = originX;
		this.originY = originY;
		this.values = values;
	}
}

class LayerData {
	public var definition:String;
	public var eid:String;
	public var cellWidth:Int;
	public var cellHeight:Int;

	public function new(
		definition:String,
		eid:String,
		cellWidth:Int,
		cellHeight:Int
	) {
		this.definition = definition;
		this.eid = eid;
		this.cellWidth = cellWidth;
		this.cellHeight = cellHeight;
	}
}

class ProjectData {
	public var values:Array<ValueData>;
	public var layers:Map<String, LayerData>;
	public var entities:Map<String, EntityData>;

	public function new() {
		values = new Array<ValueData>();
		layers = new Map<String, LayerData>();
		entities = new Map<String, EntityData>();
	}
}