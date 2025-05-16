package misc.meta.states;

import data.Song;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import lime.app.Application;
import objects.menus.BFAnimate;

class FreeplayState extends MusicBeatState
{
    public var songs:Array<String> = [];
    public var select:Int = 0;
    var bfOG:BFAnimate;

    override function create()
    {
        super.create();

        songs.push('bopeebo');
        songs.push('high');
        songs.push('stress-pico');

        bfOG = new BFAnimate(0,-100);
        bfOG.playAnim('first');
        add(bfOG);
    }
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.justPressed('up'))
            select -= 1;

        if (controls.justPressed('down'))
            select += 1;

        if (FlxG.keys.justPressed.B)
            PlayState.isBotplay != PlayState.isBotplay;

        if (controls.justPressed("accept"))
        {
            changeSong(songs[select]); // stress-pico
            bfOG.playAnim('confirm');

            new FlxTimer().start(0.8, function(tmr:FlxTimer)
            {
                CoolUtil.switchState(new PlayState());
            });
        }
    }

    public static function changeSong(song:String = "test", diff:String = "")
    {
        PlayState.SONG = Song.loadFromJson(song + diff, song);
        PlayState.diff = diff;
        PlayState.isFreeplay = true;
    }
}