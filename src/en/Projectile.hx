package en;

class Projectile extends Entity {
    
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

        var imgs = ["simple", "shrapnel"];
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
            fx.explode(centerX , centerY - 64, "explosion_big", 1.2);
            for (e in Entity.ALL) {
                if (e.hasCircColl() && e.hasCircCollWith(this) && distCase(e) < 2) {
                    e.hit(data.dmg,this);
                } else if (e.hasCircColl() && e.hasCircCollWith(this) && distCase(e) < 3) {
                    e.hit(data.dmg,this, 0.5);
                }
            }
        } else {
            fx.explode(centerX,centerY, "explosion_green");
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