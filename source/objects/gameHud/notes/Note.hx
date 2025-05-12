package objects.gameHud.notes;

import data.Conductor;
import flixel.FlxSprite;
import misc.meta.states.PlayState;
import flixel.graphics.frames.FlxAtlasFrames;

class Note extends FlxSprite 
{
    public var time:Float;
    public var direction:String;
    public var isSustain:Bool;
	public var beenHit:Bool = false;
	public var beenMiss:Bool = false;
	public var isPlayer:Bool = false;
	public var strumData:Int = 0;
	public var offsetX:Float = 0;
	public var sustainLength:Float = 0;
	public static var swagWidth:Float = 160 * 0.7;
    
	public function new(x:Float, y:Float, direction:String, time:Float, ?isSustain:Bool = false) 
    {
        super(x, y);
        this.direction = direction;
        this.time = time;
        this.isSustain = isSustain;
		//this.beenHit = false;

        var isNotePixel = PlayState.isPixel;
        if (!isNotePixel)
        {
			if (!isSustain)
            	frames = Paths.getSparrowAtlas('notes');

			scale.set(0.7, 0.7);

            switch (direction)
            {
				case 'left':
					animation.addByPrefix('leftNote', 'noteLeft');
					strumData = 0;
				case 'down':
					animation.addByPrefix('downNote', 'noteDown');
					strumData = 1;
				case 'up':
					animation.addByPrefix('upNote', 'noteUp');
					strumData = 2;
				case 'right':
					animation.addByPrefix('rightNote', 'noteRight');
					strumData = 3;
            }
		}

		if (!isSustain)
			switch (direction)
			{
				case 'left': animation.play('leftNote');
				case 'down': animation.play('downNote');
				case 'up':   animation.play('upNote');
				case 'right':animation.play('rightNote');
			}

		if (isSustain)
		{
			loadGraphic(Paths.image("NOTE_hold_assets")); 
			loadGraphic(Paths.image("NOTE_hold_assets"), true, Math.floor(width / 5 * 0.63), Math.floor(height)); 
		
			// Define animações para as notas sustains
			animation.add('holdLeft', [0]);
			animation.add('holdDown', [2]);
			animation.add('holdUp', [4]);
			animation.add('holdRight', [6]);
		
			// Define animações para o final das sustains (sustain end)
			animation.add('holdEndLeft', [1]);
			animation.add('holdEndDown', [3]);
			animation.add('holdEndUp', [5]);
			animation.add('holdEndRight', [7]);
		
			alpha = 0.6;
			offsetX += (width / 2) + 20;

			switch (strumData)
			{
				case 2:
					animation.play('holdEndUp');
				case 3:
					animation.play('holdEndRight');
				case 1:
					animation.play('holdEndDown');
				case 0:
					animation.play('holdEndLeft');
			}

			updateHitbox();

			offsetX -= (width / 2) - 20;

			if (isSustain)
			{
				switch (strumData)
				{
					case 0: animation.play('holdLeft');
					case 1: animation.play('holdDown');
					case 2: animation.play('holdUp');
					case 3: animation.play('holdRight');
				}

				scale.y *= Conductor.stepCrochet / 100 * 1.3 * PlayState.SONG.speed;
				updateHitbox();
			}
		}
		x += offsetX;
    }

	public function onNoteOffset()
		return time + Conductor.offset - Conductor.songPosition;

	override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}
