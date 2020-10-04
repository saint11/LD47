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

	public var wid(get,never) : Int; function get_wid() return level.l_Entities.cWid;
	public var hei(get,never) : Int; function get_hei() return level.l_Entities.cHei;
	
	public var pxWid(get,never) : Int; function get_pxWid() return level.l_Entities.cWid * Const.GRID;
	public var pxHei(get,never) : Int; function get_pxHei() return level.l_Entities.cHei * Const.GRID;

	public var offsetX = 0;
	public var offsetY = 0;

	public var level : World.World_Level;
	var tilesetSource : h2d.Tile;

	var marks : Map< LevelMark, Map<Int,Bool> > = new Map();
	var invalidated = true;

	var fastColl: Map<Int,Bool>;

	public var scroll:Scroll;

	var fgLeft: h2d.Graphics;
	var fgRight: h2d.Graphics;
	var parallax:Float = 0.3;

	public function new(l:World.World_Level) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		
		level = l;
		tilesetSource = hxd.Res.world.tiles.toTile();
		
		render();
		//trace("Level loaded offset is at " + offsetX +", " + offsetY);

		var doorY:Int = Data.globals.get(doorY).value;

		if (l.l_Entities.all_Hero!=null)
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
			new Mob(m.cx, m.cy, m);
		}

		if (l.l_Entities.all_Scroll!=null)
		for	(e in l.l_Entities.all_Scroll) {
			scroll = new Scroll(e.cx, e.cy);
		}

		if (l.l_Entities.all_TrapFloor!=null)
		for (e in l.l_Entities.all_TrapFloor) {
			new FloorTrap(e.cx, e.cy);
		}


		new Door(16,doorY, 1);
		var d = new Door(-1,doorY, -1);
		d.locked = true;

		fgLeft = new h2d.Graphics();
		fgRight = new h2d.Graphics();
		game.scroller.add(fgLeft, Const.DP_TOP);
		game.scroller.add(fgRight, Const.DP_TOP);
		fgLeft.drawTile(-offsetX * (2-parallax) - pxWid * 0.26, - offsetY, getRandomForeground());
		fgRight.drawTile(-offsetX * (2-parallax) - pxWid * 0.75, -offsetY, getRandomForeground());
		fgRight.scaleX = -1;
	}

	function getRandomFloor():Tile {
		var list: Array<Image> = [Res.bg.floor_simple01, Res.bg.floor_simple02];
		return list[M.rand(list.length)].toTile();
	}
	function getRandomForeground():Tile {
		var list: Array<Image> = [Res.bg.foreground01, Res.bg.foreground02, Res.bg.foreground03, Res.bg.foreground04];
		return list[M.rand(list.length)].toTile();
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

	/** Render current level**/
	function render() {
		root.removeChildren();

		var bg = Res.bg.wall_simple01.toTile();
		var floor = getRandomFloor();
		
		offsetX = M.round((bg.width - floor.width)/ 2);
		offsetY = M.round((bg.height - floor.height)/ 2);
		
		var g = new Graphics(root);
		g.drawTile(0, 0, floor);
		
		var g = new Graphics(root);
		g.drawTile(-offsetX, -offsetY, bg);
		
		// var layer = level.l_Collisions;
		// for( autoTile in layer.autoTiles ) {
		// 	var tile = layer.tileset.getAutoLayerHeapsTile(tilesetSource, autoTile);
		// 	tg.add(autoTile.renderX, autoTile.renderY, tile);
		// }
	}

	override function postUpdate() {
		super.postUpdate();

		fgLeft.x = Game.ME.scroller.x * (1 - parallax);
		fgRight.x = Game.ME.scroller.x * (1 - parallax);
		//fgLeft.y = Game.ME.scroller.y * (1 - parallax);

		if( invalidated ) {
			invalidated = false;
			render();
		}
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
}