package misc.meta;

import flixel.FlxG;
import flixel.util.FlxColor;
import haxe.io.Bytes;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class ScreenshotHelper
{
    public static var soundName:String = 'screenshot';

    public static function takeScreenshot():Void
    {
        var stage = Lib.current.stage;
        var width = stage.stageWidth;
        var height = stage.stageHeight;

        var bmd = new BitmapData(width, height, false, 0x000000);
        bmd.draw(stage);

        var byteArray = bmd.encode(new Rectangle(0, 0, bmd.width, bmd.height), new PNGEncoderOptions());
        var bytes:Bytes = Bytes.ofData(byteArray);

        var dir = "screenshots";
        if (!FileSystem.exists(dir)) {
            FileSystem.createDirectory(dir);
        }

        FlxG.camera.flash(FlxColor.WHITE, 0.3);
        FlxG.sound.play(Paths.sound(soundName));

        var safeDate = Date.now().toString().replace(":", "-").replace(":", "-").replace(" ", "_");
        var filename = haxe.io.Path.join([dir, 'screenshot_$safeDate.png']);

        File.saveBytes(filename, bytes);

        trace('Screenshot salva em: $filename');
    }

    function saveScreenshot():Void {
        var bmd = new BitmapData(FlxG.width, FlxG.height);
        bmd.draw(FlxG.stage);

        var bytes:Bytes = bmd.encode(new Rectangle(0, 0, bmd.width, bmd.height), new PNGEncoderOptions());
        File.saveBytes("screenshot_" + Date.now().getTime() + ".png", bytes);
    }
}
