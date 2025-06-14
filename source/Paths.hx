package;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;

class Paths
{
    public static function getPath(key:String, ?library:String = '')
    {
        var modPath = 'mods/$library/$key';
        if (library == null || library == '') modPath = 'mods/$key';

        if (FileSystem.exists(modPath)) return modPath;

        var assetPath = 'assets/$library/$key';
        if (library == null || library == '') assetPath = 'assets/$key';
        return assetPath;
    }

    public static function getData(direction:String, key:String, ?library:String)
    {
        return getPath('data/songs/$direction/$key.json', library);
    }

    public static function getFrag(key:String, ?library:String)
    {
        return getPath('shaders/$key.frag', library);
    }

    public static function getTextFromFile(key:String, ?library:String)
    {
        return getPath('$key', library);
    }

    public static function getFont(font:String, ?format:String = 'ttf', ?library:String = '')
    {
        return getPath('fonts/$font.$format', library);
    }

    public static function getSparrowAtlas(key:String, ?library:String = null):FlxAtlasFrames
    {
        var xmlPath:String = getPath('images/$key.xml', library);
        var pngPath:String = getPath('images/$key.png', library);

        var xml:String = File.getContent(xmlPath);
        var bitmap:BitmapData = BitmapData.fromFile(pngPath);

        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, true);
        MemoryManager.trackGraphic(key, graphic);

        return FlxAtlasFrames.fromSparrow(graphic, xml);
    }

    public static function image(key:String, ?library:String = ''):FlxGraphic
    {
        var path = getPath('images/$key.png', library);
        var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path), true);

        MemoryManager.trackGraphic(key, graphic);

        return graphic;
    }

    public static function sound(key:String, ?library:String = ''):Sound
    {
        var path = getPath('sounds/$key.ogg', library);
        var sound = Sound.fromFile(path);

        MemoryManager.trackSound(key, sound);

        return sound;
    }

    public static function voices(song:String, ?isPlayer:Bool = false):Sound
    {
        var suffix = isPlayer ? '-Player' : '';
        var songKey = '${getFormatPath(song)}/Voices$suffix';
        var path = getPath('songs/$songKey.ogg');
        var sound = Sound.fromFile(path);

        MemoryManager.trackSound(songKey, sound);

        return sound;
    }

    public static function voicesopponent(song:String, ?isOpponent:Bool = false):Sound
    {
        var suffix = isOpponent ? '-Opponent' : '';
        var songKey = '${getFormatPath(song)}/Voices$suffix';
        var path = getPath('songs/$songKey.ogg');
        var sound = Sound.fromFile(path);

        MemoryManager.trackSound(songKey, sound);

        return sound;
    }

    public static function inst(song:String):Sound
    {
        var path = getPath('songs/${getFormatPath(song)}/Inst.ogg');
        var sound = Sound.fromFile(path);

        MemoryManager.trackSound('${getFormatPath(song)}/Inst', sound);

        return sound;
    }

    public static function data(key:String):String
    {
        return getPath('data/$key.json');
    }

    public static function getFormatPath(path:String):String
    {
        var invalidChars = ~/[~&\\;:<>#]/;
        var hideChars = ~/[.,'"%?!]/;

        path = CoolUtil.replace(path, " ", "-");
        path = invalidChars.split(path).join("-");
        path = hideChars.split(path).join("");
        return CoolUtil.toLowerCase(path);
    }
}
