package en;

import hxsl.Types.Vec;
import hxd.Direction;


class Door extends Entity {


    var open:Bool = false;

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

        if (level.isComplete()){
            if (open==false) {
                open = true;
                sprSquashX = 2;
                spr.alpha = 1;
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