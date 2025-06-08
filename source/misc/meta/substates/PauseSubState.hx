package misc.meta.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import misc.meta.states.PlayState;

using StringTools;

class PauseSubState extends FlxSubState
{
    public var pauseCam:FlxCamera;

	static var pauseItems:Array<String> = ['Resume', 'Restart', 'Exit' /*, 'Open Chart Editor'*/]; //meu pau caiu
    var pauseGrp:FlxTypedGroup<FlxText>;

    var curSelected:Int = 0;
    var blackBg:FlxSprite;

    override function create()
        {
            super.create();

            pauseCam = new FlxCamera();
		    pauseCam.bgColor = FlxColor.TRANSPARENT;
		    FlxG.cameras.add(pauseCam);

            blackBg = new FlxSprite(0 ,0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
            blackBg.alpha = 0.5;
            blackBg.cameras = [pauseCam];
            add(blackBg);
 
            pauseGrp = new FlxTypedGroup<FlxText>();
            add(pauseGrp);

            for(i in 0...pauseItems.length)
                {
                    var pause = new FlxText(100, 200 + (100*i), 0, pauseItems[i], 32);
                    pause.setFormat(Paths.getFont('vcr', 'ttf'), 32, 0xFFFFFFFF, "center");
                    pause.cameras = [pauseCam];
                    pauseGrp.add(pause);
                }

            changeItem();
        }

    override function update(elapsed:Float) 
        {
            if (FlxG.keys.justPressed.ESCAPE) {
                close();
                FlxG.cameras.remove(pauseCam);
                PlayState.paused = false;
            }
        }

    
    public function changeItem(huh:Int = 0) 
        { 
            curSelected = FlxMath.wrap(curSelected + huh, 0, pauseItems.length - 1);
        }
}
