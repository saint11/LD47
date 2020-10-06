package ui;

import h2d.Text;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;

	var flow : h2d.Flow;
	var tFlow : h2d.Flow;
	var rName : Text;
	var visited : Text;

	var invalidated = true;

	var life : h2d.Flow;
	public var money : Text;

	var cAdd : h3d.Vector;
	
	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		tFlow = new h2d.Flow(root);
		tFlow.layout = Vertical;
		tFlow.verticalAlign = Left;
		tFlow.padding = 48;
		rName = new Text(Assets.fontLarge,tFlow);
		visited = new Text(Assets.fontMedium, tFlow);

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		//flow.debug=true;
		flow.verticalSpacing = 16;
		
		var mBox = new h2d.Flow(flow);
		mBox.padding = 10;
		mBox.paddingTop = 24;
		mBox.verticalAlign = Middle;
		
		var icon = Assets.ui.h_get("bloodBig", mBox);
		money = new Text(Assets.fontLarge, mBox);
		money.dropShadow  = {dx: 0, dy: 2, color:0x0, alpha:0.9};
		cAdd = new h3d.Vector();
		money.colorAdd = cAdd;
		setMoney(game.money);

		life = new h2d.Flow(flow);
		life.layout = Vertical;
	}

	public function sayRoomName(l:LevelSeed) {
		var name = Data.text.get(chamberName).text;
		if (l.data!=null)
			name = l.data.title;
		
		rName.text = name;
		if (l.loop==0)
			visited.text = StringTools.replace(Data.text.get(hudLoopCountNever).text, "{0}", name);
		else if (l.loop==1)
			visited.text = Data.text.get(hudLoopCountOnce).text;
		else 
			visited.text = StringTools.replace(Data.text.get(hudLoopCount).text, "{0}", Std.string(l.loop));

		rName.alpha=0;
		visited.alpha=0;

		game.tw.createS(rName.alpha, 1, 1);
		game.tw.createS(visited.alpha, 1, 2);

		game.delayer.addS(()->{
			game.tw.createS(rName.alpha, 0, 1);
			game.tw.createS(visited.alpha, 0, 1);
		}, 5);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
		flow.reflow();
		
		tFlow.reflow();
		tFlow.x = Std.int( Main.ME.w()/Const.UI_SCALE - tFlow.outerWidth);
        tFlow.y = Std.int( Main.ME.h()/Const.UI_SCALE - tFlow.outerHeight);
	}

	public inline function invalidate() invalidated = true;

	function render() {
		flow.reflow();
		life.removeChildren();
		for(i in 0...Game.ME.playerMaxLife)
			Assets.ui.h_get(i+1<=Game.ME.playerLife ? "lifeOn" : "lifeOff", life);
	}

	public function setMoney(v:Int) {
		money.text = Std.string(v);
		money.textColor = 0xFFB300;
	}
	
	public function blinkWhite() {
		cd.setS("moneyShake", 1);
		cAdd.r = 0.9;
		cAdd.g = 0.9;
		cAdd.b = 0.9;
	}

	public function blinkRed() {
		cd.setS("moneyShake", 1);
		cAdd.r = 1;
		cAdd.g = 0;
		cAdd.b = -.3;
	}

	override public function update() {
		super.update();
		if( cd.has("moneyShake") )
			money.y = 20 + Math.cos(ftime*0.7)*2 * cd.getRatio("moneyShake");
		cAdd.r*=0.8;
		cAdd.g*=0.8;
		cAdd.b*=0.8;
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}
