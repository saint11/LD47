import dn.heaps.Sfx;
import dn.heaps.slib.*;

class Assets {

	public static var SBANK = dn.heaps.assets.SfxDirectory.load("sfx");

	public static var fontPixel : h2d.Font;
	public static var fontTiny : h2d.Font;
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;

	public static var tiles : SpriteLib;
	public static var hero : SpriteLib;
	public static var ui : SpriteLib;
	public static var fx : SpriteLib;

	public static var shopIcons : h2d.Tile;

	static var initDone = false;

	public static function init() {
		if( initDone )
			return;
		initDone = true;

		Sfx.setGroupVolume(0, 0.75); //sfx
		Sfx.setGroupVolume(1, 0.45); // lobby music
		Sfx.setGroupVolume(2, 0.45); // bgm music

		fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
		fontTiny = hxd.Res.fonts.barlow_condensed_medium_regular_9.toFont();
		fontSmall = hxd.Res.fonts.barlow_condensed_medium_regular_11.toFont();
		fontMedium = hxd.Res.fonts.barlow_condensed_medium_regular_17.toFont();
		fontLarge = hxd.Res.fonts.barlow_condensed_medium_regular_32.toFont();

		shopIcons = hxd.Res.room_icons_png.toTile();

		tiles = dn.heaps.assets.Atlas.load("atlas/tiles.atlas");
		hero = dn.heaps.assets.Atlas.load("atlas/hero.atlas");
		ui = dn.heaps.assets.Atlas.load("atlas/ui.atlas");
		fx = dn.heaps.assets.Atlas.load("atlas/fx.atlas");

		tiles.defineAnim("trap_floor", "0(35),1,2,3,4(5),4(5)");
		tiles.defineAnim("spike", "0(35),1,2,3,4(5),4(5)");
	}
}