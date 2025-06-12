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
    public var width:Float = 0; // sou pelado
    public var alpha:Float = 1; // alpha
    public var scaleX:Float = 1; public var scaleY:Float = 1; // scales
    public var scrollFactorX:Float = 1; public var scrollFactorY:Float = 1; // scroll

    var chars:Array<Alphabet> = []; // nao mude isso manualmente

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

        // trace(x+'   '+y+'   '+width);

        // Atualiza a posição dos filhos somando o x/y do grupo
        for (letter in members) {
            if (letter != null) {
                letter.x += x;
                letter.y = y;
            }
        }
    }
    public function setY(y:Float):Void {
        this.y = y;

        for (letter in members) {
            if (letter != null)
                letter.y = y;
        }
    }
    public function setX(x:Float):Void {
        this.x = x;

        for (letter in members) {
            if (letter != null)
                letter.x += x;
        }
    }

    public function setScale(sx:Float, sy:Float)
    {
        scaleX = sx;
        scaleY = sy;

        // fix letter offsets (meu pau ta sdfnmsidgosnognosdgnsngd)
        for (letter in members) {
            if (letter != null) {
                letter.scale.set(sx, sy);
                //letter.x = (-(length*scaleX)/2)+letter.width;
            }
        }
    }

    public function setAlpha(newAlpha)
    {
        for(curChar in members)
            curChar.alpha = newAlpha;

        alpha = newAlpha;
    }

    public function scrollFactorSet(x:Float, y:Float)
    {
        scrollFactorX = x;
        scrollFactorY = y;

        for (letter in members) {
            if (letter != null)
                letter.scrollFactor.set(x, y);
        }
    }

    // literal copia do new
    public function deleteText(text:String, align:Alphabet.Align = Alphabet.Align.Left, ?flipUpsideDown:Bool = false)
    {
        this.text = text;
        this.align = align;
        this.flipUpsideDown = flipUpsideDown;

        createTextSprites();
    }

    private function createTextSprites():Void
    {
        this.clear();

        var xOffset:Float = 0;
        chars = [];

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

        width = totalWidth;
    }
}
