package en;

import hxsl.Types.Vec;

class Mob extends Entity {
    public static var ALL:Array<Mob> = [];

    var data : World.Entity_Mob;

    public function new(x,y, data : World.Entity_Mob) {
        super(x,y);

        ALL.push(this);

        spr.set("test_tile");
        spr.color = new Vec(1,0,0);
        this.data = data;
    }

    override function update() {
        super.update();

        for (ai in data.f_AI)
        switch ai {
            case Idle:

            case Chase:
                var a = angTo(level.hero);
                dx += Math.cos(a)*tmod*data.f_MoveSpeed;
                dy += Math.sin(a)*tmod*data.f_MoveSpeed;

            case Shoot:
        }
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function takeHit():Bool {
        return true;
    }
}