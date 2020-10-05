package en;

import hxsl.Types.Vec;
import hxd.Direction;


class Door extends Entity {

    public var locked = false;
    var open:Bool = false;

    var doorTop:Entity;

    public function new(x,y, dir) {
        super(x,y);

        if (dir == 1) {
            spr.set("door_exit");
        } else {
            spr.set("door_entrance");
        }

        spr.setCenterRatio();
        
        doorTop = new Entity(x,y);
        doorTop.hasColl = false;
        doorTop.spr.set("door_top");
        doorTop.spr.setCenterRatio();
        doorTop.zPrio= 1000;
        doorTop.entityVisible=false;
        doorTop.dir= dir;

        this.dir = dir;
        
        hasColl = false;

        zPrio = -100000;
    }

    override function update() {
        super.update();

        if (!locked && level.isComplete()){
            if (open==false) {
                open = true;
                spr.set("door_open");
                sprSquashX = 1.25;
                spr.alpha = 1;
                doorTop.entityVisible=true;
                doorTop.sprSquashX = 1.25;
            }

            if (game.hero.hasColl && distCase(game.hero, 0, 0.75)<1.5) {
                game.hero.enterDoor(this);
            }
        }
    }

    public function setColor(c) {
        spr.color = c;
        doorTop.spr.color = c;
    }
}