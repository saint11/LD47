package en;

import Data.Damage;
import hxsl.Types.Vec;
import h2d.Anim;

class FloorTrap extends Entity {

    public var color:Vec;

    public function new(x,y, auto, big) {
        super(x,y);
        hasColl=false;

        zPrio = -1000;
        imovable = true;
        weight= -1;

        if (big) {
            if (!auto)
                spr.anim.registerStateAnim("trap_floor_stop", 5, 0.2, level.isComplete);
            spr.anim.registerStateAnim("trap_floor", 0, 0.2);
            radius = 1.2 * Const.GRID/2;
        } else{
            if (!auto)
                spr.anim.registerStateAnim("spike_stop", 5, 0.2, ()-> return level.isComplete() || cd.has("wait") );
            else 
                spr.anim.registerStateAnim("spike_stop", 5, 0.2, ()-> cd.has("wait") );
            spr.anim.registerStateAnim("spike", 0, 0.2);
            sprScaleX = sprScaleX = 0.9;
            radius = 0.7 * Const.GRID/2;
            cd.setS("wait", rnd(0,2));
        }
        spr.setCenterRatio(0.5, 0.6);
    }

    override function update() {
        super.update();
        spr.color = color;
    }

    override function onTouch(other:Entity) {
        super.onTouch(other);
        
        if (spr.frame == 3 || spr.frame == 4) {
            other.hit(Data.damage.get(trap_damage), this);
        }
    }

    override function hasCircColl():Bool {
        if (spr.frame == 3 || spr.frame == 4) {
            return true;
        }
        return false;
    }

    override function hasCircCollWith(e:Entity):Bool {
        return e.is(Hero) || e.is(Mob);
    }

    override function hit(dmg:Damage, from:Null<Entity>, reduction:Float = 1) {
        
    }
}