package objects.menus;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

class AlphabetGroup extends FlxTypedGroup<FlxSprite>
{
    public var text:String;
    public var align:Alphabet.Align;
    public var flipUpsideDown:Bool;

    public var x:Float = 0;  // nova propriedade x
    public var y:Float = 0;  // nova propriedade y

    public function new(text:String, align:Alphabet.Align = Alphabet.Align.Left, ?flipUpsideDown:Bool = false) {
        super();

        this.text = text;
        this.align = align;
        this.flipUpsideDown = flipUpsideDown;

        createTextSprites();
    }

    public function setPosition(x:Float, y:Float):Void {
        this.x = x;
        this.y = y;

        // Atualiza a posição dos filhos somando o x/y do grupo
        for (letter in members) {
            if (letter != null) {
                letter.x += x;
                letter.y += y;
            }
        }
    }

    private function createTextSprites():Void
    {
        this.clear();

        var xOffset:Float = 0;

        var chars:Array<Alphabet> = [];

        for (i in 0...text.length) {
            var c = text.charAt(i);
            var letter = new Alphabet(c);
            letter.setFlipUpsideDown(flipUpsideDown);
            chars.push(letter);
        }

        var totalWidth:Float = 0;
        for (l in chars) totalWidth += l.width;

        switch (align) {
            case Alphabet.Align.Left:
                xOffset = 0;
            case Alphabet.Align.Center:
                xOffset = -totalWidth / 2;
            case Alphabet.Align.Right:
                xOffset = -totalWidth;
        }

        for (letter in chars) {
            letter.x = xOffset;
            letter.y = 0;
            xOffset += letter.width;
            add(letter);
        }
    }
}
