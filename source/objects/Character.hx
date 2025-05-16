package objects;

import data.Conductor;
import flixel.FlxSprite;
import haxe.Json;
import openfl.utils.Assets;
import flixel.animation.FlxAnimationController;

class Character extends FlxSprite
{
    public var animOffsets:Map<String, Array<Float>> = new Map();
    public var holdTimer:Float = 0;
    public var idleAnim:String = "idle";
    public var isOpponent:Bool = false;
    public var specialAnim:Bool = false;

    public function new(x:Float, y:Float, character:String, isOpponent:Bool = false) {
        super(x, y);
        this.isOpponent = isOpponent;
        loadCharacter(character);
    }

    public function loadCharacter(name:String):Void 
    {
        var path:String = 'assets/data/characters/$name.json';
        var rawJson:String = sys.io.File.getContent(path);
        var json:Dynamic = Json.parse(rawJson);

        var isVersion1:Bool = Reflect.hasField(json, "version");
        var assetPath:String = isVersion1 ? json.assetPath : json.image;
        frames = Paths.getSparrowAtlas(assetPath);
        var anims:Array<Dynamic> = json.animations;

        // <- AQUI ENTRA O FLIPX
        if (Reflect.hasField(json, "flipX")) {
            this.flipX = json.flipX;
        } else if (Reflect.hasField(json, "flip_x")) {
            this.flipX = json.flip_x;
        } else {
            this.flipX = isOpponent;
        }

        for (anim in anims) {
            var name:String;
            var prefix:String;
            var offsets:Array<Float>;

            if (isVersion1) {
                name = anim.name;
                prefix = anim.prefix;
                offsets = anim.offsets;
            } else {
                name = anim.anim;
                prefix = anim.name;
                offsets = anim.offsets;
            }

            var loop:Bool = isVersion1 ? false : (anim.loop == true);
            animation.addByPrefix(name, prefix, isVersion1 ? 24 : anim.fps, loop);
            animOffsets.set(name, offsets);
        }

        charDance();
    }

    public function playAnim(name:String, forced:Bool = false):Void {
        animation.play(name, forced);
        if (animOffsets.exists(name)) {
            var offsets = animOffsets.get(name);
            offset.set(offsets[0], offsets[1]);
        }

        if (name != idleAnim) {
            holdTimer = 0;
        }
    }

    public function charDance():Void {
        playAnim(idleAnim);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (CoolUtil.startsWith(animation.curAnim.name, 'sing'))
        {
            holdTimer += elapsed;
            if (holdTimer >= Conductor.stepCrochet * (0.0011 / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1)) * 4) // depois de 4 steps
            {
                charDance();
                holdTimer = 0;
            }
        }
    }
}
