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
		var skinCovers:String = 'holdCover';
		loadAnims(skin, skinCovers);
		setupNoteSplash(x, y, note);
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, ?isHold:Bool = false, ?texture:String = null, ?textureHolds:String = null) {
		setPosition(x, y);
		alpha = 0.6;
		texture = 'noteSplashes';
		textureHolds = 'holdCover';

		if(textureLoaded != texture)
			loadAnims(texture, textureHolds, isHold);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		animation.play('note-start' + note, true);
		if(animation.curAnim != null)
			animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String, skinHold:String, ?isHold:Bool = false) {
		for (cv in 0...3)
		{
			frames = Paths.getSparrowAtlas('holdCovers/${skinHold}' + cv);
			animation.addByPrefix("note-start0",	"holdCoverStartPurple", 24, false);
			animation.addByPrefix("note-hold0", 	"holdCoverPurple", 		24, false);
			animation.addByPrefix("note-end0", 		"holdCoverEndPurple", 	24, false);

			animation.addByPrefix("note-start1", 	"holdCoverStartBlue", 	24, false);
			animation.addByPrefix("note-hold1", 	"holdCoverBlue", 		24, false);
			animation.addByPrefix("note-end1", 		"holdCoverEndBlue", 	24, false);

			animation.addByPrefix("note-start2", 	"holdCoverStartGreen", 	24, false);
			animation.addByPrefix("note-hold2", 	"holdCoverGreen", 		24, false);
			animation.addByPrefix("note-end2", 		"holdCoverEndGreen", 	24, false);

			animation.addByPrefix("note-start3", 	"holdCoverStartRed", 	24, false);
			animation.addByPrefix("note-hold3", 	"holdCoverRed", 		24, false);
			animation.addByPrefix("note-end3", 		"holdCoverEndRed", 	24, false);
		}

		frames = Paths.getSparrowAtlas(skin);
        animation.addByPrefix("note0-1", "note impact 1 purple", 24, false);
		animation.addByPrefix("note0-2", "note impact 2 purple", 24, false);

		animation.addByPrefix("note1-1", "note impact 1 blue", 24, false);
		animation.addByPrefix("note1-2", "note impact 2 blue", 24, false);

		animation.addByPrefix("note2-1", "note impact 1 green", 24, false);
		animation.addByPrefix("note2-2", "note impact 2 green", 24, false);

		animation.addByPrefix("note3-1", "note impact 1 red", 24, false);
		animation.addByPrefix("note3-2", "note impact 2 red", 24, false); 
	}

	override function update(elapsed:Float) {
		if(animation.curAnim.finished) alpha = 0.0001;

		super.update(elapsed);
	}

	public function playSplash(x:Float, y:Float, ?note:Int = 0)
	{
		alpha = 1;
		setPosition(x, y);
		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		centerOffsets();
		centerOrigin();
	}
}