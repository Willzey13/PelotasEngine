package objects;

import misc.meta.states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import data.Section.SwagSection;
import data.Conductor;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public static var DEFAULT_CHARACTER:String = 'breno'; //In case a character is missing, it will use BF on its place
	public function new(x:Float, y:Float, ?character:String = 'breno', ?isPlayer:Bool = false)
    {
        super(x, y);

        animOffsets = new Map();
        curCharacter = character;
        this.isPlayer = isPlayer;

        var characterPath:String = curCharacter;
        var path:String = Paths.getCharacter(characterPath);

        if (!Assets.exists(path))
            path = Paths.getCharacter(DEFAULT_CHARACTER);

        trace('chars: $path');

        var rawJson = Assets.getText(path);
        var json:CharacterFile = cast Json.parse(rawJson);
        var spriteType = "sparrow";

        if (Assets.exists(Paths.getPath('images/' + json.image + '.txt')))
            spriteType = "packer";

        if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json')))
            spriteType = "texture";

        switch (spriteType)
        {
            case "packer":
                //frames = Paths.getPackerAtlas(json.image);
            case "sparrow":
                frames = Paths.getSparrowAtlas(json.image);
            case "texture":
                //frames = AtlasFrameMaker.construct(json.image);
        }

        imageFile = json.image;

        if (json.scale != 1)
        {
            jsonScale = json.scale;
            setGraphicSize(Std.int(width * jsonScale));
            updateHitbox();
        }

        positionArray = json.position;
        cameraPosition = json.camera_position;

        healthIcon = json.healthicon;
        singDuration = json.sing_duration;
        flipX = !!json.flip_x;
        if (json.no_antialiasing)
        {
            antialiasing = false;
            noAntialiasing = true;
        }

        if (json.healthbar_colors != null && json.healthbar_colors.length > 2)
            healthColorArray = json.healthbar_colors;

        antialiasing = !noAntialiasing;
        animationsArray = json.animations;
        if (animationsArray != null && animationsArray.length > 0)
        {
            for (anim in animationsArray)
            {
                var animAnim:String = '' + anim.anim;
                var animName:String = '' + anim.name;
                var animFps:Int = anim.fps;
                var animLoop:Bool = !!anim.loop;
                var animIndices:Array<Int> = anim.indices;
                if (animIndices != null && animIndices.length > 0)
                {
                    animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
                }
                else
                {
                    animation.addByPrefix(animAnim, animName, animFps, animLoop);
                }

                if (anim.offsets != null && anim.offsets.length > 1)
                {
                    addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
                }
            }
        }
        else
            quickAnimAdd('idle', 'BF idle dance');

        originalFlipX = flipX;

        if (animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss'))
            hasMissAnimations = true;

        recalculateDanceIdle();
        dance();

        if (isPlayer)
            flipX = !flipX;
    }

	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;//* PlayState.playbackRate;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			}
            else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * (0.0011 / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1)) * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}
			else
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;
				else
					holdTimer = 0;
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
				playAnim(animation.curAnim.name + '-loop');
		}

		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null)
				playAnim('idle' + idleSuffix);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gabi'))
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle()
    {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];

	public function quickAnimAdd(name:String, anim:String)
		animation.addByPrefix(name, anim, 24, false);
}
