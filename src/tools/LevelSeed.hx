package tools;

import hxsl.Types.Vec;
import dn.Rand;

class LevelSeed {
    public var seed:Int;
    public var rand:Rand;

    var level : World.World_Level;

    public function new(level:World.World_Level) {
        this.level = level;
        seed = M.rand();
    }

    public function getLevel():World.World_Level {
        return level;
    }

    public function resetSeed() {
        rand = new Rand(seed);
    }

    public function irange(max) {
        return rand.irange(0,max-1);
    }

    public function rcolor(base, variation) {
        return new Vec(base + rand.range(0, variation), base + rand.range(0, variation), base+ rand.range(0, variation));
    }
}