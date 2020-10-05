import hxsl.Types.Vec;
import h2d.Bitmap;
import h2d.Graphics;
import en.Hero;
import ui.EndWindow;
import h2d.col.Point;
import h2d.Interactive;
import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	/** Game controller (pad or keyboard) **/
	public var ca : dn.heaps.Controller.ControllerAccess;

	/** Particles **/
	public var fx : Fx;

	/** Basic viewport control **/
	public var camera : Camera;

	/** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
	public var scroller : h2d.Layers;

	/** Level data **/
	public var level : Level;

	/** UI **/
	public var hud : ui.Hud;

	/** Slow mo internal values**/
	var curGameSpeed = 1.0;
	var slowMos : Map<String, { id:String, t:Float, f:Float }> = new Map();

	/** LEd world data **/
	public var world : World;

	var levelToLoad : LevelSeed;
	public var levelLoop:Array<LevelSeed>; // TODO: Make sure rooms have a seed
	public var levelIndex:Int = 0;

	var mask : h2d.Bitmap;

	public var money:Int = 0;

	// Bonuses
	public var bonusMoney:Float = 0;
	public var bonusTreasure:Float = 0;

	// Player stuff
	public var hero:Hero;
	public var playerLife: Int;
	public var playerMaxLife: Int;
    public var weapon:Data.Weapons;

	public var loopCount = 0;
	
	public var moneySfx = [Assets.SBANK.drop1(),  Assets.SBANK.drop1()];
	public function new() {
		super(Main.ME);
		ME = this;
		
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		playerLife = playerMaxLife = Data.globals.get(playerHp).value;

		world = new World();
		camera = new Camera();
		fx = new Fx();
		hud = new ui.Hud();
		levelLoop = [new LevelSeed(world.all_levels.ScrollChamber, null)];
		
		mask = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF));
		mask.color = new Vec(0,0,0);

		root.add(mask, Const.DP_UI);

		addMoney(Data.globals.get(startingMoney).value);
		
		var possibleWeapons:Array<Data.WeaponsKind> = [MagicMissile, DevilGun, Shotgun];
		#if debug
		//var possibleWeapons:Array<Data.WeaponsKind> = [Sniper];
		money=10000;
		#end
        weapon = Data.weapons.get(possibleWeapons[M.rand(possibleWeapons.length)]);

		startLevel(levelLoop[0]);

		Process.resizeAll();
	}

	/**
		Called when the CastleDB changes on the disk, if hot-reloading is enabled in Boot.hx
	**/
	public function onCdbReload() {
	}

	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);

		mask.scaleX = w();
		mask.scaleY = h();
	}


	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	override function onDispose() {
		super.onDispose();

		fx.destroy();
		for(e in Entity.ALL)
			e.destroy();
		gc();
	}


	/**
		Start a cumulative slow-motion effect that will affect `tmod` value in this Process
		and its children.

		@param sec Realtime second duration of this slowmo
		@param speedFactor Cumulative multiplier to the Process `tmod`
	**/
	public function addSlowMo(id:String, sec:Float, speedFactor=0.3) {
		if( slowMos.exists(id) ) {
			var s = slowMos.get(id);
			s.f = speedFactor;
			s.t = M.fmax(s.t, sec);
		}
		else
			slowMos.set(id, { id:id, t:sec, f:speedFactor });
	}


	function updateSlowMos() {
		// Timeout active slow-mos
		for(s in slowMos) {
			s.t -= utmod * 1/Const.FPS;
			if( s.t<=0 )
				slowMos.remove(s.id);
		}

		// Update game speed
		var targetGameSpeed = 1.0;
		for(s in slowMos)
			targetGameSpeed*=s.f;
		curGameSpeed += (targetGameSpeed-curGameSpeed) * (targetGameSpeed>curGameSpeed ? 0.2 : 0.6);

		if( M.fabs(curGameSpeed-targetGameSpeed)<=0.001 )
			curGameSpeed = targetGameSpeed;
	}


	/**
		Pause briefly the game for 1 frame: very useful for impactful moments,
		like when hitting an opponent in Street Fighter ;)
	**/
	public inline function stopFrame() {
		ucd.setS("stopFrame", 0.2);
	}

	override function preUpdate() {
		super.preUpdate();
		
		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate();
	}

	override function postUpdate() {
		super.postUpdate();


		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		for(e in Entity.ALL) if( !e.destroyed ) e.finalUpdate();
		gc();

		// Update slow-motions
		updateSlowMos();
		baseTimeMul = ( 0.2 + 0.8*curGameSpeed ) * ( ucd.has("stopFrame") ? 0.3 : 1 );
		Assets.tiles.tmod = tmod;
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	
	override function update() {
		super.update();
		
		// Z sort
		//if( !cd.hasSetS("zsort",0.1) )
		Entity.ALL.sort( function(a,b) return Reflect.compare(a.z, b.z) );

		for(e in Entity.ALL) {
			scroller.over(e.spr);
			if( !e.destroyed ) e.update();
		}

		if (levelToLoad!=null)
			startLevel(levelToLoad);
		#if debug
		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			#end

			// Restart
			if( ca.selectPressed())
				Main.ME.startGame();
		}
		#end
	}

	public function loadNextLevel() {
		
		mask.visible=true;
		tw.createS(mask.alpha, 0>1, 0.6).end(()-> {
			levelIndex++;
			if (levelIndex>=levelLoop.length)
			{
				levelIndex = 0;
				loopCount++;
				
				var txt:String = Data.text.get(endCycle).text;
				txt = StringTools.replace(txt, "{0}",  Std.string(loopCount));
				
				Assets.SBANK.next(1);

				new EndWindow(txt,()->{
					levelToLoad = levelLoop[levelIndex];
				}, 2);
			}
			else 
			{
				levelToLoad = levelLoop[levelIndex];
			}
		});
	}
	
	function startLevel(l : LevelSeed) {
		for(e in Entity.ALL)
			e.destroy();
		gc();
		fx.clear();
		if( level!=null )
			level.destroy();

		level = new Level(l);
		

		Process.resizeAll();

		levelToLoad=null;
		mask.visible=true;
		tw.createS(mask.alpha, 1>0, 0.6).end(()->{
			
			if (levelIndex==0){
				Main.ME.bgmVolume = 0;
				Main.ME.lobbyVolume = 1;
			}
			else {
				Main.ME.bgmVolume = 1;
				Main.ME.lobbyVolume = 0;
			}

			mask.visible=false;
		});
	}

	public function addMoney(amount:Int, sound:Bool=false) {
		money += amount;
		
		hud.setMoney(money);
		amount>0 ? hud.blinkWhite() : hud.blinkRed();

		if (sound && !cd.hasSetMs("moneySfx",50)) {
			moneySfx[M.rand(moneySfx.length)].play(0.3);
		}
	}

	public var victoryMusic = false;
	public function win() {
		victoryMusic  = true;
		var victoryMusic = Assets.SBANK.victory();
		victoryMusic.play(true);
		
		mask.visible =true;
		mask.color = new Vec(1,1,1);
		tw.createS(mask.alpha,0>1,0.8).onEnd = ()->{
			var e = new EndWindow(Data.text.get(victory).text, ()-> {
				victoryMusic.stop();
				Main.ME.restartGame = true;
				Main.ME.reloadMusic();
				//e.addVictoryImage();
			});
		}

	}

	public function addLevel(data:Data.Shop) {
		var level = Game.ME.world.resolveLevel(data.levelName.toString());
		var lSeed = new LevelSeed(level, data);
		levelLoop.push(lSeed);
		updateBonuses();
	}

	function updateBonuses() {
		bonusMoney = 1;
		for (l in levelLoop)
		if (l.data!=null)
		for (b in l.data.bonus) {
			switch (b.bonus) {
				case Money(chance):
					bonusMoney += chance/100;
				case Treasure(chance):
					bonusTreasure += chance/100;
			}
		}
	}

	public function showLogo() {
		pause();
		
		var logo = Assets.ui.getBitmap("logo");
		var b = logo.getBounds();
		logo.x = w()/2 - b.width/2;
		logo.y = h()/2 - b.height/2 + 50;

		Main.ME.tw.createS(logo.alpha,0>1,1);

		var y = logo.y -50;
		Main.ME.tw.createS(logo.y,y,2);

		root.add(logo, Const.DP_UI);
		Main.ME.delayer.addS(()->{
			resume();
			Main.ME.tw.createS(logo.alpha,1>0,0.5);
		}, 3);
	}
}

