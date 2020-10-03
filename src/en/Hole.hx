package en;

class Hole extends Entity {
    public function new(x,y) {
        super(x,y);

        spr.setEmptyTexture(0x000000,48,48);
    }
}