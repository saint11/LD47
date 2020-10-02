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
        spr.setEmptyTexture(0x80FF00,16,16);
    }

    override function update() {
        super.update();

        var ca = Game.ME.ca;

        moveX = moveY = 0;

        if (ca.isKeyboardDown(Key.RIGHT))
            moveX += 1;
        if (ca.isKeyboardDown(Key.LEFT))
            moveX -= 1;
        if (ca.isKeyboardDown(Key.UP))
            moveY -= 1;
        if (ca.isKeyboardDown(Key.DOWN))
            moveY += 1;

        dx = addClamped(dx, moveX * moveSpeed * tmod, maxSpeed);
        dy = addClamped(dy, moveY * moveSpeed * tmod, maxSpeed);
    }

    function addClamped(value: Float, x: Float, max:Float) : Float {
        if (Math.abs(value) < max)
            return M.fclampSym(value + x, max);
        else 
            return value;
    }
}