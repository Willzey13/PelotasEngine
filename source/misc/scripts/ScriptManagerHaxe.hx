package misc.scripts;

import hscript.Parser;
import hscript.Interp;
import sys.io.File;
import sys.FileSystem;
import Reflect;

class ScriptManagerHaxe
{
    public static var interps:Array<Interp> = [];

    // Clear all loaded scripts
    public static function clear() {
        interps = [];
    }

    // Load and execute a script, injecting all fields from PlayState
    public static function load(path:String, context:Dynamic) {
        if (!FileSystem.exists(path)) return;

        var parser = new Parser();
        parser.allowTypes = true;

        var interp = new Interp();

        // If context.playState exists, inject its fields into the script
        if (context != null && Reflect.hasField(context, "playState"))
        {
            var playState = Reflect.field(context, "playState");
            for (field in Reflect.fields(playState))
            {
                var value = Reflect.getProperty(playState, field);
                interp.variables.set(field, value);
            }

            // Also expose the playState object itself
            interp.variables.set("playState", playState);
        }

        var scriptCode = File.getContent(path);
        var expr = parser.parseString(scriptCode);
        interp.execute(expr);

        interps.push(interp); // Store interpreter for future calls
    }

    // Call a function defined in any loaded script, optionally updating context values
    public static function call(funcName:String, context:Dynamic = null) {
        for (interp in interps)
        {
            if (context != null && Reflect.hasField(context, "playState"))
            {
                var playState = Reflect.field(context, "playState");

                // Re-inject updated fields into the interpreter
                for (field in Reflect.fields(playState))
                {
                    var value = Reflect.getProperty(playState, field);
                    interp.variables.set(field, value);
                }

                interp.variables.set("playState", playState);
            }

            if (!interp.variables.exists(funcName)) continue;

            var func = interp.variables.get(funcName);
            if (func != null && Reflect.isFunction(func)) // Pass args if present (like elapsed)
                Reflect.callMethod(null, func, context != null && Reflect.hasField(context, "args") ? context.args : []);
        }
    }
}
