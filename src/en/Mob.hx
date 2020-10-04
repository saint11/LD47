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

    var loot = true;

    var ai: Array<Data.AI>;
    public function new(x,y, ref : World.Entity_Mob) {
        super(x,y);

        ALL.push(this);

        spr.anim.registerStateAnim("zombie_idle", 0);
        spr.anim.registerStateAnim("zombie_walk", 1, 0.15, ()-> moving!=0);
        spr.anim.registerStateAnim("zombie_hit", 1, 0.15, ()-> hasAffect(Stun));
        
        data = Data.mobs.resolve(ref.f_MobType.getName());
        
        setAffectS(Sleep, rnd(0.5, 2) + data.sleep);
        initLife(data.hp);
        if (data.money!=null) {
            moneyMin = data.money[0];
            moneyMax = data.money[1];
        }

        ai = [];
        for (a in data.ai)
            ai.push(a.ai);

        enableShadow();
    }

    override function update() {
        super.update();

        moving=0;
        if (!hasAffect(Stun) && !hasAffect(Sleep)) {
            for (ai in ai)
            switch ai {
            case Idle, Explode:
                
            case Chase:
                var a = angTo(game.hero);
                moving=data.moveSpeed;
                dx += Math.cos(a)*tmod*data.moveSpeed;
                dy += Math.sin(a)*tmod*data.moveSpeed;
                dir = -dirTo(game.hero);
            case Shoot(min,max):
                if (!cd.hasSetS("shooter", rnd(min,max))) {
                    var p = new Projectile(centerX, centerY, angTo(game.hero), this, data.projectile);
                    p.spr.color = new Vec(0.3,1,0.3);
                }
            }
        }
    }

    override function onDie() {
        super.onDie();
        if (data.explosion!=null) {
            fx.explode(centerX , centerY - 64, "explosion_big", 1.2);
            for (e in Entity.ALL) {
                if (e.hasCircColl() && e.hasCircCollWith(this) && distCase(e) < 2) {
                    e.hit(data.explosion,this);
                } else if (e.hasCircColl() && e.hasCircCollWith(this) && distCase(e) < 3) {
                    e.hit(data.explosion,this, 0.5);
                }
            }
        }
        // Drop loot
        if (loot)
        for (i in moneyMin... M.ceil(moneyMax * Game.ME.bonusMoney)) {
            var c = new Collectible(cx,cy);
            c.dx = rnd(-0.5, 0.5);
            c.dy = rnd(-0.5, 0.5);
        }
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function onTouch(other:Entity) {
        super.onTouch(other);
        if (other.is(Hero)) {
            if(data.touchDamage!=null) {
                other.hit(data.touchDamage, this);
            }

            if (data.explosion!=null){
                kill(this);
                loot=false;
            }
        }
    }
}