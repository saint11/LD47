import en.Hero;
import hxd.Res;
import hxd.res.Atlas;

class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; inline function get_wid() return level.l_Collisions.cWid;
	public var hei(get,never) : Int; inline function get_hei() return level.l_Collisions.cHei;

	public var level : World.World_Level;
	var tilesetSource : h2d.Tile;

	var marks : Map< LevelMark, Map<Int,Bool> > = new Map();
	var invalidated = true;

	var hero : Hero;

	public function new(l:World.World_Level) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		level = l;
		tilesetSource = hxd.Res.world.tiles.toTile();
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
		return !isValid(cx,cy) ? true : level.l_Collisions.getInt(cx,cy)==0;
	}

	/** Render current level**/
	function render() {
		root.removeChildren();

		var tg = new h2d.TileGroup(tilesetSource, root);

		var collisions = level.l_Collisions;
		var tile = Res.atlas.tiles.get("cube");
		for (x in 0...collisions.cWid)
		for (y in 0...collisions.cHei){
			if( collisions.getInt(x,y) == 0) {
				var screen = getScreenPos(x,y);
				tg.add(screen.x + Const.TILE_OFFSET_X, screen.y + Const.TILE_OFFSET_Y, tile);
			}
		}

		for (e in level.l_Entities.all_Hero) {
			hero = new Hero(e.cx, e.cy);
		}
	}

	function getScreenPos(x:Int, y:Int) : Point {
		var screen = new Point(0,0);
		screen.x = (x - y) * Const.TILE_W_HALF;
		screen.y = (x + y) * Const.TILE_H_HALF;
		return screen;
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}