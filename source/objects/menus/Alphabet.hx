package objects.menus;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.Lib;
import openfl.utils.ByteArray;

enum Align {
    Left;
    Center;
    Right;
}

class Alphabet extends FlxSprite
{
    private static var atlasFrames:FlxAtlasFrames;
    private var charWidth:Int = 50;
    private var charHeight:Int = 56;
    private var flipUpsideDown:Bool = false;
    private var _char:String;

    public function new(char:String) {
        super();

        if (atlasFrames == null)
			loadAtlas();

        _char = char;
        setFrameForChar(_char);
    }

    private static function loadAtlas():Void {
        atlasFrames = Paths.getSparrowAtlas("fonts/bold");
    }

    private function setFrameForChar(c:String):Void {
        var frameName:String;

        switch (c) {
            // Símbolos comuns
            case '$': frameName = "$000";
            case '%': frameName = "%000";
            case '(': frameName = "(000";
            case ')': frameName = ")000";
            case '*': frameName = "*000";
            case '+': frameName = "+000";
            case '-': frameName = "-andpersand-000";
            case '!': frameName = "-exclamation point-000";
            case ',': frameName = "-comma-000";
            case '.': frameName = "-period-000";
            case ' ': frameName = null;

            // Letras maiúsculas e minúsculas
            case 'A', 'a': frameName = "A000";
            case 'B', 'b': frameName = "B000";
            case 'C', 'c': frameName = "C000";
            case 'D', 'd': frameName = "D000";
            case 'E', 'e': frameName = "E000";
            case 'F', 'f': frameName = "F000";
            case 'G', 'g': frameName = "G000";
            case 'H', 'h': frameName = "H000";
            case 'I', 'i': frameName = "I000";
            case 'J', 'j': frameName = "J000";
            case 'K', 'k': frameName = "K000";
            case 'L', 'l': frameName = "L000";
            case 'M', 'm': frameName = "M000";
            case 'N', 'n': frameName = "N000";
            case 'O', 'o': frameName = "O000";
            case 'P', 'p': frameName = "P000";
            case 'Q', 'q': frameName = "Q000";
            case 'R', 'r': frameName = "R000";
            case 'S', 's': frameName = "S000";
            case 'T', 't': frameName = "T000";
            case 'U', 'u': frameName = "U000";
            case 'V', 'v': frameName = "V000";
            case 'W', 'w': frameName = "W000";
            case 'X', 'x': frameName = "X000";
            case 'Y', 'y': frameName = "Y000";
            case 'Z', 'z': frameName = "Z000";

            // Símbolos adicionais
            case ':': frameName = ":000";
            case ';': frameName = ";000";
            case '=': frameName = "=000";
            case '@': frameName = "@000";

            // Default
            default:
                frameName = c.toUpperCase() + "000";
        }

        if (frameName != null && atlasFrames.exists(frameName + "0")) {
            this.frames = atlasFrames;

            var animFrames:Array<Int> = [];
            var i = 0;
            while (atlasFrames.exists(frameName + i)) {
                var frame = atlasFrames.getByName(frameName + i);
                var frameIndex = atlasFrames.frames.indexOf(frame);
                animFrames.push(frameIndex);
                i++;
            }

            this.animation.add("anim", animFrames, 12, true);
            this.animation.play("anim");

            var firstFrame = atlasFrames.getByName(frameName + "0");
            this.width = firstFrame.frame.width;
            this.height = firstFrame.frame.height;
        } else {
            this.makeGraphic(10, 10, 0x00000000);
        }
    }

    public function setFlipUpsideDown(flip:Bool):Void {
        flipUpsideDown = flip;
        this.set_flipY(flip);
    }

    public function getChar():String {
        return _char;
    }

    public static function createText(text:String, align:Align = Align.Left, flipUpsideDown:Bool = false):AlphabetGroup {
        return new AlphabetGroup(text, align, flipUpsideDown);
    }
}
