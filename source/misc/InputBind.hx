package misc;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID as FlxPad;
import flixel.input.FlxInput.FlxInputState;

class InputBind {
    public var keys:Array<FlxKey>;
    public var pads:Array<FlxPad>;

    public function new(keys:Array<FlxKey> = null, pads:Array<FlxPad> = null) {
        this.keys = keys != null ? keys : [];
        this.pads = pads != null ? pads : [];
    }

    public function check(inputState:FlxInputState):Bool {
        for (key in keys) {
            if (key != FlxKey.NONE && FlxG.keys.checkStatus(key, inputState))
                return true;
        }

        if (FlxG.gamepads.lastActive != null) {
            for (pad in pads) {
                if (pad != FlxPad.NONE && FlxG.gamepads.lastActive.checkStatus(pad, inputState))
                    return true;
            }
        }

        return false;
    }
}
