package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;
import misc.meta.transition.RTFunkinTransition;
import misc.meta.states.MainMenuState;
import openfl.display.Sprite;

class Main extends Sprite
{
    var skipIntro:Bool = true;
    public var fps:Int = 60;

    public function new()
    {
        super();
		FlxSprite.defaultAntialiasing = true;
        var game:FlxGame = new FlxGame(1280, 720, MainMenuState, fps, fps, skipIntro);
        addChild(game);
    }

    public static function switchState(nextState:FlxState)
    {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;

		if(!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new RTFunkinTransition(0.6, false));
			if(nextState == FlxG.state)
			{
				RTFunkinTransition.finishCallback = function() {
					FlxG.resetState();
				};
			} 
			else
			{
				RTFunkinTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
    }
}
