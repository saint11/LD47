import en.inter.Purge;
import en.inter.WeaponPedestal;
import en.inter.Treasure;
import en.inter.Fountain;
import en.FloorTrap;
import h2d.Tile;
import hxd.res.Image;
import h2d.Layers;
import en.inter.Scroll;
import en.Door;
import h2d.Interactive;
import en.Mob;
import hxd.fmt.spine.Data.Bone;
import en.Hole;
import h2d.Flow.FlowAlign;
import h2d.Graphics;
import hxd.Res;
import en.Hero;

class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; function get_wid() return 16;
	public var hei(get,never) : Int; function get_hei() return 15;
	
	public var pxWid(get,never) : Int; function get_pxWid() return wid * Const.GRID;
	public var pxHei(get,never) : Int; function get_pxHei() return hei * Const.GRID;

	public var offsetX = 0;
	public var offsetY = 0;

	var tilesetSource : h2d.Tile;

	var marks : Map< LevelMark, Map<Int,Bool> > = new Map();
	var invalidated = true;

	var fastColl: Map<Int,Bool>;

	public var scroll:Scroll;

	var fgLeft: h2d.Graphics;
	var fgRight: h2d.Graphics;
	var parallax:Float = 0.3;

	public var splater : h2d.Graphics;
	public var seed:LevelSeed;

	var roomComplete:Bool = false;

	public function new(level:LevelSeed) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		
		seed = level;
		var l = level.getLevel();
		level.resetSeed();

		tilesetSource = hxd.Res.world.tiles.toTile();
		
		var bg = Res.bg.wall_simple01.toTile();
		var floor = getRandomFloor(level);
		
		offsetX = M.round((bg.width - floor.width)/ 2);
		offsetY = M.round((bg.height - floor.height)/ 2);
		
		var colorVariation:Float = Data.globals.get(colorVariation).value;
		var floorG = new Graphics(root);
		floorG.drawTile(0, 0, floor);
		var floorColor = floorG.color = level.rcolor(1 - colorVariation, colorVariation);
		floorG.scaleX = level.getDir();
		if (floorG.scaleX<0)
			floorG.x += floorG.tile.width;

		splater = new h2d.Graphics(root);

		var g = new Graphics(root);
		g.drawTile(-offsetX, -offsetY, bg);
		var doorY:Int = Data.globals.get(doorY).value;
		var wallTint = level.rcolor(1 - colorVariation, colorVariation);
		g.color = wallTint;
		
		if (game.levelIndex==0){
			var d = Assets.tiles.h_get("maindoor", g);
			d.y = 616;
			d.color = wallTint;
		}
		
		g.scaleX = level.getDir();
		if (g.scaleX<0)
			g.x += offsetX/2 + g.tile.width/4;

		// Load a bunch of entities

		if (l.l_Entities.all_Hero!=null && Game.ME.loopCount==0)
		for (e in l.l_Entities.all_Hero)
			Game.ME.hero = new Hero(e.cx,e.cy);	
		else 
			Game.ME.hero = new Hero(1,doorY);
		

		fastColl = [];

		if (l.l_Entities.all_Hole!=null)
		for (e in l.l_Entities.all_Hole) {
			new Hole(e.cx,e.cy);
			//fastColl[coordId(e.cx, e.cy)] = true;
		}

		if (l.l_Entities.all_Mob!=null)
		for (m in l.l_Entities.all_Mob) {
			if (level.range(1) < m.f_Chance + m.f_ChanceIncrease * level.loop)
				new Mob(m.cx, m.cy, m);
		}

		if (l.l_Entities.all_Scroll!=null)
		for	(e in l.l_Entities.all_Scroll) {
			scroll = new Scroll(e.cx, e.cy);
		}

		if (l.l_Entities.all_TrapFloor!=null)
		for (e in l.l_Entities.all_TrapFloor) {
			if (level.range(1) < e.f_Chance + e.f_ChanceIncrease * level.loop) {
				var trap = new FloorTrap(e.cx, e.cy, e.f_Auto, true);
				trap.color = floorColor;
			}
		}

		if (l.l_Entities.all_TrapFloorSm!=null)
		for (e in l.l_Entities.all_TrapFloorSm) {
			if (level.range(1) < e.f_Chance + e.f_ChanceIncrement * level.loop) {
				var trap = new FloorTrap(e.cx, e.cy, true, false);
				trap.color = floorColor;
			}
		}
	
		if (l.l_Entities.all_Fountain!=null)
		for (e in l.l_Entities.all_Fountain) {
			if (level.range(1) < e.f_Chance + e.f_ChanceIncrement * level.loop) {
				new Fountain(e.cx, e.cy);
			}
		}

		if (l.l_Entities.all_Chest!=null)
		for (e in l.l_Entities.all_Chest) {
			new Treasure(e.cx, e.cy,e);
		}

		if (l.l_Entities.all_WeaponStand!=null)
		for (e in l.l_Entities.all_WeaponStand) {
			new WeaponPedestal(e.cx, e.cy,e);
		}
	
		// Check for purging item
		if (level.data!=null)
		if (rnd(0,1) < level.loop * level.data.purgeChance && Game.ME.money>Data.globals.get(purgePrice).value)
		{
			new Purge(M.round(wid/2), 0, level);
		}

		var dR =new Door(16,doorY, 1);
		var dL = new Door(-1,doorY, -1);
		dL.locked = true;

		dR.setColor(wallTint);
		dL.setColor(wallTint);

		fgLeft = new h2d.Graphics();
		fgRight = new h2d.Graphics();
		game.scroller.add(fgLeft, Const.DP_TOP);
		game.scroller.add(fgRight, Const.DP_TOP);
		fgLeft.drawTile(-offsetX * (2-parallax) - pxWid * 0.26 - 200, - offsetY * (2-parallax), getRandomForeground(level));
		fgRight.drawTile(-offsetX * (2-parallax) - pxWid * 0.75 - 200, -offsetY * (2-parallax), getRandomForeground(level));
		fgRight.scaleX = -1;

		
		for(s in level.splatters) {
			addSplatterGfx(s.str, s.x, s.y);
		}

		game.hud.sayRoomName(level);

		if (isComplete())
			roomComplete=true;
	}

	function getRandomFloor(level:LevelSeed):Tile {
		var list: Array<Image> = [Res.bg.floor_simple01, Res.bg.floor_simple02, Res.bg.floor_simple03, Res.bg.floor_simple04];
		return list[level.irange(list.length)].toTile();
	}
	function getRandomForeground(level:LevelSeed):Tile {
		var list: Array<Image> = [Res.bg.foreground01, Res.bg.foreground02, Res.bg.foreground03, Res.bg.foreground04];
		return list[level.irange(list.length)].toTile();
	}
	/**
		Mark the level for re-render at the end of current frame (before display)
	**/
	public inline function invalidate() {
		invalidated = true;
	}

	/**
		Return TRUE if given coordinates are in level bounds
	**/
	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei;

	/**
		Transform coordinates into a coordId
	**/
	public inline function coordId(cx,cy) return cx + cy*wid;


	/** Return TRUE if mark is present at coordinates **/
	public inline function hasMark(mark:LevelMark, cx:Int, cy:Int) {
		return !isValid(cx,cy) || !marks.exists(mark) ? false : marks.get(mark).exists( coordId(cx,cy) );
	}

	/** Enable mark at coordinates **/
	public function setMark(mark:LevelMark, cx:Int, cy:Int) {
		if( isValid(cx,cy) && !hasMark(mark,cx,cy) ) {
			if( !marks.exists(mark) )
				marks.set(mark, new Map());
			marks.get(mark).set( coordId(cx,cy), true );
		}
	}

	/** Remove mark at coordinates **/
	public function removeMark(mark:LevelMark, cx:Int, cy:Int) {
		if( isValid(cx,cy) && hasMark(mark,cx,cy) )
			marks.get(mark).remove( coordId(cx,cy) );
	}

	/** Return TRUE if "Collisions" layer contains a collision value **/
	public inline function hasCollision(cx,cy) : Bool {
		return !isValid(cx,cy) ? true : fastColl[coordId(cx,cy)];
	}

	override function postUpdate() {
		super.postUpdate();

		fgLeft.x = Game.ME.scroller.x * (1 - parallax);
		fgRight.x = Game.ME.scroller.x * (1 - parallax);
		fgLeft.y = Game.ME.scroller.y * (1 - parallax);
		fgRight.y = Game.ME.scroller.y * (1 - parallax);

		if (!roomComplete && isComplete()) {
			roomComplete=true;
			
			if (game.levelIndex>0)
				Assets.SBANK.complete_room(0.7);
		}

		if (Game.ME.levelIndex==0)
			Main.ME.lobbyVolume=1;
	}

	override function onDispose() {
		super.onDispose();
		fgLeft.remove();
		fgRight.remove();
	}

	public function isComplete() :Bool {
		if (scroll == null && Mob.ALL.length==0) {
			return true;
		} else {
			return false;
		}
	}

	public function addSplatter(spr:String, x:Float, y:Float) {
		
		addSplatterGfx(spr, x,y);

		seed.splatters.push({x:x, y:y, str:spr});
	}

	function addSplatterGfx(spr:String, x:Float, y:Float) {
		var tile = Assets.fx.getTile(spr);
		
		splater.drawTile(x-tile.width/2,y + tile.height/2, tile);
	}

}