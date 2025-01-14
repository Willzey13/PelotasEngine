package objects.gameHud.notes;

import data.Conductor;
import flixel.FlxSprite;
import misc.meta.states.PlayState;

class Note extends FlxSprite 
{
    public var time:Float;
    public var direction:String;
    public var isSustain:Bool;
	public var beenHit:Bool = false;
	public var beenMiss:Bool = false;
	public var wasHit:Bool = false;
	public var isPlayer:Bool = false;
	public var strumData:Int = 0;
	public var mustPress:Bool = false;
	public var sustainLength:Float = 0;
	public var offsetX:Float = 0;
    
	public function new(x:Float, y:Float, direction:String, time:Float, ?isSustain:Bool = false) 
    {
        super(x, y);
        this.direction = direction;
        this.time = time;
        this.isSustain = isSustain;

        var isNotePixel = PlayState.isPixel;
        if (!isNotePixel)
        {
			if (!isSustain)
            	frames = Paths.getSparrowAtlas('notes');

			scale.set(0.7, 0.7);

            switch (direction)
            {
				case 'left':
					animation.addByPrefix('leftNote', 	'yellow instância 1');
					strumData = 0;
				case 'down':
					animation.addByPrefix('downNote', 	'purple instância 1');
					strumData = 1;
				case 'up':
					animation.addByPrefix('upNote', 	'green instância 1');
					strumData = 2;
				case 'right':
					animation.addByPrefix('rightNote', 	'pink instância 1');
					strumData = 3;
            }
		}

        switch (direction)
		{
			case 'left': animation.play('leftNote');
			case 'down': animation.play('downNote');
			case 'up':   animation.play('upNote');
			case 'right':animation.play('rightNote');
		}

		if (isSustain)
		{
			frames = Paths.getSparrowAtlas('holds');

			// Holds 
			animation.addByPrefix('yellowhold', 	'yellow hold piece instância 1');
			animation.addByPrefix('purplehold', 	'purple hold piece instância 1');
			animation.addByPrefix('greenhold', 		'green hold piece instância 1');
			animation.addByPrefix('pinkhold', 		'pink hold piece instância 1');

			// Holds End
			animation.addByPrefix('yellowholdend', 	'yellow end hold instância 1');
			animation.addByPrefix('purpleholdend', 	'purple hold end instância 1');
			animation.addByPrefix('greenholdend', 	'green hold end instância 1');
			animation.addByPrefix('pinkholdend', 	'pink hold end instância 1');

			// noteScore * 0.2;
			alpha = 0.6;
			offsetX += (width / 2) + 20;

			switch (strumData)
			{
				case 2:
					animation.play(isSustain ? 'yellowhold' : 'yellowholdend');
				case 3:
					animation.play(isSustain ? 'purplehold' : 'purpleholdend');
				case 1:
					animation.play(isSustain ? 'greenhold' : 'greenholdend');
				case 0:
					animation.play(isSustain ? 'pinkhold' : 'pinkholdend');
			}

			updateHitbox();

			offsetX -= (width / 2) - 20;

			if (isSustain)
			{
				switch (strumData)
				{
					case 0:
						animation.play('yellowhold');
					case 1:
						animation.play('purplehold');
					case 2:
						animation.play('greenhold');
					case 3:
						animation.play('pinkhold');
				}

				scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
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
