package;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID as FlxPad;
import flixel.input.keyboard.FlxKey;
import misc.InputBind;

class Controls
{
    static var binds:Map<String, InputBind> = new Map();

    public function new() {}

    public function setupDefaults() {
        register("left", new InputBind([FlxKey.LEFT, FlxKey.A], [FlxPad.DPAD_LEFT]));
        register("right", new InputBind([FlxKey.RIGHT, FlxKey.D], [FlxPad.DPAD_RIGHT]));
        register("up", new InputBind([FlxKey.UP, FlxKey.W], [FlxPad.DPAD_UP]));
        register("down", new InputBind([FlxKey.DOWN, FlxKey.S], [FlxPad.DPAD_DOWN]));
        register("accept", new InputBind([FlxKey.ENTER, FlxKey.Z], [FlxPad.X]));
        register("back", new InputBind([FlxKey.BACKSPACE, FlxKey.X], [FlxPad.BACK]));
    }

    public function register(name:String, bind:InputBind):Void
        binds.set(name, bind);

    public function justPressed(name:String):Bool {
        return check(name, FlxInputState.JUST_PRESSED);
    }

    public function pressed(name:String):Bool {
        return check(name, FlxInputState.PRESSED);
    }

    public function justReleased(name:String):Bool {
        return check(name, FlxInputState.JUST_RELEASED);
    }

    private function check(name:String, state:FlxInputState):Bool {
        var bind = binds.get(name);
        if (bind == null) {
            trace('[ControlManager] Bind "$name" não encontrado.');
            return false;
        }
        return bind.check(state);
    }
}
