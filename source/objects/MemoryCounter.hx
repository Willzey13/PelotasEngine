package objects;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flash.system.System;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.media.Sound;
import openfl.Assets;
import sys.FileSystem;
import openfl.system.System;

class MemoryCounter extends TextField
{
    var memPeak:Float = 0;

    static final BYTES_PER_MEG:Float = 1024 * 1024;
    static final ROUND_TO:Float = 1 / 100;

    public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
    {
        super();
        this.x = x;
        this.y = y;
        this.width = 500;
        this.selectable = false;
        this.mouseEnabled = false;
        defaultTextFormat = new TextFormat("_sans", 12, color);
        text = "RAM: ";

        #if flash
        addEventListener(Event.ENTER_FRAME, function(e) {
        var time = Lib.getTimer();
        __enterFrame(time - currentTime);
        });
        #end
    }

    @:noCompletion
    #if !flash override #end function __enterFrame(deltaTime:Float):Void
    {
        var mem:Float = FlxMath.roundDecimal(System.totalMemory / BYTES_PER_MEG, 1);
        if (mem > memPeak) memPeak = mem;

        text = 'RAM: ${mem}MB / ${memPeak}MB';
    }
}

class MemoryManager
{
    public static var trackedGraphics:Map<String, FlxGraphic> = new Map();
    public static var trackedSounds:Map<String, Sound> = new Map();
    public static var keepAssets:Array<String> = [];
    public static var dumpExclusions:Array<String> = [
        "fonts/default",
        "fonts/bold",
        "menu/checkmark",
        "menu/menuArrows"
    ];

    public static function trackGraphic(key:String, graphic:FlxGraphic):Void {
        trackedGraphics.set(key, graphic);
        if (!keepAssets.contains(key)) keepAssets.push(key);
    }

    public static function trackSound(key:String, sound:Sound):Void {
        trackedSounds.set(key, sound);
        if (!keepAssets.contains(key)) keepAssets.push(key);
    }

    public static function clearAllMemory(?cleanUnused:Bool = false):Void
    {
        var clearedGraphics:Array<String> = [];

        for (key => graphic in trackedGraphics)
        {
            var cleanKey = key.split(".")[0]; // remove extensão se houver
            if (dumpExclusions.contains(cleanKey)) continue;

            clearedGraphics.push(key);
            trackedGraphics.remove(key);

            if (openfl.Assets.cache.hasBitmapData(key))
                openfl.Assets.cache.removeBitmapData(key);

            FlxG.bitmap.remove(graphic);
            graphic.dump();
            graphic.destroy();
        }

        trace('Cleared rendered graphics: $clearedGraphics');
        trace('Total cleared graphics: ${clearedGraphics.length}');

        @:privateAccess
        for (key in FlxG.bitmap._cache.keys())
        {
            if (!keepAssets.contains(key) && !trackedGraphics.exists(key))
            {
                var graphic = FlxG.bitmap._cache.get(key);
                if (graphic != null)
                {
                    openfl.Assets.cache.removeBitmapData(key);
                    FlxG.bitmap._cache.remove(key);
                    graphic.dump();
                    graphic.destroy();
                }
                trackedGraphics.remove(key);
            }
        }

        for (key in trackedGraphics.keys())
        {
            if (!keepAssets.contains(key))
            {
                var graphic = trackedGraphics.get(key);
                if (graphic != null)
                {
                    @:privateAccess
                    FlxG.bitmap._cache.remove(key);
                    graphic.destroy();
                }
                trackedGraphics.remove(key);
            }
        }

        for (key => sound in trackedSounds)
        {
            if (dumpExclusions.contains(key + '.ogg')) continue;

            Assets.cache.clear(key);
            trackedSounds.remove(key);
        }

        for (key in trackedSounds.keys())
        {
            if (!keepAssets.contains(key))
            {
                Assets.cache.clear(key);
                trackedSounds.remove(key);
            }
        }

        if (!cleanUnused)
            Assets.cache.clear("songs");

        FlxG.bitmap.clearCache();

        keepAssets = [];
        keepAssets.push("assets/images/fonts/bold");
        System.gc();
    }

    public static function clearUnusedMemory():Void
    {
        FlxG.bitmap.clearCache();
        for (key in trackedGraphics.keys()) {
            if (!keepAssets.contains(key)) {
                var graphic = trackedGraphics.get(key);
                if (graphic != null) {
                    @:privateAccess
                    FlxG.bitmap._cache.remove(key);
                    graphic.destroy();
                }
                trackedGraphics.remove(key);
            }
        }

        for (key in trackedSounds.keys()) {
            if (!keepAssets.contains(key)) {
                var sound = trackedSounds.get(key);
                if (sound != null) {
                    Assets.cache.clear(key);
                }
                trackedSounds.remove(key);
            }
        }

        keepAssets = [];
        keepAssets.push("assets/images/fonts/bold");

        System.gc();
    }

    public static function clearStoredMemory(?cleanUnused:Bool = false):Void {
        // Limpar gráficos não utilizados
        @:privateAccess
        for (key in FlxG.bitmap._cache.keys()) {
            if (!keepAssets.contains(key)) {
                var graphic = FlxG.bitmap._cache.get(key);
                if (graphic != null) {
                    openfl.Assets.cache.removeBitmapData(key);
                    FlxG.bitmap._cache.remove(key);
                    graphic.destroy();
                }
                trackedGraphics.remove(key);
            }
        }

        // Limpar sons não utilizados
        for (key in trackedSounds.keys()) {
            if (!keepAssets.contains(key)) {
                Assets.cache.clear(key);
                trackedSounds.remove(key);
            }
        }

        // Limpar cache de assets específicos, se desejado
        if (cleanUnused) {
            Assets.cache.clear("songs"); // Supondo que esse seja um prefixo comum
        }

        // Resetar a lista de ativos mantidos
        keepAssets = [];
        keepAssets.push("assets/images/fonts/bold");
        System.gc();
    }
}
