package en;

import hxd.Key;
import hxd.Res;

class Hero extends Entity {
    
    var moveX:Float;
    var moveY:Float;
    var maxSpeed :Float;
    var moveSpeed :Float;

    public function new(cx, cy) {
        super(cx, cy);
        Game.ME.camera.target = this;

        maxSpeed = Data.globals.get(playerMaxMoveSpeed).value;
        moveSpeed = Data.globals.get(playerMoveSpeed).value;
        spr.set("test_tile");
        spr.setCenterRatio(0.5, 1);
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

            if (Main.ME.mouse.leftClicked) {
                trace("shoot");
                new Projectile(footX, footY, angToMouse(), SimpleBullet);
            }

            dx = addClamped(dx, moveX * moveSpeed * tmod, maxSpeed);
            dy = addClamped(dy, moveY * moveSpeed * tmod, maxSpeed);

            if (!hasAffect(Invulnerable)) {
                if (checkForDamage()) {
                    setAffectS(Stun, 0.2);
                    setAffectS(Invulnerable, 0.8);
                }

                spr.alpha = 1;
            }
            else 
            {
                spr.alpha = 0.5 + Math.sin(ftime) * 0.25;
            }

        }
    }

    function checkForDamage() {
        for (m in Mob.ALL) {
            if (m.distCase(this) < 0.7) {
                var a = angTo(m);
                dx = -Math.cos(a)*0.3;
                dy = -Math.sin(a)*0.3;
                return true;
            }
        }

        return false;
    }

    function addClamped(value: Float, x: Float, max:Float) : Float {
        if (Math.abs(value) < max)
            return M.fclampSym(value + x, max);
        else 
            return value;
    }
}