package en;

import Data.Damage;
import hxd.Key;
import hxd.Res;

class Hero extends Entity {
    
    var moveX:Float;
    var moveY:Float;
    var maxSpeed :Float;
    var moveSpeedX :Float;
    var moveSpeedY :Float;

    var weapon:Data.Weapons;

    public function new(cx, cy) {
        super(cx, cy);
        Game.ME.camera.trackTarget(this, true);
        
        maxSpeed = Data.globals.get(playerMaxMoveSpeed).value;
        moveSpeedX = Data.globals.get(playerMoveSpeedX).value;
        moveSpeedY = Data.globals.get(playerMoveSpeedY).value;

        spr.set(Assets.hero);
        spr.anim.registerStateAnim("hero_idle_d", 0, Data.animations.get(hero_idle).speed);
        spr.anim.registerStateAnim("hero_walk_d", 1, Data.animations.get(hero_walk).speed, ()-> moveX != 0 || moveY != 0);
        spr.setCenterRatio(0.5, 1);
        
        weapon = Data.weapons.get(MagicMissile);
        
        initLife(Data.globals.get(playerHp).value);

        enableShadow();
    }

    override function update() {
        super.update();

        if (cd.getRatio("doorEnter")>0) {
            var d = cd.getRatio("doorEnter");
            spr.alpha = d;
            sprScaleX = sprScaleY = 0.8 + d * 0.2;
        } else if (!hasAffect(Stun)) {
            var ca = Game.ME.ca;

            moveX = moveY = 0;

            if (ca.leftDown())
                moveX -= 1;
            if (ca.rightDown())
                moveX += 1;
            if (ca.upDown())
                moveY -= 1;
            if (ca.downDown())
                moveY += 1;

            if (ca.yDown() && cd.getS("player_shoot")==0) {
                new Projectile(centerX, centerY, angToMouse(), this, weapon.projectile);
                cd.setS("player_shoot", weapon.interval);
            }

            dx = addClamped(dx, moveX * moveSpeedX * tmod, maxSpeed);
            dy = addClamped(dy, moveY * moveSpeedY * tmod, maxSpeed);
            
            if (!hasAffect(Invulnerable)) {
                spr.alpha = 1;
            }
            else 
            {
                spr.alpha = 0.5 + Math.sin(ftime) * 0.25;
            }
        }

        
    }

    function addClamped(value: Float, x: Float, max:Float) : Float {
        if (Math.abs(value) < max)
            return M.fclampSym(value + x, max);
        else 
            return value;
    }

    public function enterDoor(door:Door) {
        hasColl=false;
        cd.setS("doorEnter",.5);
        cd.onComplete("doorEnter", ()-> { game.loadNextLevel(); });
        dy = 0;
        dx = door.dir *0.2;
    }

    override function hit(dmg:Damage, from:Null<Entity>) {
        super.hit(dmg, from);
        
        setAffectS(Invulnerable, 1);
        setAffectS(Stun, dmg.stunTime);

        hud.invalidate();
    }

    public function stop() {
        moveX = moveY = 0;
        cancelVelocities();
    }
}