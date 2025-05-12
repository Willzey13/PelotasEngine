package misc;

import flixel.math.FlxMath;

class Timings
{
	public static var sickHitWindow:Int = 45;
    public static var goodHitWindow:Int = 90;
    public static var badHitWindow:Int = 135;
    public static var shitHitWindow:Int = 180;
}

@:structInit
class Judgement {
    public var name:String;
    public var timing:Int;
    public var health:Float;
    public var accuracy:Int;
    public var breakCombo:Bool = false;

    public static var list:Array<Judgement> = [
        new Judgement({name: "sick", timing: Timings.sickHitWindow, accuracy: 100, health: 2.5}),
        new Judgement({name: "good", timing: Timings.goodHitWindow, accuracy: 85, health: 1}),
        new Judgement({name: "bad", timing: Timings.badHitWindow, accuracy: 60, health: -2.5}),
        new Judgement({name: "shit", timing: Timings.shitHitWindow, accuracy: 40, health: -4, breakCombo: true})
    ];
    
    public function new(data:{name:String, timing:Int, health:Float, accuracy:Int, ?breakCombo:Bool}) {
        name = data.name;
        timing = data.timing;
        health = data.health;
        accuracy = data.accuracy;
        if (data.breakCombo != null) {
            breakCombo = data.breakCombo;
        }
    }

    public static function worstTiming():Float
    {
        var max = 0.0;
        for (j in Judgement.list)
        {
            if (j.timing > max)
                max = j.timing;
        }
        return max;
    }
}
