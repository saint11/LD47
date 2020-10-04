package en;

class Projectile extends Entity {
    
    public var ALL:Array<Projectile> = [];

    var owner:Entity;
    var data:Data.Projectiles;
    var lifeSpan = 0.;

    public function new(x, y, angle, owner, data: Data.Projectiles) {
        ALL.push(this);
        
        this.owner = owner;
        
        super(0,0);

        setPosPixel(x,y);

        frictX = data.friction;
        frictY = data.friction;

        dx = Math.cos(angle)*tmod*data.speed;
        dy = Math.sin(angle)*tmod*data.speed;

        spr.anim.registerStateAnim("p_simple", 0, 0.1);
        weight = 0;

        enableShadow(0.5);
        tall = true;
        gravity=0;
        altitude = 16;
        this.data = data;
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }
    
    override function onTouchWallX() {
        if (lifeSpan>0.1)
            explode();
    }

    override function onTouchWallY() {
        if (lifeSpan>0.1)
            explode();
    }

    override function onTouch(e:Entity) {
        e.hit(data.dmg, this);
        explode();
    }

    override function hasCircCollWith(e:Entity):Bool {
        return e != owner && !e.is(Projectile);
    }


    public function explode() {
        fx.explode(centerX,centerY, "explosion_green");
        destroy();
    }

    override function hit(dmg:Data.Damage, from:Null<Entity>, reduction: Float = 1) {
        
    }

    override function update() {
        super.update();
        lifeSpan += tmod;
        if (lifeSpan>data.lifespan)
            explode();
    }

}