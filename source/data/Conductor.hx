package data;

import flixel.FlxG;

class Conductor
{
    public static var songPosition:Float = 0;
    public static var songStartTime:Float = 0;
    public static var bpm:Float = 120;

    public static function update(elapsed:Float):Void
    {
        if (FlxG.sound.music != null && FlxG.sound.music.playing)
            songPosition = FlxG.sound.music.time;
    }

    public static function getNotePosition(noteTime:Float):Float
    {
        var speed:Float = 1000 / bpm;
        return (noteTime - songPosition) * speed;
    }
}
