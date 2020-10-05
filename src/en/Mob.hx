package en;

import haxe.macro.Expr.Case;
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

        data = Data.mobs.resolve(ref.f_MobType.getName());
        
        spr.anim.registerStateAnim(data.sprite + "_walk", 0, 0.1 * data.animSpeed); //fallback
        spr.anim.registerStateAnim(data.sprite + "_idle", 1, 0.1 * data.animSpeed, ()-> hasAffect(Sleep));
        spr.anim.registerStateAnim(data.sprite + "_charge", 1, 0.1 * data.animSpeed, ()-> isChargingAction("jump"));
        spr.anim.registerStateAnim(data.sprite + "_walk", 2, 0.15 * data.animSpeed, ()-> moving!=0);
        spr.anim.registerStateAnim(data.sprite + "_hit", 3, 0.15 * data.animSpeed, ()-> hasAffect(Stun));
        
        setAffectS(Sleep, rnd(0.5, 2) + data.sleep);
        initLife(data.hp);
        if (data.money!=null) {
            moneyMin = data.money[0];
            moneyMax = data.money[1];
        }

        ai = [];
        for (a in data.ai)
            ai.push(a.ai);

        enableShadow(data.shadowScale);
    }

    override function update() {
        super.update();

        moving=0;
        if (!hasAffect(Stun) && !hasAffect(Sleep)) {
            for (ai in ai)
            switch ai {
            case Idle, Explode:
                
            case Chase:
                if(!isChargingAction("jump") && altitude<=2) {
                    var a = angTo(game.hero);
                    moving=data.moveSpeed;
                    dx += Math.cos(a)*tmod*data.moveSpeed;
                    dy += Math.sin(a)*tmod*data.moveSpeed;
                    dir = -dirTo(game.hero);
                    
                    frictX = 0.82;
                    frictY = 0.82;
                }
            case Shoot(min,max):
                if (!cd.hasSetS("shooter", rnd(min,max))) {
                    var p = new Projectile(centerX, centerY, angTo(game.hero), this, data.projectile);
                }
            case CrossShoot(min,max):
                if (!cd.hasSetS("crossShoot", rnd(min,max))) {
                    var p = new Projectile(centerX, centerY, 0 * M.DEG_RAD, this, data.projectile);
                    var p = new Projectile(centerX, centerY, 90 * M.DEG_RAD, this, data.projectile);
                    var p = new Projectile(centerX, centerY, 180 * M.DEG_RAD, this, data.projectile);
                    var p = new Projectile(centerX, centerY, -90 * M.DEG_RAD, this, data.projectile);
                }
            case Jump(range, delay):
                var a = angTo(game.hero);

                if (distCase(game.hero)<range) {
                    chargeAction("jump", delay, ()->{
                        moving=data.moveSpeed;
                        dx += Math.cos(a)*tmod*data.jumpSpeed;
                        dy += Math.sin(a)*tmod*data.jumpSpeed;
                        jump(3);
                        frictX = 0.95;
                        frictY = 0.95;
                        dir = -dirTo(game.hero);
                    });
                }
            }
        }
    }

    override function onDie() {
        super.onDie();
        if (data.explosion!=null) {
            Assets.SBANK.boom(1);

            fx.explode(centerX , centerY - 64, "explosion_big", 1.25, false);
            level.addSplatter("explosion_big_ground", centerX , centerY - 64);
            for (e in Entity.ALL) {
                if (e.hasCircColl() && e.hasCircCollWith(this) && distCase(e) < 2) {
                    e.hit(data.explosion,this);
                } else if (e.hasCircColl() && e.hasCircCollWith(this) && distCase(e) < 3) {
                    e.hit(data.explosion,this, 0.5);
                }
            }
        } else {
            fx.explode(footX , footY - 32, "blood_splatter", true);
        }
        // Drop loot
        if (loot)
        {
            var all = [
				Assets.SBANK.splat1,
				Assets.SBANK.splat2,
				Assets.SBANK.splat3
            ];
            var s = all[Std.random(all.length)]();
            s.play(1);
            
            var droppedBlood = M.ceil(M.randRange(moneyMin, moneyMax) * Game.ME.bonusMoney);
            for (i in 0...droppedBlood) {
                var c = new Collectible(cx,cy);
                c.dx = rnd(-0.5, 0.5);
                c.dy = rnd(-0.5, 0.5);
            }
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

    override function hit(dmg:Damage, from:Null<Entity>, reduction:Float = 1) {
        super.hit(dmg, from, reduction);
    }
}