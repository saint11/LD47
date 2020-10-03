package en;

import hxsl.Types.Vec;
import hxd.Direction;


class Door extends Entity {
    public function new(x,y, dir) {
        super(x,y);

        spr.set("door");
        spr.setCenterRatio();
        
        this.dir = dir;
        
        hasColl = false;

        zPrio = -100000;
    }

    override function update() {
        super.update();

        if (level.hero.hasColl && distCase(level.hero, 0, 0.25)<1.12) {
            level.hero.enterDoor(this);
            spr.color = new Vec(0.1,1,0.1);
        }
        else 
            spr.color = new Vec(1,1,1);
    }
}