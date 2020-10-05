package en.inter;

class WeaponPedestal extends Interactive {
    
    var expired : Bool = false;
    var icon : HSprite;
    var weapon : Data.Weapons;

    public function new(x,y, data: World.Entity_WeaponStand) {
        super(x,y);

        weight = 1000;
        radius = 1.5 * Const.GRID;
        spr.anim.registerStateAnim("pedestal",0,0.2, ()->!expired);
        spr.anim.registerStateAnim("pedestal_expired",0,0.2, ()->expired);
        spr.setCenterRatio();

        var possibleWeapons:Array<Data.WeaponsKind> = [MagicMissile, DevilGun, Shotgun];

        if (level.seed.loop>2)
            possibleWeapons  = [GrenadeLauncher, Sniper, Chaingun];

        var i = possibleWeapons.length;
        while(--i >= 0) {
            if (Data.weapons.get(possibleWeapons[i]) == Game.ME.weapon)
                possibleWeapons.remove(possibleWeapons[i]);
        }
        weapon = Data.weapons.get(possibleWeapons[M.rand(possibleWeapons.length)]);

        icon = Assets.ui.h_get("icon_" + weapon.icon, spr);
        icon.setCenterRatio();
    }

    override function activate(by:Hero) {
        super.activate(by);
        if (!expired) {
            expired = true;
            Assets.SBANK.weapon(0.6);
            Game.ME.weapon = weapon;
            sprSquashX = 1.3;
            sprSquashY = 0.8;

            fx.flashBangS(0xFF99AA, 0.55, 1);

            game.camera.bump(0,20);

            game.tw.createS(icon.scaleX,1.2>0, 0.3);
            game.tw.createS(icon.scaleY,1.1>0, 0.3);
        }
    }

    override function update() {
        super.update();

        icon.y = -80 + Math.sin(ftime*0.05) * 24;
    }
}