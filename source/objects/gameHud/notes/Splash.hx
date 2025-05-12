package objects.gameHud.notes;

import data.Conductor;
import flixel.FlxSprite;
import misc.meta.states.PlayState;
import flixel.graphics.frames.FlxAtlasFrames;

class Splash extends FlxSprite 
{
	public function new(x:Float, y:Float, direction:String, time:Float, ?isSustain:Bool = false) 
    {
        super(x, y);
    }
}
