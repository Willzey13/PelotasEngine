package misc.meta.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class MainMenuState extends MusicBeatState
{
    override public function create():Void
    {
        super.create();

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GREEN);
        add(bg);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ENTER)
        {
            FlxG.switchState(new PlayState());
        }
    }
}