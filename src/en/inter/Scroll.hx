package en.inter;

import Data.Damage;

class Scroll extends Interactive {

    public function new(x,y) {
        super(x,y);
        
        imovable = true;
        tall = true;
        
        spr.set("scroll");
        enableShadow(2);
    }

    override function update() {
        super.update();

        altitude = 10 + Math.sin(ftime * 0.05) * 5;
    }

    override function hit(dmg:Damage, from:Null<Entity>) {
        
    }

    override function dispose() {
        super.dispose();
        level.scroll=null;
    }

    override function onActivate(by:Hero) {
        super.onActivate(by);
        new ui.ShopWindow();
    }
}