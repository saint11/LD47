package en;

class Hero extends Entity {
    public function new(x,y) {
        super(x,y);
        trace("Hero created at " + footX + ", " + footY);

        Game.ME.camera.target = this;
    }
}