package misc.meta.states;

import sys.net.*;
import data.Conductor;
import data.Section.SwagSection;
import data.Song.SwagSong;
import data.Song;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import objects.gameHud.notes.Note;
import objects.gameHud.notes.NoteStrum;
import misc.Timings;
import misc.Timings.Judgement;

class PlayState extends MusicBeatState
{
	public static var SONG:SwagSong;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var defaultCamZoom:Float = 1.05;
	public var generatedMusic:Bool = false;
	public var camZooming:Bool = false;

	public var instrumental:FlxSound;
	public var vocals:FlxSound;

	public var playerStrumline:FlxTypedGroup<NoteStrum>;
	public var opponentStrumline:FlxTypedGroup<NoteStrum>;
	public var notes:FlxGroup;

    public static var isPixel:Bool = false;
	private var score:Int = 0;
	private var accuracy:Float = 100.0;
	private var scoreText:FlxText;
	private var accuracyText:FlxText;

	override public function create():Void
    {
        super.create();
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		SONG = Song.loadFromJson('bopeebo', 'bopeebo');

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
		add(bg);

		playerStrumline = new FlxTypedGroup<NoteStrum>();
		playerStrumline.camera = camHUD;
		var directions = ["left", "down", "up", "right"];
		for (i in 0...4)
		{
			var direction = directions[i];
			var strum = new NoteStrum(FlxG.width / 2 + 100 + i * 108, -10, direction);
			playerStrumline.add(strum);
		}
		add(playerStrumline);

		opponentStrumline = new FlxTypedGroup<NoteStrum>();
		opponentStrumline.camera = camHUD;
		for (i in 0...4)
		{
			var direction = directions[i];
			var strum = new NoteStrum(FlxG.width / 2 - 650 + i * 108, -10, direction);
			opponentStrumline.add(strum);
		}
		add(opponentStrumline);

		notes = new FlxGroup();
		notes.camera = camHUD;
        add(notes);
		scoreText = new FlxText(10, 10, 200, "Score: 0");
		accuracyText = new FlxText(10, 30, 200, "Accuracy: 100%");
		add(scoreText);
		add(accuracyText);

		generateSong();
    }

	public function generateSong()
	{
		generatedMusic = true;
		camZooming = true;
		var songData = SONG;
		var noteData:Array<SwagSection>;
		Conductor.changeBPM(songData.bpm);
		noteData = songData.notes;
		FlxG.sound.playMusic("assets/songs/" + songData.song.toLowerCase() + "/Inst.ogg", 1, false);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded("assets/songs/" + songData.song.toLowerCase() + "/Voices.ogg");
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		vocals.play();

		var playerCounter:Int = 0;
		var daBeats:Int = 0;

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNote:Int = songNotes[1];
				var directions = ["left", "down", "up", "right"];
				var positionsPlayer = [0, 1, 2, 3];
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var noteX:Float;
				var direction:String;

				if (!gottaHitNote)
				{
					noteX = FlxG.width / 2 - 610 + daNoteData * 108;
					direction = directions[daNoteData];
				}
				else
				{
					noteX = FlxG.width / 2 + 140 + daNoteData * 108;
					direction = directions[daNoteData];
				}

				var swagNote:Note = new Note(noteX - 3, FlxG.height + 50, direction, daStrumTime);
				swagNote.scrollFactor.set(0, 0);
				swagNote.sustainLength = songNotes[2];
				swagNote.isPlayer = gottaHitNote;

				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;
				for (susNote in 0...Math.floor(susLength))
				{
					var sustainNote:Note = new Note(noteX + 57.7, FlxG.height + 50, direction, daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, true);
					sustainNote.isPlayer = gottaHitNote;
					sustainNote.scrollFactor.set();
					notes.add(sustainNote);
				}
				notes.add(swagNote);
			}
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var pressed:Array<Bool> 		= [];
	public var justPressed:Array<Bool> 	= [];
	public var released:Array<Bool> 	= [];
	public var ghostTapping:Bool = false;
	public static var defaultStageZoom:Float = 1.03;
	var perdidos:Int = 0;

    override public function update(elapsed:Float):Void
    {
		super.update(elapsed);

		if (camZooming)
		{
			if (camGame != null && camGame.zoom > 1)
				camGame.zoom = FlxMath.lerp(camGame.zoom, 1, elapsed * 6);
		
			if (camHUD != null && camHUD.zoom > 1)
				camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, elapsed * 6);
		}

		if (FlxG.keys.justPressed.SPACE)
			paused = !paused;

		pressed = [
			FlxG.keys.pressed.Z,
			FlxG.keys.pressed.X,
			FlxG.keys.pressed.UP,
			FlxG.keys.pressed.RIGHT,
		];
		justPressed = [
			FlxG.keys.justPressed.Z,
			FlxG.keys.justPressed.X,
			FlxG.keys.justPressed.UP,
			FlxG.keys.justPressed.RIGHT,
		];
		released = [
			FlxG.keys.justReleased.Z,
			FlxG.keys.justReleased.X,
			FlxG.keys.justReleased.UP,
			FlxG.keys.justReleased.RIGHT,
		];

		for (strum in playerStrumline.members)
		{
			if(pressed[strum.data])
			{
				if(!["pressed", "confirm"].contains(strum.animation.curAnim.name))
					strum.playAnim("pressed");
			}
			else
				strum.playAnim("static");
		}

		for (note in notes.members)
		{
			if (note != null && note is Note)
			{
				var customNote = cast(note, Note);
				customNote.y = Conductor.offset - (Conductor.songPosition - customNote.time) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2));
				
				if (customNote.isPlayer)
				{
					if (justPressed[customNote.strumData])
					{
						var possibleNotes:Array<Note> = [];
						for (daNote in notes)
						{
							var noteCheck:Note = cast daNote;
							if (noteCheck != null && noteCheck.isPlayer && noteCheck.strumData == customNote.strumData)
							{
								for (judge in Judgement.list)
								{
									if (Math.abs(noteCheck.time - Conductor.songPosition) < judge.timing)
										possibleNotes.push(noteCheck);
								}
							}
						}
				
						possibleNotes.sort((a, b) -> Std.int(Math.abs(a.time - Conductor.songPosition) - Math.abs(b.time - Conductor.songPosition)));

						if (possibleNotes.length > 0)
						{
							var noteToHit = possibleNotes[0];
							onGoodHitNote(noteToHit);
						}
					}
				}

				if (pressed.contains(true) && customNote.isPlayer && customNote.isSustain)
				{
					var sustainNotes: Array<Note> = [];
		
					for (i in 0...pressed.length)
					{
						if (pressed[i] && customNote.strumData == i)
						{
							if (!customNote.beenHit && !customNote.beenMiss && customNote.isSustain &&
								Math.abs(Conductor.songPosition - customNote.time) < 135) {
									sustainNotes.push(customNote);
							}
						}
					}
		
					sustainNotes.sort((a, b) -> Std.int(a.time - b.time));
		
					if (sustainNotes.length > 0)
					{
						var sustainToHit = sustainNotes[0];
						var center:Float = playerStrumline.members[customNote.strumData].y + Note.swagWidth / 2 + 58;
						if (sustainToHit.y + sustainToHit.offset.y * sustainToHit.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, sustainToHit.width / sustainToHit.scale.x, sustainToHit.height / sustainToHit.scale.y);
							swagRect.y = (center - sustainToHit.y) / sustainToHit.scale.y;
							swagRect.height -= swagRect.y;

							sustainToHit.clipRect = swagRect;
						}
					}
				}
				
				if (customNote.y >= 50 && customNote.y <= 100)
				{
					if (!customNote.isPlayer)
						onGoodHitNote(customNote);
				}

				if (customNote.isPlayer && !customNote.isSustain && !customNote.beenHit && !customNote.beenMiss && customNote.y < playerStrumline.members[customNote.strumData].y)
					if (Conductor.songPosition - customNote.time > Judgement.worstTiming())
						onMissNote(customNote);
					
			}
		}

		if (startingSong)
		{
			if (startedCountdown)
				Conductor.songPosition += FlxG.elapsed * 1000;
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			if (!paused)
				if (Conductor.lastSongPos != Conductor.songPosition)
					Conductor.lastSongPos = Conductor.songPosition;
		}

		scoreText.text = "Score: " + score;
		accuracyText.text = "Accuracy: " + Std.int(accuracy) + "%";
	}

	public var paused:Bool = false;
	public var startedCountdown:Bool = true;
	public var startingSong:Bool = true;
	var zoomLevel:Float = 1.0;

	override function beatHit()
	{
		super.beatHit();

		if (camZooming && camHUD.zoom < 1.35 && curBeat % 4 == 0)
		{
			if (camGame != null)
				camGame.zoom += 0.03;
	
			if (camHUD != null)
				camHUD.zoom += 0.03;
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (SONG.needsVoices)
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
				resyncVocals();
	}

	function onMissNote(note:Note)
	{	
		if (note.beenMiss) return;
		vocals.volume = 0;
		note.beenMiss = true;
		notes.remove(note, true);
		accuracy -= 2;
		if (accuracy < 0) accuracy = 0;
		score -= 10;
		if (score < 0) score = 0;

		perdidos -= 1;
		trace('QUANTOS FORAM PERDIDOS: ' + perdidos);

		scoreText.text = "Score: " + score;
		accuracyText.text = "Accuracy: " + Std.int(accuracy) + "%";
	}

	public function onGoodHitNote(note:Note)
	{
		if (note.beenMiss) return;
		note.beenHit = true;
		vocals.volume = 1;
		var strum = playerStrumline.members[note.strumData];
		var opponentStrum = opponentStrumline.members[note.strumData];

		if (!note.isPlayer)
		{
			if (opponentStrum != null)
			{
				if (note.isSustain)
					opponentStrum.playAnim('confirm', true);
				
				opponentStrum.playAnim('confirm', true);
				opponentStrum.animation.finishCallback = function(name:String)
				{
					opponentStrum.playAnim('static', true);
				};
			}
			note.kill();
		}
		else if (note.isPlayer)
		{
			score += 100;
			updateAccuracy(true);

			if (strum != null)
				strum.playAnim('confirm', true);

			note.kill();
		}
	}	

	private function updateAccuracy(hit:Bool):Void
		accuracy = hit ? (accuracy * 0.9) + 100 * 0.1 : accuracy * 0.9;
}
