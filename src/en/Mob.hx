package en;

import dn.Rand;
import Data.Damage;
import h3d.IDrawable;
import hxsl.Types.Vec;

class Mob extends Entity {
    
    public static var ALL:Array<Mob> = [];
    var data : Data.Mobs;

    var moving:Float = 0;

    var moneyMin =0;
    var moneyMax =0;
    public function new(x,y, ref : World.Entity_Mob) {
        super(x,y);

        ALL.push(this);

        spr.anim.registerStateAnim("zombie_idle", 0);
        spr.anim.registerStateAnim("zombie_walk", 1, 0.15, ()-> moving>0);
        
        setAffectS(Stun, rnd(0.5, 1));

        data = Data.mobs.resolve(ref.f_MobType.getName());
        initLife(data.hp);
        if (data.money!=null) {
            moneyMin = data.money[0];
            moneyMax = data.money[1];
        }

        enableShadow();
    }

    override function update() {
        super.update();

        moving=0;
        if (!hasAffect(Stun)) {
            for (ai in data.ai)
            switch ai.ai {
            case Idle:
                
            case Chase:
                var a = angTo(level.hero);
                moving=data.moveSpeed;
                dx += Math.cos(a)*tmod*data.moveSpeed;
                dy += Math.sin(a)*tmod*data.moveSpeed;
                dir = -dirTo(level.hero);
            case Shoot:
            }
        }
    }

    override function onDie() {
        super.onDie();
        
        // Drop loot
        for (i in moneyMin...moneyMax) {
            var c = new Collectible(cx,cy);
            c.dx = rnd(-0.5, 0.5);
            c.dy = rnd(-0.5, 0.5);
        }
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function hit(dmg:Damage, from:Null<Entity>) {
        super.hit(dmg, from);
        setAffectS(Stun, 0.4);
    }

    override function onTouch(other:Entity) {
        super.onTouch(other);
        if (data.touchDamage!=null && other.is(Hero)) 
             other.hit(data.touchDamage, this);
    }
}