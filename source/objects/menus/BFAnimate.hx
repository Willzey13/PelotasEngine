package objects.menus;

import flixel.FlxSprite;
import flixel.animation.FlxAnimationController;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flxanimate.FlxAnimate;
import openfl.utils.Assets;

class BFAnimate extends FlxAnimate
{
	public var isAnimateAtlas:Bool = true;
    var anims:Array<Array<Dynamic>> = [
        ["idle",                "Boyfriend DJ",                 24, false],
        ["confirm",             "Boyfriend DJ confirm",         24, false],
        ["first pump",          "Boyfriend DJ fist pump",       24, false],
        ["first",               "boyfriend dj intro",           24, false],
        ["lost 1",              "Boyfriend DJ loss reaction 1", 24, false],
        ["watching",            "Boyfriend DJ watchin tv OG",   24, false],
        ["CS",                  "Boyfriend DJ to CS",           24, false],
        ["new character",       "Boyfriend DJ new character ",  24, false],
    ];

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		initBF();
	}

	function initBF():Void
    {
        isAnimateAtlas = true;
        showPivot = false;
        var sheetBase:String = "assets/images/freeplay/bf";

        loadAtlas(sheetBase);
        screenCenter();
        x += 45;
        y += 600;

        for (animData in anims)
            anim.addBySymbol(animData[0], animData[1], animData[2], animData[3]);

        trace("Idle frames: " + anim.getByName("idle"));
    }

    public function playAnim(name:String = "", ?forced:Bool = false)
    {
        anim.play(name, forced);
    }
}
