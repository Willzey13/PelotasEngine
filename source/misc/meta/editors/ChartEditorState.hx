package misc.meta.editors;

import flixel.FlxG;
import objects.menus.*;

class ChartEditorState extends MusicBeatState
{
    override public function create():Void
    {
      // Teste foda de texto mano ta muito gay isso aqui KKKKKKKKKKKKKK
        var alphabetGroup = new AlphabetGroup("GOZEEEEEEEEU", Alphabet.Align.Center);
        alphabetGroup.setPosition(FlxG.width / 2, FlxG.height / 2);
        add(alphabetGroup);

        super.create();
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}
