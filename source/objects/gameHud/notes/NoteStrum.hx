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
            frames = Paths.getSparrowAtlas('noteStrumline');
            scale.set(0.7, 0.7);

            switch (direction)
            {
                case 'left':  
                    animation.addByPrefix('static',             'staticLeft', 24, false);
                    animation.addByPrefix('pressed',            'pressLeft', 24, false);
                    animation.addByPrefix('confirm',            'confirmLeft', 24, false);
                    data = 0;

                    if (isSustain)
                        animation.addByPrefix('confirm',        'confirmHoldLeft', 24, false);
                    
                case 'down':  
                    animation.addByPrefix('static',             'staticDown', 24, false);
                    animation.addByPrefix('pressed',            'pressDown', 24, false);
                    animation.addByPrefix('confirm',            'confirmDown', 24, false);
                    data = 1;

                    if (isSustain)
                        animation.addByPrefix('confirm',        'confirmHoldDown', 24, false);

                case 'up':    
                    animation.addByPrefix('static',             'staticUp', 24, false);
                    animation.addByPrefix('pressed',            'pressUp', 24, false);
                    animation.addByPrefix('confirm',            'confirmUp', 24, false);
                    data = 2;

                    if (isSustain)
                        animation.addByPrefix('confirm',        'confirmHoldUp', 24, false);

                case 'right': 
                    animation.addByPrefix('static',             'staticRight', 24, false);
                    animation.addByPrefix('pressed',            'pressRight', 24, false);
                    animation.addByPrefix('confirm',            'confirmRight', 24, false);
                    data = 3;

                    if (isSustain)
                        animation.addByPrefix('confirm',        'confirmHoldRight', 24, false);
            }
		}

        animation.play('static');
    }

    public function playAnim(name:String, ?loop = false)
    {
        animation.play(name, loop);
		centerOffsets();
		centerOrigin();
    }

	override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}
