package;

import data.CrashHandler;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import misc.meta.states.MainMenuState;
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
		CrashHandler.initialize();
		addChild(new FlxGame(1280, 720, MainMenuState, fps, fps, skipIntro));
		FlxG.autoPause = false;
	}
}
