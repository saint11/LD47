package en.inter;

import dn.heaps.Sfx;

class Fountain extends Interactive {
    var expired : Bool = false;

    var sfxLoop:Sfx;
    public function new(x,y) {
        super(x,y);

        weight = 1000;
        radius = 1.5 * Const.GRID;
        spr.anim.registerStateAnim("fountain",0,Data.animations.get(fountain).speed, ()->!expired);
        spr.anim.registerStateAnim("fountain_expired",0,Data.animations.get(fountain).speed, ()->expired);
        spr.setCenterRatio();

        sfxLoop = Assets.SBANK.fountain();
        sfxLoop.play(true);
    }

    override  function dispose() {
        super.dispose();
        sfxLoop.stop();
    }
    override function activate(by:Hero) {
        super.activate(by);
        if (!expired) {
            expired = true;
            Assets.SBANK.drink(1);

            sfxLoop.stop();
            by.heal(1);

            sprSquashX = 1.3;
            sprSquashY = 0.8;

            fx.flashBangS(0xFF99AA, 0.55, 1);
        }
    }



}