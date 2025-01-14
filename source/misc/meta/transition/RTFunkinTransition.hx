package misc.meta.transition;

import data.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class RTFunkinTransition extends MusicBeatSubstate
{
    public static var finishCallback:Void->Void;
    private var leTween:FlxTween = null;
    public static var nextCamera:FlxCamera;
    var isTransIn:Bool = false;
    var transBlack:FlxSprite;

    public function new(duration:Float, isTransIn:Bool)
    {
        super();

        this.isTransIn = isTransIn;
        var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
        var width:Int = Std.int(FlxG.width / zoom);
        var height:Int = Std.int(FlxG.height / zoom);

        transBlack = new FlxSprite().makeGraphic(width, height + 400, FlxColor.BLACK);
        transBlack.scrollFactor.set();
        add(transBlack);

        transBlack.y -= (height - FlxG.height) / 2;

        // Usando o easing suave 'sineInOut' para a transição
        var easingType = FlxEase.sineInOut;

        if (isTransIn)
        {
            transBlack.x = 0;
            leTween = FlxTween.tween(transBlack, {x: width}, duration, {
                onComplete: function(twn:FlxTween)
                {
                    close();
                },
                ease: easingType
            });
        }
        else
        {
            transBlack.x = 0;
            FlxTween.tween(transBlack, {x: -width}, duration, {
                onComplete: function(twn:FlxTween)
                {
                    if(finishCallback != null) {
						finishCallback();
					}
                },
                ease: easingType
            });
        }

        if (nextCamera != null)
            transBlack.cameras = [nextCamera];

        nextCamera = null;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    override function destroy()
    {
        if (leTween != null)
        {
            leTween.cancel();
            leTween = null;
        }
    
        if (finishCallback != null)
        {
            finishCallback();
            finishCallback = null; // Evita chamadas duplicadas
        }
    
        super.destroy();
    }
}
