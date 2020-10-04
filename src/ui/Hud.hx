package ui;

import h2d.Text;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;

	var flow : h2d.Flow;
	var invalidated = true;

	var life : h2d.Flow;
	public var money : Text;

	var cAdd : h3d.Vector;
	
	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		
		var mBox = new h2d.Flow(flow);
		mBox.padding = 10;
		mBox.paddingTop = 24;
		money = new Text(Assets.fontLarge, mBox);
		money.dropShadow  = {dx: 2, dy: 2, color:0x0, alpha:0.9};
		cAdd = new h3d.Vector();
		money.colorAdd = cAdd;
		setMoney(game.money);

		life = new h2d.Flow(flow);
		life.layout = Vertical;
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}

	public inline function invalidate() invalidated = true;

	function render() {
		var hero = Game.ME.hero;
		life.removeChildren();
		for(i in 0...hero.maxLife)
			Assets.ui.h_get(i+1<=hero.life ? "lifeOn" : "lifeOff", life);
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
			money.y = Math.cos(ftime*0.7)*2 * cd.getRatio("moneyShake");
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
