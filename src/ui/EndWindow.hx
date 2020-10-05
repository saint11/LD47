package ui;

import h2d.Text;


class EndWindow extends dn.Process {
    public static var ME:EndWindow;

    var mask : h2d.Graphics;
    var masterFlow : h2d.Flow;
    
    public var ca : dn.heaps.Controller.ControllerAccess;
    var action:Void->Void;
    public function new(text:String, action:Void->Void, timer:Float = -1) {
        super(Main.ME);
        ME = this;

        ca = Main.ME.controller.createAccess("win", true);
        
        createRootInLayers(Main.ME.root, Const.DP_UI);

		mask = new h2d.Graphics(root);
        tw.createS(mask.alpha, 0>1, 0.9);

        masterFlow = new h2d.Flow(root);
        masterFlow.padding = 32;
        //masterFlow.backgroundTile = Assets.ui.getTile("window");
        masterFlow.layout = Horizontal;
        masterFlow.verticalAlign = Middle;
        masterFlow.borderHeight = masterFlow.borderWidth = 32;
        masterFlow.horizontalSpacing = 8;

        
        var t = new Text(Assets.fontMedium, masterFlow);
        t.text = text;

        cd.setS("lock",1.5);

        Game.ME.pause();
        onResize();

        this.action = action;

        if (timer>0){
            cd.setS("timer", timer);
            cd.onComplete("timer", ()->{
                action();
                close();
            });
        }
    }

    override function update() {
        if (!cd.has("lock")){
            if (ca.aDown()) {
                action();
                close();
            }
        }
    }
    
	var closed:Bool;
    function close() {
		if (!closed)
		{
			closed = true;
			cd.setS("closing", 99999);
			tw.createS(root.alpha, 0, 0.4);
			tw.createS(masterFlow.y, -masterFlow.outerHeight,0.4).end( function() {
				destroy();
			});
		}
    }
    
    override function onResize() {
        super.onResize();
        
		mask.clear();
		mask.beginFill(0x21111F, 1);
        mask.drawRect(0,0,Main.ME.w(),Main.ME.h());
        
		masterFlow.reflow();
		masterFlow.x = Std.int( Main.ME.w()*0.5 - masterFlow.outerWidth*0.5);
        masterFlow.y = Std.int( Main.ME.h()*0.5 - masterFlow.outerHeight*0.5);
    }
    
    public function addVictoryImage() {
        
    }

    override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
		ca.dispose();
		Game.ME.resume();
	}
}