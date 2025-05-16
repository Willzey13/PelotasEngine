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
	public var isHoldEnd:Bool;
	public var beenHit:Bool = false;
	public var beenMiss:Bool = false;
	public var isPlayer:Bool = false;
	public var strumData:Int = 0;
	public var offsetX:Float = 0;
	public var sustainLength:Float = 0;
	public var type:String = "";
	public var beenAccurately:Bool = false;
	public var areHolding:Bool = false;
	public static var swagWidth:Float = 160 * 0.7;
    
	public function new(x:Float, y:Float, direction:String, time:Float, ?isSustain:Bool = false, ?isHoldEnd:Bool = false)
    {
        super(x, y);
        this.direction = direction;
        this.time = time;
        this.isSustain = isSustain;
		this.isHoldEnd = isHoldEnd;
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
		
			animation.add('holdLeft', [0]);
			animation.add('holdDown', [2]);
			animation.add('holdUp', [4]);
			animation.add('holdRight', [6]);
		
			animation.add('holdEndLeft', [1]);
			animation.add('holdEndDown', [3]);
			animation.add('holdEndUp', [5]);
			animation.add('holdEndRight', [7]);
		
			// alpha = 0.6; opcional
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
					case 0: animation.play(isHoldEnd ? 'holdEndLeft' : 'holdLeft');
					case 1: animation.play(isHoldEnd ? 'holdEndDown' : 'holdDown');
					case 2: animation.play(isHoldEnd ? 'holdEndUp' : 'holdUp');
					case 3: animation.play(isHoldEnd ? 'holdEndRight' : 'holdRight');
				}

				scale.y *= Conductor.stepCrochet / 100 * 0.75 * PlayState.SONG.speed;
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
