package misc;

import misc.CustomFadeTransition;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

class CoolUtil
{
    public static function switchState(nextState:FlxState) {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
        {
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		CoolUtil.switchState(FlxG.state);
	}

	// -------- StringTools reimplementado --------

    public static function trim(str:String):String {
        return ~/^\s+|\s+$/g.replace(str, "");
    }

    public static function replace(str:String, sub:String, by:String):String {
        return str.split(sub).join(by);
    }

    public static function startsWith(str:String, prefix:String):Bool {
        return str.indexOf(prefix) == 0;
    }

    public static function endsWith(str:String, suffix:String):Bool {
        return str.length >= suffix.length && str.substr(str.length - suffix.length) == suffix;
    }

    public static function contains(str:String, needle:String):Bool {
        return str.indexOf(needle) != -1;
    }

    public static function toLowerCase(str:String):String {
        return str.toLowerCase();
    }

    public static function toUpperCase(str:String):String {
        return str.toUpperCase();
    }
}