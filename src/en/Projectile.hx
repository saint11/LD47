package en;

class Projectile extends Entity {
    
    public var ALL:Array<Projectile> = [];

    public function new(x, y, angle, kind: Data.ProjectilesKind) {
        ALL.push(this);
        
        super(0,0);

        setPosPixel(x,y);

        var data = Data.projectiles.get(kind);

        frictX = data.friction;
        frictY = data.friction;

        dx = Math.cos(angle)*tmod*data.speed;
        dy = Math.sin(angle)*tmod*data.speed;

        spr.setEmptyTexture(0xff0000,8,8);
        
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
}