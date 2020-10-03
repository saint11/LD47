package en;

import hxd.Key;
import hxd.Res;

class Hero extends Entity {
    
    var moveX:Float;
    var moveY:Float;
    var maxSpeed :Float;
    var moveSpeed :Float;

    var weapon:Data.Weapons;

    public function new(cx, cy) {
        super(cx, cy);
        Game.ME.camera.target = this;

        maxSpeed = Data.globals.get(playerMaxMoveSpeed).value;
        moveSpeed = Data.globals.get(playerMoveSpeed).value;
        spr.anim.registerStateAnim("hero_idle_d", 1, Data.animations.get(hero_idle_d).speed);
        spr.setCenterRatio(0.5, 1);
        
        weapon = Data.weapons.get(MagicMissile);
    }

    override function update() {
        super.update();

        if (!hasAffect(Stun)) {
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

            if (Main.ME.mouse.leftDown && cd.getS("player_shoot")==0) {
                new Projectile(centerX, centerY, angToMouse(), this, weapon.projectile);
                cd.setS("player_shoot", weapon.interval);
            }

            dx = addClamped(dx, moveX * moveSpeed * tmod, maxSpeed);
            dy = addClamped(dy, moveY * moveSpeed * tmod, maxSpeed);
            
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

    override function onTouch(other:Entity) {
        super.onTouch(other);

        if (other.is(Mob)) {
            var a = angTo(other);
            dx = -Math.cos(a)*0.3;
            dy = -Math.sin(a)*0.3;

            setAffectS(Stun, 0.4);
            setAffectS(Invulnerable, 1);
        }
    }
}