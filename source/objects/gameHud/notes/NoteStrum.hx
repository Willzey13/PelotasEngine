package objects.gameHud.notes;

import data.Conductor;
import flixel.FlxSprite;
import misc.meta.states.PlayState;

class NoteStrum extends FlxSprite 
{
    public var direction:String;
    public var isDownscroll:Bool = false;
    public var isMiddlescroll:Bool = false;
    public var botplay:Bool = false;
    public var data:Int = 0;
    
	public function new(x:Float, y:Float, direction:String = '', ?isSustain:Bool = false, ?isDownscroll:Bool = false, ?isMiddlescroll:Bool = false) 
    {
        super(x, y);
        this.direction = direction;
        this.isMiddlescroll = isMiddlescroll;
        this.isDownscroll = isDownscroll;

        var isStrumPixel = PlayState.isPixel;
        if (!isStrumPixel)
        {
            frames = Paths.getSparrowAtlas('strum');
            scale.set(0.7, 0.7);

            switch (direction)
            {
                case 'left':  
                    animation.addByPrefix('static',             'arrow static instância 4', 24, false);
                    animation.addByPrefix('pressed',            'left press instância 1', 24, false);
                    animation.addByPrefix('confirm',            'left confirm instância 1', 24, false);
                    data = 0;
                    
                case 'down':  
                    animation.addByPrefix('static',             'arrow static instância 3', 24, false);
                    animation.addByPrefix('pressed',            'down press instância 1', 24, false);
                    animation.addByPrefix('confirm',            'down confirm instância 1', 24, false);
                    data = 1;

                case 'up':    
                    animation.addByPrefix('static',             'arrow static instância 2', 24, false);
                    animation.addByPrefix('pressed',            'up press instância 1', 24, false);
                    animation.addByPrefix('confirm',            'up confirm instância 1', 24, false);
                    data = 2;

                case 'right': 
                    animation.addByPrefix('static',             'arrow static instância 1', 24, false);
                    animation.addByPrefix('pressed',            'right press instância 1', 24, false);
                    animation.addByPrefix('confirm',            'right confirm instância 1', 24, false);
                    data = 3;
            }
		}

        playAnim('static');
    }

    public function playAnim(name:String, ?loop = false)
    {
        animation.play(name, loop);
        if (["pressed", "static"].contains(animation.curAnim.name))
            onOffsets();
        else if (["confirm"].contains(animation.curAnim.name))
        {
            switch (data)
            {
                case 0:
                    onOffsets(0.48, 0.5);
                case 1:
                    onOffsets(0.46, 0.5);
                case 2:
                    onOffsets(0.44, 0.5);
                case 3:
                    onOffsets(0.42, 0.5);
            }
        }

		centerOrigin();
    }

	override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    public function onOffsets(tamanhoX:Float = 0.5, tamanhoY:Float = 0.5):Void
    {
        offset.x = (frameWidth - width) * tamanhoX;
        offset.y = (frameHeight - height) * tamanhoY;
    }
}
