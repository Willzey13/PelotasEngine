package;

import data.CrashHandler;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import misc.meta.states.MainMenuState;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.FPS;

class Main extends Sprite {
	var skipIntro:Bool = true;
	public var fps:Int = 60;

	public static var fpsCounter:FPS;

	public static function main():Void {
		CrashHandler.initialize();
		CrashHandler.queryStatus();

		openfl.Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage == null)
			addEventListener(Event.ADDED_TO_STAGE, init);
		else
			init();
	}

	function init(?e:Event):Void {
		if (e != null) removeEventListener(Event.ADDED_TO_STAGE, init);

		FlxG.fixedTimestep = false;
		FlxSprite.defaultAntialiasing = true;
		FlxG.autoPause = true;

		var game = new FlxGame(1280, 720, MainMenuState, fps, fps, skipIntro);
		addChild(game);

		// #if debug
		// fpsCounter = new FPS(10, 3, 0xFFFFFF);
		// addChild(fpsCounter);
		// #end

		trace("Main initialized com sucesso.");
	}
}
