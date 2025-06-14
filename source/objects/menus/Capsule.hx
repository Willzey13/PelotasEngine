package objects.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Json;
import openfl.utils.Assets;

typedef AnimationMeta = {
    var offsets:Array<Float>;
    var loop:Bool;
}

class Capsule extends FlxSprite
{
    var animData:Map<String, AnimationMeta> = new Map();

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

        frames = Paths.getSparrowAtlas("freeplay/freeplayCapsule/capsule/freeplayCapsule");

        animation.addByPrefix('select',     'mp3 capsule w backing',                24, true);
        animation.addByPrefix('NO select',  'mp3 capsule w backing NOT SELECTED',   24, true);

        loadAnimMeta(); // ← carregar offsets
    }

    function loadAnimMeta()
    {
        var path = "assets/images/freeplay/freeplayCapsule/capsule/freeplayCapsuleOffsets.json";
        if (Assets.exists(path)) {
            var raw:String = Assets.getText(path);
            var parsed:Dynamic = Json.parse(raw);

            for (key in Reflect.fields(parsed)) {
                var entry:Dynamic = Reflect.field(parsed, key);
                var meta:AnimationMeta = {
                    offsets: entry.offsets,
                    loop: entry.loop
                };
                animData.set(key, meta);
            }
        } else {
            trace("⚠️ Offsets JSON não encontrado em: " + path);
        }
    }

    public function playAnim(anim:String, ?loop:Bool = false)
    {
        animation.play(anim, loop);
        
        if (animData.exists(anim)) {
            var data = animData.get(anim);
            offset.set(data.offsets[0], data.offsets[1]);
        } else {
            offset.set(0, 0);
        }

        centerOffsets();
        centerOrigin();
    }
}
