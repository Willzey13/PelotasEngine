package objects.gameHud;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxObject;

class HealthIcon extends FlxSprite
{
    public var character:String;
    public var isPlayer:Bool;
    public var baseX:Float = 0;
    public var baseY:Float = 0;

    public function new(char:String = "bf", isPlayer:Bool = false)
    {
        super();

        this.character = char;
        this.isPlayer = isPlayer;

        loadIcon(char);

        setGraphicSize(Std.int(width * 0.9));
        updateHitbox();
        antialiasing = true;
        scrollFactor.set(0, 0);
    }

    public function loadIcon(char:String)
    {
        character = char;
        loadGraphic(Paths.image('icons/icon-' + char), true, 150, 150);

        animation.add("normal", [0]);
        animation.add("losing", [1]);
        animation.play("normal");
    }

    public var curHealth:Float = 0;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (isPlayer)
        {
            if (curHealth < 0.7)
                animation.play("losing");
            else
                animation.play("normal");
        }
        else
        {
            if (curHealth > 1.5)
                animation.play("losing");
            else
                animation.play("normal");
        }

        flipX = isPlayer;
    }
}
