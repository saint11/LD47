
import hxsl.Types.Vec;
import ui.PurgeUi;
import en.inter.Purge;
import ui.EndWindow;
import ui.ShopWindow;
import Data;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;
	public var ca : dn.heaps.Controller.ControllerAccess;

	var scene:h2d.Scene;

	public var mouseX(get,never) : Float; function get_mouseX() return (scene.mouseX - Game.ME.scroller.x)/ Const.SCALE;
	public var mouseY(get,never) : Float; function get_mouseY() return (scene.mouseY - Game.ME.scroller.y)/ Const.SCALE;
	public var rawMouseX(get,never) : Float; function get_rawMouseX() return (scene.mouseX)/ Const.SCALE;
	public var rawMouseY(get,never) : Float; function get_rawMouseY() return (scene.mouseY)/ Const.SCALE;

	public var restartGame:Bool;

	public var lobbyVolume:Float = 0;
	public var bgmVolume:Float = 0;
	var curLobbyVolume:Float = 0;
	var curBgmVolume:Float = 0;

	var bgm:dn.heaps.Sfx;
	var lobbyBgm:dn.heaps.Sfx;

	public function new(s:h2d.Scene) {
		super();
		ME = this;
		scene = s;

        createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff<<24|0x3E2C46;
        #if( hl && !debug )
        engine.fullScreen = true;
        #end

		// Resources
		#if(hl)
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed();
        #end

        // Hot reloading
		#if debug
        hxd.res.Resource.LIVE_UPDATE = true;
        hxd.Res.data.watch(function() {
            delayer.cancelById("cdb");

            delayer.addS("cdb", function() {
            	Data.load( hxd.Res.data.entry.getBytes().toString() );
            	if( Game.ME!=null )
                    Game.ME.onCdbReload();
            }, 0.2);
        });
		#end

		// Assets & data init
		Assets.init();
		new ui.Console(Assets.fontTiny, s);
		
		Lang.init("en");
		Data.load( hxd.Res.data.entry.getText() );

		// Game controller
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);

		controller.bind(AXIS_LEFT_Y_NEG, Key.DOWN, Key.S);
		controller.bind(AXIS_LEFT_Y_POS, Key.UP, Key.W);

		controller.bind(A, Key.Z, Key.SPACE);
		controller.bind(B, Key.ESCAPE, Key.BACKSPACE, Key.MOUSE_RIGHT);
		controller.bind(Y, Key.MOUSE_LEFT);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.N);

		// Start
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontMedium);
		delayer.addF( startGame, 1 );

	}


	public function startGame() {
		reloadMusic();

		if(ShopWindow.ME!=null)
			ShopWindow.ME.destroy();

		if (EndWindow.ME!=null)
			EndWindow.ME.destroy();

		if (PurgeUi.ME !=null)
			PurgeUi.ME.destroy();

		if( Game.ME!=null ) {
			Game.ME.destroy();
			delayer.addF(function() {
				new Game();		
			}, 1);
		}
		else
		{
			new Game();
			#if !debug
			Game.ME.showLogo();
			#end
		}
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_WID>0 )
			Const.SCALE = ( w()/Const.AUTO_SCALE_TARGET_WID );
		else if( Const.AUTO_SCALE_TARGET_HEI>0 )
			Const.SCALE = ( h()/Const.AUTO_SCALE_TARGET_HEI );

		Const.UI_SCALE = Const.SCALE;
	}

    override function update() {
		Assets.tiles.tmod = tmod;
		#if(debug )
		if (ca.isKeyboardDown(Key.F1))
			Console.ME.show();
		if (ca.isKeyboardDown(Key.F2))
			Console.ME.setFlag("bounds", true);
		#end

		super.update();
		
		if (restartGame) {
			restartGame=false;
			startGame();
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		
		if (!Game.ME.victoryMusic && EndWindow.ME==null) {
			curLobbyVolume = M.lerp(curLobbyVolume, lobbyVolume * 0.5, 0.1);
			dn.heaps.Sfx.setGroupVolume(1, curLobbyVolume);
			
			curBgmVolume = M.lerp(curBgmVolume, bgmVolume * 0.7, 0.1);
			dn.heaps.Sfx.setGroupVolume(2, curBgmVolume);
		}
		else 
		{
			dn.heaps.Sfx.setGroupVolume(1, 0);
			dn.heaps.Sfx.setGroupVolume(2, 0);
		}
	}

	public function reloadMusic() {
		if (lobbyBgm==null){
			lobbyBgm = Assets.SBANK.lobby();
			lobbyBgm.playOnGroup(1, true);
		}// else lobbyBgm.stop();
		
		if (bgm==null) {
			bgm = Assets.SBANK.bgm();
			bgm.playOnGroup(2, true);
		}// else bgm.stop();
		

		// delayer.addF(()->{
		// 	bgm.playOnGroup(2, true);
		// 	lobbyBgm.playOnGroup(1, true);
		// },1);
	}
}