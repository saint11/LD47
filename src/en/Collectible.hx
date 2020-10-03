package en;

class Collectible extends Entity {
    public function new(x,y) {
        super(x,y);

        spr.set("blood");
        hasColl=false;
    }

    override function update() {
        super.update();

        if(distCase(level.hero) < Data.globals.get(bloodPickUpRange).value) {
            var a = angTo(level.hero);
            dx = Math.cos(a);
            dy = -Math.sin(a);

            if (distPx(level.hero)<5) {
                destroy();
            }
        }
    }
}