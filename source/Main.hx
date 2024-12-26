package;

import flixel.FlxGame;
import misc.meta.states.PlayState;
import openfl.display.Sprite;

class Main extends Sprite
{
	var skipIntro:Bool = true;
	public var fps:Int = 60;
	public function new()
	{
		super();
		addChild(new FlxGame(1280, 720, PlayState, fps, fps, skipIntro));
	}
}
