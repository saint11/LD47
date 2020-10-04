package en;

class Interactive extends Entity {
	public static var ALL : Array<Interactive> = [];
    var interacting = false;
	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		weight = -1;
		imovable=true;
	}

	function onActivate(by:Hero) {
	}

	public function canBeActivated(by:Hero) {
		return !cd.has("lock");
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function postUpdate() {
		super.postUpdate();
	}

	public function activate(by:Hero) {
		onActivate(by);
	}

	override function onTouch(e:Entity) {
        super.onTouch(e);
        if (e.is(Hero)) {
            if (!cd.has("interacting")) {
                var h = e.as(Hero);
                h.stop();
                activate(h);
            }
            cd.setS("interacting", 0.8);
        }
	}

	override public function update() {
		super.update();
	}

	
    override function hit(dmg:Data.Damage, from:Null<Entity>, reduction: Float = 1) {
        
    }

}