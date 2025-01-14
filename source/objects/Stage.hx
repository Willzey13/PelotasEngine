package objects;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

class Stage extends FlxGroup
{
    public var foreground:FlxGroup;

    public function new(stageName:String)
    {
        super();

        foreground = new FlxGroup();
        loadStage(stageName);
    }

    private function loadStage(stageName:String):Void
    {
        switch (stageName)
        {
            case "stage":
                var bg = new FlxSprite();
                bg.loadGraphic('assets/stages/stage/images/bg.png');
                add(bg);

            case "cimiterio":
                var bg = new FlxSprite();
                bg.loadGraphic('assets/stages/cimiterio/images/cementerio.png');
                add(bg);

                var fore = new FlxSprite();
                fore.loadGraphic('assets/stages/cimiterio/images/tumolu.png');
                foreground.add(fore);

            case "stage3":

            default:
        }
    }
}
