package en;

import hxsl.Types.Vec;
import h2d.Anim;

class FloorTrap extends Entity {

    public var color:Vec;

    public function new(x,y) {
        super(x,y);
        hasColl=false;

        zPrio = -1000;
        spr.anim.registerStateAnim("trap_floor_stop", 5, 0.2, level.isComplete);
        spr.anim.registerStateAnim("trap_floor", 0, 0.2);

        spr.setCenterRatio(0.5, 0.75);
    }

    override function update() {
        spr.color = color;
        super.update();
        if (spr.frame == 3 || spr.frame == 4) {
            for (e in Entity.ALL)
                {
                    if (e!=this && e.hasCircColl() && e.hasCircCollWith(this)){
                        if (distCase(e)<1.2) {
                            e.hit(Data.damage.get(trap_damage), this);
                        }
                    }
                }
            }
        }

    override function hasCircColl():Bool {
        return false;
    }
}