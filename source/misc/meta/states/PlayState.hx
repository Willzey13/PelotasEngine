package misc.meta.states;

import data.Conductor;
import data.Section.SwagSection;
import data.Song.SwagSong;
import data.Song;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import objects.gameHud.notes.Note;
import objects.gameHud.notes.NoteStrum;
import objects.Character;
import objects.Stage;
import misc.Timings;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var SONG:SwagSong;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var defaultCamZoom:Float = 1.05;
	public var generatedMusic:Bool = false;
	public var camZooming:Bool = false;
	public var camFollow:FlxObject;

	public var instrumental:FlxSound;
	public var vocals:FlxSound;
	
	public var breno:Character;
	public var gabi:Character;
	public var daddy:Character;

	public var stage:Stage;
	public var curStage:String = '';
	public var brenoPoint:FlxPoint;
	public var gabiPoint:FlxPoint;
	public var daddyPoint:FlxPoint;

	public var playerStrumline:FlxTypedGroup<NoteStrum>;
	public var opponentStrumline:FlxTypedGroup<NoteStrum>;
	public var notes:FlxGroup;

    public static var isPixel:Bool = false;
	private var score:Int = 0;
	private var accuracy:Float = 100.0;
	private var scoreText:FlxText;
	private var accuracyText:FlxText;
	public var missesText:FlxText;
	public var misses:Int = 0;

	override public function create():Void
    {
        super.create();
		defaultCamZoom = 1.00000000002;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		
		brenoPoint = new FlxPoint(0, 0);
		gabiPoint = new FlxPoint(0, 0);
		daddyPoint = new FlxPoint(0, 0);

		FlxCamera.defaultCameras = [camGame];
		SONG = Song.loadFromJson('tutorial', 'tutorial');

		curStage = SONG.stage;
		curStage = 'cimiterio';

		switch (curStage)
		{
			case 'stage':
				brenoPoint.x += 0;
				brenoPoint.y += 0;
				gabiPoint.x += 0;
				gabiPoint.y += 0;
				daddyPoint.x += 0;
				daddyPoint.y += 0;

			case 'cimiterio':
				brenoPoint.x += 600;
				brenoPoint.y += 600;
				gabiPoint.x += 1150;
				gabiPoint.y += 750;
				daddyPoint.x += 600;
				daddyPoint.y += 850;
		}

		stage = new Stage(curStage);
		add(stage);

		breno = new Character(0, 0, 'breno', true);
		breno.x += brenoPoint.x;
		breno.y += brenoPoint.y;
		add(breno);

		gabi = new Character(0, 0, 'gabi', false);
		gabi.x += gabiPoint.x;
		gabi.y += gabiPoint.y;
		add(gabi);

		daddy = new Character(0, 0, 'spooky', false);
		daddy.x += daddyPoint.x;
		daddy.y += daddyPoint.y;
		add(daddy);

		//add(stage.foreground);

		var camPos:FlxPoint = new FlxPoint(daddy.getGraphicMidpoint().x, daddy.getGraphicMidpoint().y);
		playerStrumline = new FlxTypedGroup<NoteStrum>();
		playerStrumline.camera = camHUD;
		var directions = ["left", "down", "up", "right"];
		for (i in 0...4)
		{
			var direction = directions[i];
			var strum = new NoteStrum(FlxG.width / 2 + 140 + i * 108, 20, direction);
			playerStrumline.add(strum);
		}
		add(playerStrumline);

		opponentStrumline = new FlxTypedGroup<NoteStrum>();
		opponentStrumline.camera = camHUD;
		for (i in 0...4)
		{
			var direction = directions[i];
			var strum = new NoteStrum(FlxG.width / 2 - 610 + i * 108, 20, direction);
			opponentStrumline.add(strum);
		}
		add(opponentStrumline);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		if(boyfriendCameraOffset == null)
			boyfriendCameraOffset = [0, 130];

		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		notes = new FlxGroup();
		notes.camera = camHUD;
        add(notes);
		scoreText = new FlxText(10, 10, 200, "Score: 0");
		accuracyText = new FlxText(10, 30, 200, "Accuracy: 100%");
		missesText = new FlxText(10, FlxG.height - 30, 200, 'Misses: $misses');
		missesText.cameras = [camHUD];
		add(scoreText);
		add(accuracyText);
		add(missesText);

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

				var swagNote:Note = new Note(noteX, FlxG.height + 50, direction, daStrumTime);
				swagNote.scrollFactor.set(0, 0);
				swagNote.sustainLength = songNotes[2];
				swagNote.isPlayer = gottaHitNote;
				sortByShit(swagNote, swagNote);

				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;
				for (susNote in 0...Math.floor(susLength))
				{
					var sustainNote:Note = new Note(noteX + 60, FlxG.height + 50, direction, daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, true);
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

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

    override public function update(elapsed:Float):Void
    {
		super.update(elapsed);

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		if (FlxG.keys.justPressed.SPACE)
			paused = !paused;

		pressed = [
			(FlxG.keys.pressed.Z || FlxG.keys.pressed.LEFT),
			(FlxG.keys.pressed.X || FlxG.keys.pressed.DOWN),
			(FlxG.keys.pressed.M || FlxG.keys.pressed.UP),
			(FlxG.keys.pressed.COMMA || FlxG.keys.pressed.RIGHT),
		];
		justPressed = [
			(FlxG.keys.justPressed.Z || FlxG.keys.justPressed.LEFT),
			(FlxG.keys.justPressed.X || FlxG.keys.justPressed.DOWN),
			(FlxG.keys.justPressed.M || FlxG.keys.justPressed.UP),
			(FlxG.keys.justPressed.COMMA || FlxG.keys.justPressed.RIGHT),
		];
		released = [
			(FlxG.keys.justReleased.Z || FlxG.keys.justReleased.LEFT),
			(FlxG.keys.justReleased.X || FlxG.keys.justReleased.DOWN),
			(FlxG.keys.justReleased.M || FlxG.keys.justReleased.UP),
			(FlxG.keys.justReleased.COMMA || FlxG.keys.justReleased.RIGHT),
		];

		if (generatedMusic)
		{
			if(breno.animation.curAnim != null && breno.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * breno.singDuration && breno.animation.curAnim.name.startsWith('sing') && !breno.animation.curAnim.name.endsWith('miss')) {
				breno.dance();
			}

			if (startedCountdown && !breno.stunned)
			{
				if (breno.animation.curAnim != null && breno.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * breno.singDuration && breno.animation.curAnim.name.startsWith('sing') && !breno.animation.curAnim.name.endsWith('miss'))
					breno.dance();
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if (curBeat % 4 == 0)
				{
					//trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
				}
			
				// Adicionando offsets de câmera do personagem
				if (camFollow.x != daddy.x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					camFollow.setPosition(daddy.getMidpoint().x + 150, daddy.getMidpoint().y - 100);
					camFollow.x += daddy.cameraPosition[0] + opponentCameraOffset[0];
					camFollow.y += daddy.cameraPosition[1] + opponentCameraOffset[1];
				}
			
				if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != breno.x - 100)
				{
					camFollow.setPosition(breno.getMidpoint().x - 100, breno.getMidpoint().y - 100);
					camFollow.x -= breno.cameraPosition[0] - boyfriendCameraOffset[0];
					camFollow.y += breno.cameraPosition[1] + boyfriendCameraOffset[1];
				}
			}
		}

		playingPlayer = false;

		for (strum in playerStrumline.members)
		{
			if(pressed[strum.data])
			{
				if(!["pressed", "confirm"].contains(strum.animation.curAnim.name))
					strum.playAnim("pressed");
			}
			else
				strum.playAnim("static");

			if(strum.animation.curAnim.name == "confirm")
				playingPlayer = true;
		}

		for (note in notes.members)
		{
			if (note != null && note is Note)
			{
				var customNote = cast(note, Note);
				customNote.y = 200 + Conductor.offset - (Conductor.songPosition - customNote.time) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2));
				
				var timingOffset: Float = -30; // Ajuste este valor para modificar o intervalo aceitável
				if (customNote.y >= -100 && customNote.time <= Conductor.songPosition + timingOffset)
				{
					if (customNote.isPlayer) 
					{
						if (justPressed.contains(true))
						{
							for (i in 0...justPressed.length)
							{
								if (justPressed[i])
								{
									var closestHitNote: Note = null; // bruh
									var minTiming: Float = customNote.beenMiss ? Timings.getTimings("good")[1] : Timings.minTiming;
									var noteDiff: Float = customNote.onNoteOffset();

									if (noteDiff <= minTiming && !customNote.beenMiss && !customNote.beenHit && customNote.strumData == i)
									{
										if (!(customNote.beenMiss && Conductor.songPosition >= customNote.time + Timings.getTimings("sick")[1]))
										{
											closestHitNote = customNote;
										}
									}
								
									if (closestHitNote != null)
									{
										onGoodHitNote(closestHitNote, true);
									}
									else if (!ghostTapping && startedCountdown)
									{
										// Incrementa misses se nenhuma nota foi encontrada para acertar
										// vocals.volume = 0;
								
										// Exemplo de miss handling (opcional):
										// var note = new Note();
										// note.updateData(0, i, "none", assetModifier);
										// onNoteMiss(note, playerStrumline, true);
									}
								}
							}
						}
					}
				}

				if (pressed.contains(true) && customNote.isPlayer)
				{
					for (i in 0...pressed.length)
					{
						if (pressed[i])
						{
							if (customNote.y >= -30 && customNote.y <= 100)
							{
								if (customNote.isSustain)
								{
									var possibleHitNotes: Array<Note> = []; // notas possíveis
									var canHitNote: Note = null;
									var noteDiff: Float = customNote.onNoteOffset();
									var minTiming: Float = Timings.minTiming;

									if (customNote.beenMiss)
										minTiming = Timings.getTimings("good")[1];
				
									if (noteDiff <= minTiming && !customNote.beenMiss && !customNote.beenHit && customNote.strumData == i)
									{
										if (customNote.beenMiss && Conductor.songPosition >= customNote.time + Timings.getTimings("sick")[1]) 
										{
											continue;
										}
				
										possibleHitNotes.push(customNote);
										canHitNote = customNote;
									}

									if (canHitNote != null)
									{
										for (note in possibleHitNotes) {
											if (note.time < canHitNote.time)
												canHitNote = note;
										}
				
										onGoodHitNote(canHitNote, true);
									}
								}
							}
						}
					}
				}

				if (customNote.y >= -50 && customNote.y <= 70)
				{
					if (!customNote.isPlayer)
						onGoodHitNote(customNote, false);
				}

				if (customNote.y < -100)
				{
					customNote.kill();
					updateAccuracy(false);
				}
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
	public var gfSpeed:Int = 1;
	public var playingPlayer:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		// if (generatedMusic)
			// notes.sort(FlxSort.byY, FlxSort.DESCENDING); // está linha

		for (char in [breno, gabi, daddy])
		{
			if (char == gabi && gabi != null && curBeat % Math.round(gfSpeed * gabi.danceEveryNumBeats) == 0 && gabi.animation.curAnim != null && !gabi.animation.curAnim.name.startsWith("sing") && !gabi.stunned)
				gabi.dance();

			if (char == breno && curBeat % breno.danceEveryNumBeats == 0 && breno.animation.curAnim != null && !breno.animation.curAnim.name.startsWith('sing') && !breno.stunned)
				breno.dance();
			
			if (char == daddy && curBeat % daddy.danceEveryNumBeats == 0 && daddy.animation.curAnim != null && !daddy.animation.curAnim.name.startsWith('sing') && !daddy.stunned)
				daddy.dance();
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
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

	public function onGoodHitNote(note:Note, isPlayer:Bool = false)
	{
		vocals.volume = 1;
		var canLoop:Bool = note.isSustain
			&& (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.UP || FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.DOWN);
		var strum = playerStrumline.members[note.strumData];
		var opponentStrum = opponentStrumline.members[note.strumData];
		var char = breno;

		if (!note.isPlayer)
		{
			char = daddy;
			if (opponentStrum != null)
			{
				opponentStrum.playAnim('confirm', false);
				opponentStrum.animation.finishCallback = function(name:String)
				{
					opponentStrum.playAnim('static', true);
				};
			}

			char.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.strumData], false);
			char.holdTimer = 0;
			note.kill();
		}
		else if (note.isPlayer)
		{
			char = breno;
			score += 100;
			updateAccuracy(true);

			if (strum != null)
				strum.playAnim('confirm', true);

			char.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.strumData], false);
			char.holdTimer = 0;
			note.kill();
		}
	}

	private function updateAccuracy(hit:Bool):Void
		accuracy = hit ? (accuracy * 0.9) + 100 * 0.1 : accuracy * 0.9;
}
