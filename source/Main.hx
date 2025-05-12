package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import misc.meta.states.PlayState;
import openfl.display.Sprite;

class Main extends Sprite
{
	var skipIntro:Bool = true;
	public var fps:Int = 120;
	public function new()
	{
		super();
		FlxG.fixedTimestep = false;
		FlxSprite.defaultAntialiasing = true;
		addChild(new FlxGame(1280, 720, PlayState, fps, fps, skipIntro));
	}
}
