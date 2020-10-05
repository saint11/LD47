package en;

import ui.EndWindow;
import Data.Damage;
import hxd.Key;
import hxd.Res;

class Hero extends Entity {
    
    var moveX:Float;
    var moveY:Float;
    var maxSpeed :Float;
    var moveSpeedX :Float;
    var moveSpeedY :Float;

    public function new(cx, cy) {
        super(cx, cy);
        Game.ME.camera.trackTarget(this, true);
        
        maxSpeed = Data.globals.get(playerMaxMoveSpeed).value;
        moveSpeedX = Data.globals.get(playerMoveSpeedX).value;
        moveSpeedY = Data.globals.get(playerMoveSpeedY).value;

        spr.set(Assets.hero);
        spr.anim.registerStateAnim("hero_idle_d", 0, Data.animations.get(hero_idle).speed);
        spr.anim.registerStateAnim("hero_walk_u", 1, Data.animations.get(hero_walk).speed, ()-> moveY < 0);
        spr.anim.registerStateAnim("hero_walk_d", 1, Data.animations.get(hero_walk).speed, ()-> moveY > 0);
        spr.anim.registerStateAnim("hero_walk_r", 2, Data.animations.get(hero_walk).speed  * 0.8, ()-> moveX != 0);

        spr.setCenterRatio(0.5, 1);
        
        initLife(Game.ME.playerMaxLife);
        life = Game.ME.playerLife;
		
        enableShadow();
    }

    override function update() {
        super.update();

        if (cd.getRatio("doorEnter")>0) {
            var d = cd.getRatio("doorEnter");
            shadow.alpha = d;
            spr.alpha = d;
            sprScaleX = sprScaleY = 0.8 + d * 0.2;
        } else if (!hasAffect(Stun)) {
            var ca = Game.ME.ca;

            moveX = moveY = 0;

            if (ca.leftDown()) {
                dir = -1;
                moveX -= 1;
            }
            if (ca.rightDown()) {
                dir = 1;
                moveX += 1;
            }
            if (ca.upDown())
                moveY -= 1;
            if (ca.downDown())
                moveY += 1;


            if (ca.yDown() && cd.getS("player_shoot")==0) {
                var helper = cy<2? 8: cy>level.hei-2? -4: 0;
                shoot(footX,footY, 0, helper);
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

    function shoot(x:Float,y:Float, offX:Float, offY:Float) {
        var weapon = Game.ME.weapon;

        for (i in 0...weapon.bullets){
            new Projectile(x + offX,y + offY, angToMouse(offX,offY) + rnd(-weapon.spread, weapon.spread) * M.DEG_RAD, this, weapon.projectile);
        }

        cd.setS("player_shoot", weapon.interval);
        setAffectS(Stun, weapon.stun);
        cancelVelocities();
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
        cd.onComplete("doorEnter", ()-> {
            entityVisible = false;
            game.loadNextLevel();
        });
        dy = 0;
        dx = door.dir *0.2;
    }

    override  function heal(v) {
        super.heal(v);
        Game.ME.playerLife=life;
        hud.invalidate();
    }

    override function hit(dmg:Damage, from:Null<Entity>, reduction: Float = 1) {
        super.hit(dmg, from, reduction);
        
        Game.ME.playerLife=life;
        hud.invalidate();
        
        setAffectS(Invulnerable, 1);
        setAffectS(Stun, dmg.stunTime);

        Game.ME.addSlowMo("hit", 0.5, 0.1);
        Game.ME.stopFrame();
        Game.ME.camera.shakeS(0.1,1);
    }

    public function stop() {
        moveX = moveY = 0;
        cancelVelocities();
    }

    override function onDie() {
        super.onDie();

        new EndWindow(Data.text.get(game_over).text);
    }

    override function dispose() {
        super.dispose();
        Game.ME.playerLife=life;
    }
}