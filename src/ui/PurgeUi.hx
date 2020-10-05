package ui;

import h2d.Object;
import en.inter.Purge;
import dn.Rand;
import h2d.Interactive;
import h3d.scene.World;
import h2d.Text;
import hxd.Key;

class PurgeUi extends dn.Process {
    public static var ME : PurgeUi;
    
	var mask : h2d.Graphics;
    var masterBox : h2d.Flow;
    var outBox  : h2d.Flow;
    var money : h2d.Text;
    
    public var ca : dn.heaps.Controller.ControllerAccess;
    
	var curIdx = 0;
    var cursor : HSprite;

    var btns : Array<{ f:h2d.Flow, cb:Void->Void }> = [];
    
    public function new(owner:Purge) {
        super(Main.ME);
		ME = this;
        ca = Main.ME.controller.createAccess("purge", true);

        createRootInLayers(Main.ME.root, Const.DP_UI);

		mask = new h2d.Graphics(root);
        tw.createS(mask.alpha, 0>1, 0.3);

        outBox = new h2d.Flow(root);
        outBox.layout = Vertical;
        outBox.horizontalAlign = Middle;
        
		var icon = Assets.ui.h_get("bloodBig", outBox);
		money = new h2d.Text(Assets.fontLarge, outBox);
		money.textColor = 0xFF3333;
        outBox.getProperties(money).paddingBottom = 32;

		masterBox = new h2d.Flow(outBox);
		masterBox.layout = Vertical;
		masterBox.verticalAlign = Middle;
        masterBox.horizontalAlign = Middle;
        masterBox.backgroundTile = Assets.ui.getTile("window");
        masterBox.padding = 32;
        masterBox.borderHeight = masterBox.borderWidth = 32;
        
        
        var tBox = new h2d.Flow(masterBox);
        tBox.layout= Horizontal;
        tBox.padding = 12;

		var helpTxt = new Text(Assets.fontMedium, tBox);
		helpTxt.text = Data.text.get(purge).text;
        helpTxt.alpha=0.9;
        var drop = Assets.tiles.h_get("blood", tBox);
        drop.y = 6;
        var price = new Text(Assets.fontMedium, tBox);
        price.text = Data.globals.get(purgePrice).value + " ?";

        var bBox = new h2d.Flow(masterBox);
        bBox.layout= Horizontal;
        bBox.padding = 12;
        bBox.horizontalSpacing = 16;

        btns.push(addButton(bBox, "Yes", 0xFFFFFF, 0, ()-> {
            close();
            owner.expire();
        }));

        btns.push(addButton(bBox, "No", 0xFFAAAA, 1, ()-> {
            close();
        }));

        cursor = Assets.ui.h_get("cursor",0, 0.5,0.5, bBox);
        bBox.getProperties(cursor).isAbsolute = true;

        onResize();
    }

    function addButton(ob:Object, text:String, color:Int, index:Int, interact: Void->Void) {
        var f = new h2d.Flow(ob);
		//f.debug = true;
		f.verticalAlign = Middle;
		f.backgroundTile = Assets.ui.getTile("button");
        f.borderHeight = f.borderWidth = 16;
		f.padding = 16;
		f.maxWidth = f.minWidth = 190;
        f.enableInteractive = true;
        var tf = new h2d.Text(Assets.fontMedium, f);
		tf.text = text;
        tf.maxWidth = 180;
        tf.textColor = color;

        f.interactive.onOver = (e)-> curIdx = index;
        f.interactive.onClick = (e)-> interact();
        
        return {f:f, cb: interact};
    }

    override function onResize() {
        super.onResize();
        
		mask.clear();
		mask.beginFill(0x21111F,0.75);
		mask.drawRect(0,0,Main.ME.w(),Main.ME.h());
        
		outBox.reflow();
		outBox.x = Std.int( Main.ME.w()*0.5 - outBox.outerWidth*0.5);
        outBox.y = Std.int( Main.ME.h()*0.5 - outBox.outerHeight*0.5);
    }

    override function update() {
        super.update();

        money.text = Std.string(Game.ME.money);
        
		for(i in btns)
			i.f.alpha = 0.7;
		var i = btns[curIdx];
        
        var g = Game.ME;
        
        var i = btns[curIdx];

		cursor.visible = i!=null;
		if( i!=null ) {
			i.f.alpha = 1;
            cursor.x = 5 - M.fabs(Math.sin(ftime*0.2)*5) + i.f.x;
            cursor.y = i.f.y + i.f.outerHeight*0.5;
            
            if( ca.rightPressed() && curIdx<btns.length-1)
                curIdx++;

            if( ca.leftPressed() && curIdx>0 )
                curIdx--;

            if( !cd.has("lock") && ca.aPressed() ){
                btns[curIdx].cb();
            }
        }
            
		
		if( ca.bPressed() || Key.isPressed(Key.ESCAPE) )
			close();
    }

	var closed:Bool;
	function close() {
		if (!closed)
		{
			closed = true;
			cd.setS("closing", 99999);
			tw.createS(root.alpha, 0, 0.4);
			tw.createS(masterBox.y, -masterBox.outerHeight,0.4).end( function() {
				destroy();
			});
		}
    }
    
    override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
		ca.dispose();
		Game.ME.resume();
	}
}