package misc.meta.states;

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
import misc.scripts.ScriptManagerHaxe;
import misc.Timings.Judgement;
import misc.Timings;
import objects.Character;
import objects.gameHud.notes.Note;
import objects.gameHud.notes.NoteStrum;
import sys.FileSystem;

class PlayState extends MusicBeatState
{
	public static var SONG:SwagSong;
	public static var diff:String = "normal";
	public static var isFreeplay:Bool = false;
	public static var isBotplay:Bool = false; // Cheat game

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var defaultCamZoom:Float = 1.05;
	public var generatedMusic:Bool = false;
	public var camZooming:Bool = false;

	public var instrumental:FlxSound;
	public var vocals:FlxSound;

	public var boyfriend:Character;
	public var dad:Character;

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

		if (SONG == null)
			SONG = Song.loadFromJson('stress-pico', 'stress-pico');

		ScriptManagerHaxe.clear();

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
		add(bg);

		dad = new Character(200, 100, SONG.player2, true);
		add(dad);

		boyfriend = new Character(600, 100, SONG.player1, false);
		add(boyfriend);

		if (CoolUtil.toLowerCase(SONG.song) == 'stress-pico')
			boyfriend.loadCharacter('pico-holding-nene');

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

		generateSong();
		Conductor.songPosition = -Conductor.crochet * 5;

		scoreText = new FlxText(10, 10, 200, "Score: 0");
		accuracyText = new FlxText(10, 30, 200, "Accuracy: 100%");
		add(scoreText);
		add(accuracyText);

		reloadScripts();
    	ScriptManagerHaxe.call("create");

		startingSong = true;

		if (!haveCutscene)
		{
			switch (CoolUtil.toLowerCase(SONG.song))
			{
				default:
					startCountdown();
			}
		}	
    }

	public var haveCutscene:Bool = false;

	public function generateSong()
	{
		generatedMusic = true;
		camZooming = true;
		var songData = SONG;
		var noteData:Array<SwagSection>;
		Conductor.changeBPM(songData.bpm);
		noteData = songData.notes;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded("assets/songs/" + songData.song.toLowerCase() + "/Voices.ogg");
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(new FlxSound().loadEmbedded("assets/songs/" + CoolUtil.toLowerCase(songData.song) + "/Inst.ogg"));
		FlxG.sound.list.add(vocals);

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
				var totalSustains = Math.floor(susLength);
				for (susNote in 0...totalSustains)
				{
					var isEnd = susNote == totalSustains - 1;
					var sustainNote = new Note(
						noteX + 57.7,
						FlxG.height + 50,
						direction,
						daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet,
						true,
						isEnd
					);
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

	public function startCountdown()
	{
		var daCount:Int = 0;
		var countTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			Conductor.songPosition = -Conductor.crochet * (4 - daCount);

			if(daCount == 0)
			{
				startedCountdown = true;
				for(strums in playerStrumline.members)
				{
					var strumMult:Int = 3;
					FlxTween.tween(strums, {alpha: 1}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						startDelay: Conductor.crochet / 2 / 1000 * strumMult,
					});
				}
				for(strums in opponentStrumline.members)
				{
					var strumMult:Int = 3;
					FlxTween.tween(strums, {alpha: 1}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						startDelay: Conductor.crochet / 2 / 1000 * strumMult,
					});
				}
			}
			
			if(daCount == 0)
				startedCountdown = true;

			if(daCount == 4)
				startSong();

			if(daCount != 4)
			{
				var soundName:String = ["3", "2", "1", "Go"][daCount];	
				FlxG.sound.play(Paths.sound('intro-$soundName'));
				
				if(daCount >= 1)
				{
					var countName:String = ["ready", "set", "go"][daCount - 1];
					var styleCount:String = "funkin"; // funkin Countdown Default UI

					if (isPixel) styleCount = "pixel";

					var countSprite = new FlxSprite();
					countSprite.loadGraphic(Paths.image('$styleCount/$countName'));
					countSprite.updateHitbox();
					countSprite.screenCenter();
					countSprite.cameras = [camHUD];
					add(countSprite);

					FlxTween.tween(countSprite, {alpha: 0}, Conductor.stepCrochet * 2.8 / 1000, {
						startDelay: Conductor.stepCrochet * 1 / 1000,
						onComplete: function(twn:FlxTween)
						{
							countSprite.destroy();
						}
					});
				}
			}

			daCount++;
		}, 5);
	}

	function reloadScripts()
	{

		var scriptsPath = "assets/scripts/";
		var scripts = FileSystem.readDirectory(scriptsPath);

		for (script in scripts)
		{
			if (StringTools.endsWith(script, ".hx"))
			{
				var fullPath = scriptsPath + script;
				trace("Loading script: " + fullPath);

				ScriptManagerHaxe.load(fullPath, {
					boyfriend: boyfriend,
					dad: dad,
					SONG: SONG
				});
			}
		}
	}

	function startSong():Void
	{
		startingSong = false;

		if (!paused)
			FlxG.sound.playMusic("assets/songs/" + CoolUtil.toLowerCase(SONG.song) + "/Inst.ogg", 1, false);
		
		vocals.play();
	}

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
	public var isChartingMode:Bool = false;
	var perdidos:Int = 0;

    override public function update(elapsed:Float):Void
    {
		super.update(elapsed);

		if (FlxG.keys.justPressed.B && (isFreeplay || isChartingMode))
            isBotplay = !isBotplay;

		if (controls.justPressed('back'))
			CoolUtil.switchState(new FreeplayState());

		ScriptManagerHaxe.call("update", {
			curStep: curStep,
			zoomLevel: zoomLevel,
			boyfriend: boyfriend,
			dad: dad
		});

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
			controls.pressed("left"),
			controls.pressed("down"),
			controls.pressed("up"),
			controls.pressed("right"),
		];
		justPressed = [
			controls.justPressed("left"),
			controls.justPressed("down"),
			controls.justPressed("up"),
			controls.justPressed("right"),
		];
		released = [
			controls.justReleased("left"),
			controls.justReleased("down"),
			controls.justReleased("up"),
			controls.justReleased("right"),
		];

		for (strum in playerStrumline.members)
		{
			if (isBotplay)
			{
				for (note in notes)
				{
					var noteCheck:Note = cast note;
					if (noteCheck != null && noteCheck.strumData == strum.data && noteCheck.isPlayer
						&& !noteCheck.beenHit && Math.abs(noteCheck.time - Conductor.songPosition) < 45)
						strum.playAnim("pressed");
				}
			}
			else
			{
				if(pressed[strum.data])
				{
					if(!["pressed", "confirm"].contains(strum.animation.curAnim.name))
						strum.playAnim("pressed");
				}
				else
					strum.playAnim("static");
			}
		}

		for (note in notes.members)
		{
			if (note != null && note is Note)
			{
				var customNote = cast(note, Note);
				customNote.y = Conductor.offset - (Conductor.songPosition - customNote.time) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2));
				
				if (customNote.isPlayer)
				{
					if (isBotplay && !customNote.beenHit && !customNote.isSustain)
					{
						if (Math.abs(customNote.time - Conductor.songPosition) < 45)
							onGoodHitNote(customNote);
					}
					else if (justPressed[customNote.strumData] && !isBotplay)
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

				var sustainNotes:Array<Note> = [];
				var canPush = false;

				if (customNote.isSustain && !customNote.beenHit && !customNote.beenMiss) // Player
				{
					if (pressed.contains(true) && customNote.isPlayer)
					{
						for (i in 0...pressed.length)
						{
							if (pressed[i] && customNote.strumData == i)
							{
								if (Math.abs(Conductor.songPosition - customNote.time) < 135)
									canPush = true;
							}
						}
					}
					else if (isBotplay)
					{
						if (Math.abs(Conductor.songPosition - customNote.time) < 135)
							canPush = true;
					}
					else // DAD (CPU)
					{
						if (Math.abs(Conductor.songPosition - customNote.time) < 135 && !customNote.isPlayer)
							canPush = true;
					}

					if (canPush)
						sustainNotes.push(customNote);
				}

				if (sustainNotes.length > 0)
				{
					sustainNotes.sort((a, b) -> Std.int(a.time - b.time));

					var sustainToHit = sustainNotes[0];
					var center:Float = sustainToHit.isPlayer ? playerStrumline.members[customNote.strumData].y + Note.swagWidth / 2 + 58 : opponentStrumline.members[customNote.strumData].y + Note.swagWidth / 2 + 58;

					if (sustainToHit.y + sustainToHit.offset.y * sustainToHit.scale.y <= center)
					{
						var swagRect = new FlxRect(0, 0, sustainToHit.width / sustainToHit.scale.x, sustainToHit.height / sustainToHit.scale.y);
						swagRect.y = (center - sustainToHit.y) / sustainToHit.scale.y;
						swagRect.height -= swagRect.y;

						@:privateAccess
						sustainToHit.set_clipRect(swagRect);
						onHoldNote(sustainToHit);
					}
				}
				
				if (customNote.y >= 75 && customNote.y <= 100)
				{
					if (!customNote.isPlayer)
					{
						onGoodHitNote(customNote);
						// onHoldNote(customNote);
					}
				}

				if (customNote.isPlayer && !customNote.beenHit && !customNote.beenMiss && customNote.y < playerStrumline.members[customNote.strumData].y)
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

		if (curBeat % 2 == 0 && boyfriend.animation.curAnim != null && !CoolUtil.startsWith(boyfriend.animation.curAnim.name, 'sing') && !boyfriend.specialAnim)
		{
			boyfriend.charDance();
		}
		if (curBeat % 2 == 0 && dad.animation.curAnim != null && !CoolUtil.startsWith(dad.animation.curAnim.name, 'sing') && !dad.specialAnim)
		{
			dad.charDance();
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
		if (note.areHolding || note.isSustain)
		{
			note.beenMiss = true;
			note.areHolding = false;
		}
		if (note.beenMiss || note.beenHit || note.isSustain) return;
		vocals.volume = 0;
		note.beenMiss = true;
		notes.remove(note, true);
		accuracy -= 2;
		if (accuracy < 0) accuracy = 0;
		score -= 10;
		if (score < 0) score = 0;

		perdidos -= 1;
		trace('QUANTOS FORAM PERDIDOS: ' + perdidos);

		switch (note.type)
		{
			default:
				if (!note.beenAccurately)
				{
					boyfriend.playAnim(['singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'][note.strumData], false);
					boyfriend.holdTimer = 0;
				}
		}

		scoreText.text = "Score: " + score;
		accuracyText.text = "Accuracy: " + Std.int(accuracy) + "%";
	}

	public function onHoldNote(note:Note)
	{
		var char = dad;
		var strum = note.isPlayer ? playerStrumline.members[note.strumData] : opponentStrumline.members[note.strumData];
		if (note.beenHit)
			note.areHolding = true;

		if (note.isPlayer)
		{
			char = boyfriend;
			if (char != null && note.type != "no animation")
			{
				char.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.strumData], true);
				char.holdTimer = 0;
			}
		}
		else
		{
			char = dad;
			if (strum != null) strum.playAnim('confirm', true);
			if (char != null && note.type != "no animation")
			{
				char.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.strumData], true);
				char.holdTimer = 0;
			}
		}
	}

	public function onGoodHitNote(note:Note)
	{
		note.beenHit = true;
		vocals.volume = 1;
		note.kill();
		if (note.beenMiss || note.isSustain) return;
		var strum = playerStrumline.members[note.strumData];
		var opponentStrum = opponentStrumline.members[note.strumData];
		var char = dad;

		if (!note.isPlayer)
		{
			char = dad;
			if (opponentStrum != null)
			{
				opponentStrum.playAnim('confirm', true);
				opponentStrum.animation.finishCallback = function(name:String)
				{
					opponentStrum.playAnim('static', false);
				};
			}
			note.kill();
		}
		else if (note.isPlayer)
		{
			score += 100;
			updateAccuracy(true);
			char = boyfriend;

			if (boyfriend != null && note.type != "no animation")
			{
				boyfriend.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.strumData], true);
				boyfriend.holdTimer = 0;
			}

			if (strum != null)
				strum.playAnim('confirm', true);

			if (isBotplay)
			{
				strum.playAnim('confirm', true);
				strum.animation.finishCallback = function(name:String)
				{
					strum.playAnim('static', true);
				};
			}
			
			note.kill();
		}

		if (char != null && note.type != "no animation")
		{
			char.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.strumData], true);
			char.holdTimer = 0;
		}
	}	

	private function updateAccuracy(hit:Bool):Void
		accuracy = hit ? (accuracy * 0.9) + 100 * 0.1 : accuracy * 0.9;
}
