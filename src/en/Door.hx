package en;

import hxd.Direction;


class Door extends Entity {
    public function new(x,y, dir:Direction) {
        super(x,y);

        spr.set("door");
        spr.setCenterRatio();

        if (flip)
            spr.scaleX = -1;
        
        hasColl = false;
    }
}