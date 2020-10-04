package en.inter;

import dn.Delayer;

class Treasure extends Interactive {
    var expired : Bool = false;
    var d : Delayer;
    public function new(x,y) {
        super(x,y);

        weight = 1000;
        radius = 1.2 * Const.GRID;
        spr.anim.registerStateAnim("treasure_on",0,0.2, ()->!expired);
        spr.anim.registerStateAnim("treasure_off",0,0.2, ()->expired);
        spr.setCenterRatio(0.5,0.5);
        
        d = new Delayer(30);
    }

    override function activate(by:Hero) {
        super.activate(by);
        if (!expired) {
            expired = true;

            
        var droppedBlood = M.ceil(M.randRange(Data.globals.get(fountainMoneyMin).value, Data.globals.get(fountainMoneyMax).value) * Game.ME.bonusMoney);
        for (i in 0...droppedBlood) {
            
            d.addMs(()->{
                var c = new Collectible(cx,cy);
                c.dx = rnd(-0.5, 0.5);
                c.dy = rnd(-0.5, 0.5);
            }, i*50);
        }
        
        }
    }

    override function update() {
        super.update();
        d.update(tmod);
    }
}