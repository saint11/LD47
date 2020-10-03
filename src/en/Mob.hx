package en;

import Data.Damage;
import h3d.IDrawable;
import hxsl.Types.Vec;

class Mob extends Entity {
    
    public static var ALL:Array<Mob> = [];
    var data : Data.Mobs;

    public function new(x,y, ref : World.Entity_Mob) {
        super(x,y);

        ALL.push(this);

        spr.set("test_tile");
        spr.color = new Vec(1,0,0);
        
        data = Data.mobs.resolve(ref.f_MobType.getName());
        initLife(data.hp);
    }

    override function update() {
        super.update();

        if (!hasAffect(Stun)) {
            for (ai in data.ai)
            switch ai.ai {
            case Idle:
                
            case Chase:
                var a = angTo(level.hero);
                dx += Math.cos(a)*tmod*data.moveSpeed;
                dy += Math.sin(a)*tmod*data.moveSpeed;
                
            case Shoot:
            }
        }
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function hit(dmg:Damage, from:Null<Entity>) {
        super.hit(dmg, from);
        setAffectS(Stun, 0.4);
        bumpAgainst(from, dmg.push);
    }
}