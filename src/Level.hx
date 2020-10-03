import hxd.fmt.spine.Data.Bone;
import en.Hole;
import sys.ssl.Context.Config;
import h2d.Flow.FlowAlign;
import h2d.Graphics;
import hxd.Res;
import en.Hero;

class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; function get_wid() return level.l_Entities.cWid;
	public var hei(get,never) : Int; function get_hei() return level.l_Entities.cHei;
	
	public var pxWid : Int = Const.AUTO_SCALE_TARGET_WID;
	public var pxHei : Int = Const.AUTO_SCALE_TARGET_HEI;

	public var offsetX = 0;
	public var offsetY = 0;

	public var level : World.World_Level;
	var tilesetSource : h2d.Tile;

	var marks : Map< LevelMark, Map<Int,Bool> > = new Map();
	var invalidated = true;

	var fastColl: Map<Int,Bool>;

	var hero:Hero;

	public function new(l:World.World_Level) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		
		level = l;
		tilesetSource = hxd.Res.world.tiles.toTile();
		
		render();
		trace("Level loaded offset is at " + offsetX +", " + offsetY);

		for (e in l.l_Entities.all_Hero)
			hero = new Hero(e.cx,e.cy);	


		fastColl = [];
		for (e in l.l_Entities.all_Hole) {
			new Hole(e.cx,e.cy);
			fastColl[coordId(e.cx, e.cy)] = true;
		}
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
	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei-1;

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
		return !isValid(cx,cy) || fastColl[coordId(cx,cy)];
		//return !isValid(cx,cy) ? true : level.l_Collisions.getInt(cx,cy)==0;
	}

	/** Render current level**/
	function render() {
		root.removeChildren();

		var bg = Res.bg.wall_simple01.toTile();
		var floor = Res.bg.floor_simple01.toTile();
		
		pxWid = M.round(bg.width);
		pxHei = M.round(bg.height);
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


		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}