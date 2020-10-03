package en;

class Projectile extends Entity {
    
    public var ALL:Array<Projectile> = [];

    var owner:Entity;

    public function new(x, y, angle, owner, data: Data.Projectiles) {
        ALL.push(this);
        
        this.owner = owner;
        
        super(0,0);

        setPosPixel(x,y);

        frictX = data.friction;
        frictY = data.friction;

        dx = Math.cos(angle)*tmod*data.speed;
        dy = Math.sin(angle)*tmod*data.speed;

        spr.setEmptyTexture(0xff0000,16,16);
        spr.setCenterRatio();
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function onTouchWallX() {
        destroy();
    }

    override function onTouchWallY() {
        destroy();
    }

    override function onTouch(e:Entity) {
        if (e.takeHit()) {
            
        }
        destroy();
    }

    override function hasCircCollWith(e:Entity):Bool {
        return e != owner;
    }

}