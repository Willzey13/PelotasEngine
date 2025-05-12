package objects.gameHud.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		var skin:String = 'noteSplashes';
		skin = 'noteSplashes';
		loadAnims(skin);
		setupNoteSplash(x, y, note);
	}

	public function setupNoteSplash(x:Float, y:Float, strum:Int = 0, ?note:Note, ?texture:String = null) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
	
		offset.set(10, 10);
		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + strum + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String)
	{
		frames = Paths.getSparrowAtlas('noteSplashes');
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note impact " + i + "  blue", 24, false);
			animation.addByPrefix("note2-" + i, "note impact " + i + " green", 24, false);
			animation.addByPrefix("note0-" + i, "note impact " + i + " purple", 24, false);
			animation.addByPrefix("note3-" + i, "note impact " + i + " red", 24, false);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}