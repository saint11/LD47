package en.inter;

import dn.Delayer;

class Treasure extends Interactive {
    var expired : Bool = false;
    var d : Delayer;

    var spawned:Bool = false;

    public function new(x,y, data:World.Entity_Chest) {
        super(x,y);
        if (!data.f_Permanent)
        {
            hasColl=false;
            entityVisible = false;
        }
        else
        {
            spawned=true;
        }
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
            Assets.SBANK.open_treasure(0.7);

            var droppedBlood = M.ceil(M.randRange(Data.globals.get(fountainMoneyMin).value, Data.globals.get(fountainMoneyMax).value) * Game.ME.bonusMoney);
            for (i in 0...droppedBlood) {
                
                d.addMs(()->{
                    var c = new Collectible(cx,cy);
                    c.dx = rnd(-0.5, 0.5);
                    c.dy = rnd(-0.5, 0.5);
                }, i*30);
            }
            
            setSquashX(1.1);
            setSquashY(0.95);
        }
    }

    override function update() {
        super.update();
        d.update(tmod);

        if (!spawned && level.isComplete()) {
            spawned=true;
            if (rnd(0,1)<Game.ME.bonusTreasure) {
                Assets.SBANK.treasure(0.7);
                hasColl=true;
                entityVisible = true;
                
                setSquashX(0.5);
                setSquashY(0.2);
            }
        }
    }
}