package;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.utils.AssetType;

class Paths
{
    public static function getPath(key:String, ?library:String = '')
    {
        if (library == '' || library == null) 
            return 'assets/$key'; 
        else 
            return 'assets/$library/$key';
    }

    inline static public function getSparrowAtlas(key:String, ?library:String = null):FlxAtlasFrames
    {
        var xmlPath:String = getPath('images/$key.xml', library);
        var pngPath:String = getPath('images/$key.png', library);
        
        var xml = Assets.getText(xmlPath);
        var pngBitmapData:BitmapData = BitmapData.fromFile(pngPath);
        
        var atlasGraphic:FlxGraphic = FlxGraphic.fromBitmapData(pngBitmapData, true);
        var atlasFrames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(atlasGraphic, xml);
    
        return atlasFrames;
    }

    public static function image(key:String, ?library:String = ''):FlxGraphic
    {
        var path:String = getPath('images/$key.png', library);
        var bitmapData:BitmapData = BitmapData.fromFile(path);
        return FlxGraphic.fromBitmapData(bitmapData, true);
    }

    public static function data(key:String):String
        return 'assets/data/$key.json';
}