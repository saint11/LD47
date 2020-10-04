package en;

class Collectible extends Entity {
    public function new(x,y) {
        super(x,y);

        spr.set("blood");
    }

    override function hasCircCollWith(e:Entity):Bool {
        return e.is(Collectible);
    }

    override function update() {
        super.update();

        if(distCase(game.hero) < Data.globals.get(bloodPickUpRange).value) {
            var a = angTo(game.hero);
            dx = Math.cos(a) * 0.3;
            dy = Math.sin(a) * 0.3;

           if (distPx(game.hero)<8) {
                Game.ME.addMoney(1);
                destroy();
            }
        }
    }
}