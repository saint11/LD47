package en;

class Fountain extends Interactive {
    var expired : Bool = false;

    public function new(x,y) {
        super(x,y);

        weight = 1000;
        radius = 1.5 * Const.GRID;
        spr.anim.registerStateAnim("fountain",0,0.2, ()->!expired);
        spr.anim.registerStateAnim("fountain_expired",0,0.2, ()->expired);
        spr.setCenterRatio();
    }

    override function activate(by:Hero) {
        super.activate(by);
        if (!expired) {
            expired = true;

            by.heal(1);
        }
    }



}