package tools;

import hxsl.Types.Vec;
import dn.Rand;

class LevelSeed {
    public var seed:Int;
    var rand:Rand;

    var level : World.World_Level;
    public var data : Data.Shop;

    public var loop:Int;

    public var splatters:Array<{x:Float, y:Float, str:String}> = [];

    public function new(level:World.World_Level, data:Data.Shop) {
        this.level = level;
        this.data = data;
        loop = -1;
        seed = M.rand();
    }

    public function getLevel():World.World_Level {
        loop++;
        return level;
    }

    public function resetSeed() {
        rand = new Rand(seed);
    }

    public function irange(max) {
        return rand.irange(0,max-1);
    }

    public function range(max) {
        return rand.range(0,max);
    }

    public function rcolor(base, variation) {
        return new Vec(base + rand.range(0, variation), base + rand.range(0, variation), base+ rand.range(0, variation));
    }

    public function getDir() {
        return rand.irange(1,1,true);
    }
}