package ui;

import h2d.Interactive;
import h3d.scene.World;
import h2d.Text;
import hxd.Key;

class ShopWindow extends dn.Process {
	public static var ME : ShopWindow;

	var mask : h2d.Graphics;
	var masterFlow : h2d.Flow;
	var iFlow : h2d.Flow;
	var wFlow : h2d.Flow;
    var descFlow : h2d.Flow;
    
    var money : h2d.Text;
    var description : h2d.Text;
    
    public var ca : dn.heaps.Controller.ControllerAccess;
    
	var curIdx = 0;
	var cursor : HSprite;

	var items : Array<{ f:h2d.Flow, p:Int, desc:String, cb:Void->Void } >;

    public function new() {
        super(Main.ME);
		ME = this;
        ca = Main.ME.controller.createAccess("shop", true);
        
        createRootInLayers(Main.ME.root, Const.DP_UI);
        
		mask = new h2d.Graphics(root);
        tw.createS(mask.alpha, 0>1, 0.3);
        
        masterFlow = new h2d.Flow(root);
        masterFlow.padding = 32;
        //masterFlow.backgroundTile = Assets.ui.getTile("window");
        masterFlow.layout = Horizontal;
        masterFlow.verticalAlign = Middle;
        masterFlow.borderHeight = masterFlow.borderWidth = 32;
        masterFlow.horizontalSpacing = 8;

		wFlow = new h2d.Flow(masterFlow);
		wFlow.padding = 32;
		wFlow.layout = Vertical;
		wFlow.horizontalAlign = Middle;
		wFlow.backgroundTile = Assets.ui.getTile("window");
        wFlow.borderHeight = wFlow.borderWidth = 32;
        
        descFlow = new h2d.Flow(masterFlow);
		descFlow.padding = 32;
		descFlow.layout = Vertical;
		descFlow.horizontalAlign = Middle;
        descFlow.backgroundTile = Assets.ui.getTile("window");
        descFlow.minWidth = descFlow.maxWidth = 350;
        
        descFlow.borderHeight = descFlow.borderWidth = 32;

        description = new Text(Assets.fontMedium, descFlow);
        description.maxWidth = 350;

		money = new h2d.Text(Assets.fontMedium, wFlow);
		money.textColor = 0xFF9900;
        wFlow.getProperties(money).paddingBottom = 32;
        
		iFlow = new h2d.Flow(wFlow);
		iFlow.layout = Vertical;
		iFlow.verticalSpacing = 1;

        wFlow.addSpacing(8);
		var tf = new h2d.Text(Assets.fontMedium, wFlow);
		if( Game.ME.ca.isGamePad() )
            tf.text = "[A-Button] to buy, [B-Button] to cancel";
		else
            tf.text = "SPACE to buy, ESCAPE to cancel";
        
        tf.textColor = 0x805337;
        
        cd.setS("lock", 0.2);
        refresh();
        onResize();
        Game.ME.pause();
    }

    function refresh() {
        items = [];
        iFlow.removeChildren();
        
        var i = 0;
        for(item in Data.shop.all) {
            // {
            //     addLocked(i.id, "Item locked (need "+i.cond.name+")");
            //     continue;
            // }
            addItem(item, i++);
        }

        cursor = Assets.ui.h_get("cursor",0, 0.5,0.5, iFlow);
    }

    
	function addItem(inf:Data.Shop, index:Int) {
		
		var f = new h2d.Flow(iFlow);
		//f.debug = true;
		f.verticalAlign = Middle;
		f.backgroundTile = Assets.ui.getTile("button");
        f.borderHeight = f.borderWidth = 16;
		f.padding = 4;
		f.maxWidth = f.minWidth = 290;

		var icon = new h2d.Bitmap(dn.CdbHelper.getH2dTile(Assets.shopIcons, inf.icon), f);
		
        var cost = inf.price;
        var money = Game.ME.money;

        var tf = new h2d.Text(Assets.fontSmall, f);
		tf.text = inf.title;
        tf.maxWidth = 190;
        tf.textColor = cost<= money ? 0xFFFFFF : 0xE77272;
        
        f.addSpacing(8);
        

		if( cost>0 ) {
			var tf = new h2d.Text(Assets.fontSmall, f);
			tf.text = "$"+cost;
			tf.textColor = cost <= money ? 0xFF9900 : 0xD20000;
		}
		else {
			var tf = new h2d.Text(Assets.fontSmall, f);
			tf.text = "FREE";
			tf.textColor = 0x8CD12E;
        }
        
        var interact = () -> {
            Game.ME.levelLoop.push(Game.ME.world.resolveLevel(inf.levelName.toString()));
            Game.ME.level.scroll.destroy();
            Game.ME.addMoney(-cost);
            close();
        }
        var interactive = new Interactive(f.outerWidth, f.outerHeight, f);
        interactive.onOver = (e)-> curIdx = index;
        interactive.onClick = (e)-> interact();
        
		items.push( {
			f:f,
			p:cost,
			desc:inf.desc,
			cb:interact,
		});
	}
    
	function close() {
		cd.setS("closing", 99999);
		tw.createS(root.alpha, 0, 0.1);
		tw.createS(wFlow.y, -wFlow.outerHeight,0.1).end( function() {
			destroy();
		});
    }
    
    override function update() {
        super.update();

        money.text = "You have $"+Game.ME.money;
        
        
        var g = Game.ME;
		for(i in items)
			i.f.alpha = 0.7;
		var i = items[curIdx];
        description.text = i.desc;

		cursor.visible = i!=null;
		if( i!=null ) {
			i.f.alpha = 1;
			cursor.x = 5 - M.fabs(Math.sin(ftime*0.2)*5);
			cursor.y += ( i.f.y + i.f.outerHeight*0.5 - cursor.y ) * 0.3;

			if( ca.downPressed() && curIdx<items.length-1 )
				curIdx++;

			if( ca.upPressed() && curIdx>0 )
				curIdx--;

			if( !cd.has("lock") && ca.aPressed() ) {
				if( Game.ME.money>=i.p ) {
                    i.cb();
				}
			}
		}

		if( ca.bPressed() || Key.isPressed(Key.ESCAPE) )
			close();
    }

    override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
		ca.dispose();
		Game.ME.resume();
	}

    override function onResize() {
        super.onResize();
        
		mask.clear();
		mask.beginFill(0x21111F,0.75);
        mask.drawRect(0,0,Main.ME.w(),Main.ME.h());
        
		masterFlow.reflow();
		masterFlow.x = Std.int( Main.ME.w()*0.5 - masterFlow.outerWidth*0.5);
        masterFlow.y = Std.int( Main.ME.h()*0.5 - masterFlow.outerHeight*0.5);
        descFlow.minHeight = descFlow.maxHeight = wFlow.outerHeight;
    }
}