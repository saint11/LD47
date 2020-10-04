package en;

import h2d.Anim;

class FloorTrap extends Entity {
    public function new(x,y) {
        super(x,y);
        hasColl=false;

        zPrio = -1000;
        spr.anim.registerStateAnim("trap_floor", 0, 0.2);
    }
}