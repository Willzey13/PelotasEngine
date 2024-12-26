package objects.gameHud.notes;

import data.Conductor;
import flixel.FlxSprite;
import misc.meta.states.PlayState;

class Note extends FlxSprite 
{
    public var time:Float;
    public var direction:String;
    public var isSustain:Bool;
    public var hit:Bool;
    
    public function new(x:Float, y:Float, direction:String, time:Float, isSustain:Bool = false) 
    {
        super(x, y);
        this.direction = direction;
        this.time = time;
        this.isSustain = isSustain;
        this.hit = false;

        var isNotePixel = PlayState.isPixel;
        if (!isNotePixel)
        {
            frames = Paths.getSparrowAtlas('notes');

            switch (direction)
            {
                case 'left':  animation.addByPrefix('leftNote',          'noteLeft');
                case 'down':  animation.addByPrefix('downNote',          'noteDown');
                case 'up':    animation.addByPrefix('upNote',            'noteUp');
                case 'right': animation.addByPrefix('rightNote',         'noteRight');
            }
		}

        switch (direction)
		{
			case 'left': animation.play('leftNote');
			case 'down': animation.play('downNote');
			case 'up':   animation.play('upNote');
			case 'right':animation.play('rightNote');
		}
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}
