package tools;

import h2d.Scene;
import h2d.Interactive;

class Mouse {
    public var x: Float;
    public var y: Float;

    public var leftDown:Bool;
    public var leftClicked:Bool;

    var scene:Scene;

    public function new(scene : Scene) {
        var interactive = new Interactive(scene.width, scene.height, scene);
        this.scene = scene;
        
        interactive.onPush = (e) -> {
            leftDown=true;
            leftClicked = true;
            //trace("X: " + x + ", Y: " +  y);
        }
        
        interactive.onRelease = (e) -> {
            //trace("Up!");
            leftDown=false;
        }
        
        interactive.onReleaseOutside = (e) -> {
            leftDown=false;
        }
    }

    public function update() {
        leftClicked = false;
        if (Game.ME == null) {

            x = scene.mouseX;
            y = scene.mouseY;
        }
        else 
            {
                x = scene.mouseX - Game.ME.scroller.x;
                y = scene.mouseY - Game.ME.scroller.y;
            }
    }
}