package en;

class Projectile extends Entity {
    static var sfxPop = [
        Assets.SBANK.pop1,
        Assets.SBANK.pop2,
        Assets.SBANK.pop3,
        Assets.SBANK.pop4,
    ];
    public var ALL:Array<Projectile> = [];

    var owner:Entity;
    var data:Data.Projectiles;
    var lifeSpan = 0.;
    var maxLifespan = 0.;
    public function new(x, y, angle, owner, data: Data.Projectiles) {
        ALL.push(this);
        
        this.owner = owner;
        
        super(0,0);

        setPosPixel(x,y);

        frictX = data.friction;
        frictY = data.friction;

        dx = Math.cos(angle)*tmod*data.speed;
        dy = Math.sin(angle)*tmod*data.speed;

        var imgs = ["simple", "shrapnel","bomb","bomb_en","enemy"];
        spr.anim.registerStateAnim("p_" + imgs[data.image.toInt()], 0, 0.1);
        spr.setCenterRatio();
        weight = 0;

        enableShadow(0.5);
        tall = true;
        gravity= data.gravity;
        altitude = data.startAltitude;
        maxLifespan = data.lifespan + rnd(-data.lifespanVar, data.lifespanVar);
        sprScaleY = sprScaleX = data.scale;

        jump(data.jump);
        this.data = data;
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }
    
    override function onTouchWallX() {
        if (lifeSpan>0.05 && data.breakOnWall)
            explode();
    }

    override function onTouchWallY() {
        if (lifeSpan>0.05 && data.breakOnWall)
            explode();
    }

    override function onTouch(e:Entity) {
        if (data.dmgOnTouch) {
            e.hit(data.dmg, this);
            explode();
        }
    }

    override function hasCircCollWith(e:Entity):Bool {
        return e != owner && !e.is(Projectile);
    }


    public function explode() {
        if (data.explode) {
            Assets.SBANK.boom(1);
            fx.explode(centerX , centerY - 64, "explosion_big", false);
            level.addSplatter("explosion_big_ground", centerX , centerY);
            for (e in Entity.ALL) {
                var mul = 1.;
                if (e == owner) 
                    mul = 0.25;

                if (e.hasCircColl() && e.hasCircCollWith(this) && distCase(e) < 2) {
                    e.hit(data.dmg,this, mul);
                } else if (e.hasCircColl() && e.hasCircCollWith(this) && distCase(e) < 3) {
                    if (!e.is(Hero))
                        e.hit(data.dmg,this, 0.5 * mul);
                }
            }
        } else {
            
            if (!game.cd.hasSetMs("projectileSfx",50)) {
                var s = sfxPop[Std.random(sfxPop.length)]();
                s.play(rnd(0.4,0.6));
            }

            fx.explode(centerX,centerY, "explosion_green", false);
        }

        destroy();
    }

    override function hit(dmg:Data.Damage, from:Null<Entity>, reduction: Float = 1) {
        
    }

    override function update() {
        super.update();
        lifeSpan += tmod;
        if (lifeSpan>maxLifespan)
            explode();
    }

}