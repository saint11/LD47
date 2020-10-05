package en;

class Collectible extends Entity {
    public function new(x,y) {
        super(x,y);
        enableShadow(0.3);
        radius = 0.2;
        spr.set("blood");
        jump(rnd(2,4));
        bounceFrict = 0.6;

        cd.setS("cooldown",0.6);
    }

    override function hasCircCollWith(e:Entity):Bool {
        return e.is(Collectible);
    }

    override function update() {
        super.update();

        if (!cd.has("cooldown"))
        if((distCase(game.hero) < Data.globals.get(bloodPickUpRange).value )|| level.isComplete()) {
            var a = angTo(game.hero);
            dx = Math.cos(a) * 0.3;
            dy = Math.sin(a) * 0.3;

           if (distPx(game.hero)<8 ) {
                Game.ME.addMoney(1, true);
                destroy();
            }
        }
    }
}