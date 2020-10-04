package en.inter;

import Data.Damage;

class Scroll extends Interactive {

    public function new(x,y) {
        super(x,y);
        setPosPixel((x + 0.5)*Const.GRID, y*Const.GRID);
        
        imovable = true;
        tall = true;
        
        spr.anim.registerStateAnim("ghost_idle",0,0.1);
        enableShadow(2);
    }

    override function update() {
        super.update();

        altitude = 10 + Math.sin(ftime * 0.05) * 5;

        spr.alpha = 0.5 + Math.sin(ftime * 0.02) * 0.2;
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