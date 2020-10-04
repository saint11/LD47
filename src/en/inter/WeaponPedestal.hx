package en.inter;

class WeaponPedestal extends Interactive {
    var expired : Bool = false;

    var weapon : Data.Weapons;
    public function new(x,y) {
        super(x,y);

        weight = 1000;
        radius = 1.5 * Const.GRID;
        spr.anim.registerStateAnim("fountain",0,0.2, ()->!expired);
        spr.anim.registerStateAnim("fountain_expired",0,0.2, ()->expired);
        spr.setCenterRatio();

        var possibleWeapons:Array<Data.WeaponsKind> = [MagicMissile, DevilGun, Shotgun];
        weapon = Data.weapons.get(possibleWeapons[M.rand(possibleWeapons.length)]);
    }

    override function activate(by:Hero) {
        super.activate(by);
        if (!expired) {
            expired = true;

            
        }
    }
}