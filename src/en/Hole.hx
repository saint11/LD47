package en;

class Hole extends Entity {
    public function new(x,y) {
        super(x,y);

        spr.set("test_hole");

        zPrio = -10000;
        imovable = true;
    }
}