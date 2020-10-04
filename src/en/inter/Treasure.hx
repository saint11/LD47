package en.inter;

import dn.Delayer;

class Treasure extends Interactive {
    var expired : Bool = false;

    public function new(x,y) {
        super(x,y);

        weight = 1000;
        radius = 1.5 * Const.GRID;
        spr.anim.registerStateAnim("fountain",0,0.2, ()->!expired);
        spr.anim.registerStateAnim("fountain_expired",0,0.2, ()->expired);
        spr.setCenterRatio();
    }

    override function activate(by:Hero) {
        super.activate(by);
        if (!expired) {
            expired = true;

            
        var d = new Delayer(30);
        var droppedBlood = M.ceil(M.randRange(Data.globals.get(fountainMoneyMin).value, Data.globals.get(fountainMoneyMax).value) * Game.ME.bonusMoney);
        for (i in 0...droppedBlood) {
            
            var c = new Collectible(cx,cy);
            c.dx = rnd(-0.5, 0.5);
            c.dy = rnd(-0.5, 0.5);
        }

        }
    }

}