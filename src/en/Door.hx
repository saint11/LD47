package en;

import hxd.Direction;


class Door extends Entity {
    public function new(x,y, dir:Direction) {
        super(x,y);

        spr.set("door");
        spr.setCenterRatio();
        
        
        hasColl = false;
    }
}