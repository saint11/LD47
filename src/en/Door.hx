package en;

import hxsl.Types.Vec;
import hxd.Direction;


class Door extends Entity {


    var open:Bool = false;

    var doorTop:Entity;

    public function new(x,y, dir) {
        super(x,y);

        spr.set("door");
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

        if (level.isComplete()){
            if (open==false) {
                open = true;
                sprSquashX = 2;
                spr.alpha = 1;
                doorTop.entityVisible=true;
                doorTop.sprSquashX = 2;
            }

            if (game.hero.hasColl && distCase(game.hero, 0, 0.25)<1.12) {
                game.hero.enterDoor(this);
            }
        }
        else 
        {
            spr.alpha = 0;           
        }
    }
}