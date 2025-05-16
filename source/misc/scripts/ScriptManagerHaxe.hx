package misc.scripts;

import hscript.Parser;
import hscript.Interp;
import sys.io.File;
import sys.FileSystem;

class ScriptManagerHaxe
{
    public static var interps:Array<Interp> = [];
    
    public static function clear() {
        interps = [];
    }

    public static function load(path:String, context:Dynamic) {
        if (!FileSystem.exists(path)) return;

        var parser = new Parser();
        parser.allowTypes = true;

        var interp = new Interp();
        interp.variables.set("boyfriend", context.boyfriend);
        interp.variables.set("dad", context.dad);
        interp.variables.set("SONG", context.SONG);
        interp.variables.set("zoomLevel", context.zoomLevel);
        interp.variables.set("curStep", context.curStep);

        var scriptCode = File.getContent(path);
        var expr = parser.parseString(scriptCode);
        interp.execute(expr);

        interps.push(interp); // Salva o interpreter para chamadas futuras
    }

    public static function call(funcName:String, context:Dynamic = null) {
        for (interp in interps) {
            if (context != null) {
                if (Reflect.hasField(context, "curStep")) interp.variables.set("curStep", context.curStep);
                if (Reflect.hasField(context, "zoomLevel")) interp.variables.set("zoomLevel", context.zoomLevel);
            }

            if (!interp.variables.exists(funcName)) continue;

            var func = interp.variables.get(funcName);
            if (func != null && Reflect.isFunction(func)) {
                Reflect.callMethod(null, func, []);
            }
        }
    }
}
