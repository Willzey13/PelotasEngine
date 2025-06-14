package objects;

import data.Conductor;
import flixel.FlxSprite;
import flixel.animation.FlxAnimationController;
import flixel.math.FlxPoint;
import haxe.Json;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

class Character extends FlxSprite
{
    public var animOffsets:Map<String, Array<Float>> = new Map();
    public var holdTimer:Float = 0;
    public var idleAnim:String = "idle";
    public var isOpponent:Bool = false;
    public var specialAnim:Bool = false;
    public var singHoldMultiplier:Float = 4;
    public var curChar:String = 'bf';
    public var cameraPosition:FlxPoint = new FlxPoint(0, 0);
    public var curIcon:String = 'face';

    public function new(x:Float, y:Float, character:String, isOpponent:Bool = false) {
        super(x, y);
        this.isOpponent = isOpponent;
        this.curChar = character;
        loadCharacter(character);
    }

    public function loadCharacter(name:String):Void 
    {
        var modPath:String = 'mods/data/characters/$name.json';
        var assetPath:String = 'assets/data/characters/$name.json';
        var rawJson:String;

        if (FileSystem.exists(modPath)) {
            rawJson = File.getContent(modPath);
        } else if (FileSystem.exists(assetPath)) {
            rawJson = File.getContent(assetPath);
        } else {
            throw 'Arquivo de personagem não encontrado: ' + name;
        }

        var json:Dynamic = Json.parse(rawJson);
        var isVersion1:Bool = Reflect.hasField(json, "version");
        var assetPath:String = isVersion1 ? json.assetPath : json.image;
        frames = Paths.getSparrowAtlas(assetPath);
        var anims:Array<Dynamic> = json.animations;
        var singTime:Float = 4;

        if (Reflect.hasField(json, "flipX")) {
            if (!isOpponent)
                this.flipX != json.flipX;
            else
                this.flipX = json.flipX;
        } else if (Reflect.hasField(json, "flip_x")) {
            if (!isOpponent)
                this.flipX != json.flip_x;
            else
                this.flipX = json.flip_x;
        } else {
            this.flipX = isOpponent;
        }

        if (Reflect.hasField(json, "camera_position") && json.camera_position is Array && (json.camera_position.length >= 2)) {
            var camPos:Array<Float> = json.camera_position;
            cameraPosition.set(camPos[0], camPos[1]);
        } else {
            cameraPosition.set(0, 0);
        }

        if (Reflect.hasField(json, "scale"))
        {
            if(json.scale != 1)
                scale.set(json.scale, json.scale);
            else
                scale.set(1, 1);
        }

        for (anim in anims) {
            var name:String;
            var prefix:String;
            var offsets:Array<Float>;

            if (isVersion1) {
                name = anim.name;
                prefix = anim.prefix;
                offsets = anim.offsets;

                if (Reflect.hasField(json, "singTime"))
                    singTime = json.singTime;

                curIcon = curChar;
            } else {
                name = anim.anim;
                prefix = anim.name;
                offsets = anim.offsets;

                if (Reflect.hasField(json, "sing_duration"))
                    singTime = json.sing_duration;

                if (Reflect.hasField(json, "healthicon"))
                    curIcon = json.healthicon;
                else
                    curIcon = 'face';
            }

            singHoldMultiplier = singTime;
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

    public var isSpectator:Bool = false;
    var danced:Bool = false;

    public function charDance():Void {

        if (isSpectator)
        {
            danced = !danced;

            if (danced)
                playAnim('danceRight');
            else
                playAnim('danceLeft');
        }
        else
            playAnim(idleAnim);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!isSpectator && CoolUtil.startsWith(animation.curAnim.name, 'sing'))
        {
            holdTimer += elapsed;
            if (holdTimer >= Conductor.stepCrochet * (0.0011 / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1)) * singHoldMultiplier)
            {
                charDance();
                holdTimer = 0;
            }
        }
    }
}
