package misc;

import flixel.math.FlxMath;

typedef TimingValues = {
	var sick:Int;
	var good:Int;
	var bad:Int;
	var shit:Int;
}

final Timings:TimingValues = {
	sick: 45,
	good: 90,
	bad: 135,
	shit: 180
};

@:structInit
class Judgement {
    public var name:String;
    public var timing:Int;
    public var health:Float;
    public var accuracy:Int;
    public var score:Int = 350;
    public var breakCombo:Bool = false;

    // SUSTAIN NOTES
    var maxTiming = Timings.shit; // 180
    public static final SICK_THRESHOLD:Float = Timings.sick / Timings.shit;
    public static final GOOD_THRESHOLD:Float = Timings.good / Timings.shit;
    public static final BAD_THRESHOLD:Float = Timings.bad / Timings.shit;
    public static final SHIT_THRESHOLD:Float = 1.0;
    
    public static var list:Array<Judgement> = [
        new Judgement({name: "sick", timing: Timings.sick, accuracy: 100, health: 2.5, score: 350}),
        new Judgement({name: "good", timing: Timings.good, accuracy: 85, health: 1, score: 200}),
        new Judgement({name: "bad", timing: Timings.bad, accuracy: 60, health: -2.5, score: 100}),
        new Judgement({name: "shit", timing: Timings.shit, accuracy: 40, health: -4, breakCombo: true, score: 50})
    ];
    
    public function new(data:{name:String, timing:Int, health:Float, accuracy:Int, ?score:Int, ?breakCombo:Bool}) {
        name = data.name;
        timing = data.timing;
        health = data.health;
        score = data.score;
        accuracy = data.accuracy;
        if (data.breakCombo != null) {
            breakCombo = data.breakCombo;
        }
    }

    public static function getScoreByTiming(timing:Float):Int { // get score - meu pinto caiu
		var judgement = getJudgement(timing);
		return (judgement != null) ? judgement.score : 0;
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

    public static function getJudgementByTiming(timing:Float):String {
        for (j in list) {
            if (timing <= j.timing) {
                return j.name;
            }
        }
        return "miss";
    }

    public static function getJudgement(timing:Float):Judgement {
        for (j in list) {
            if (timing <= j.timing) {
                return j;
            }
        }
        return null;
    }
}
