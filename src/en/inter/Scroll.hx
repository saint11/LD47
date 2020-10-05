package en.inter;

import hxsl.Types.Vec;

class Scroll extends Interactive {
    
    var seed:Int = 0;
	var talkTf : Null<h2d.Text>;

    public function new(x,y) {
        super(x,y);
        setPosPixel((x + 0.5)*Const.GRID, y*Const.GRID);
        
        imovable = true;
        tall = true;
        
        spr.anim.playAndLoop("ghost_idle");
        spr.anim.setSpeed(0.12);
        enableShadow(2);

        seed = M.rand();

        cd.setS("say",1);
        cd.onComplete("say", ()->{
            var txt = getLine(Game.ME.loopCount);
            if (txt!=null)
                sayWords(txt);
        });
    }

    function getLine(loop:Int) {
        for (l in Data.dialog.all) {
            if (l.loop==loop)
                return l.text;
        }

        return null;
    }

    override function update() {
        super.update();

        altitude = 10 + Math.sin(ftime * 0.05) * 5;

        spr.alpha = 0.5 + Math.sin(ftime * 0.02) * 0.2;
    }
    
    override function dispose() {
        super.dispose();
        level.scroll=null;
        
		if( talkTf!=null )
			talkTf.remove();
    }

    override function onActivate(by:Hero) {
        super.onActivate(by);
        new ui.ShopWindow(seed);
    }
    override function postUpdate() {
        super.postUpdate();
        
		if( talkTf!=null ) {
			talkTf.x = Std.int(footX-talkTf.textWidth*0.5);
			talkTf.y = Std.int(footY-118-talkTf.textHeight + txtY);
        }
        
        
        var t = game.tw.createS(spr.alpha, 1>0, 0.7);
        t.delayMs(800);
    }

    public function bye() {
        hasColl=false;

    }

    function clearWords(?immediate=false) {
		if( talkTf!=null ) {
			if( immediate )
				talkTf.remove();
			else {
				var e = talkTf;
				game.tw.createS(e.alpha, 0, 1.3).end( e.remove );
			}
			talkTf = null;
		}
	}
    var txtY = 0.;
	public function sayWords(str:String, ?c=0xFFFFFF) {
		clearWords();
        talkTf = new h2d.Text(Assets.fontMedium);
        //talkTf.scale(0.79);
		game.scroller.add(talkTf, Const.DP_UI);
		talkTf.text = str;
		talkTf.textColor = c;
        talkTf.maxWidth = 250;
        talkTf.color = new Vec(1, 0.6, 0.45 );
        talkTf.dropShadow = {dx:  0,dy: 4, color: 0x0, alpha: 1};
        var e = talkTf;
        
		game.tw.createS(e.alpha, 0>1, 0.7);
		game.tw.createS(txtY, 0>-64, str.length*0.1);

		game.delayer.cancelById("clearSay"+uid);
		game.delayer.addS("clearSay"+uid, clearWords.bind(), 2+str.length*0.1);
    }
    
}