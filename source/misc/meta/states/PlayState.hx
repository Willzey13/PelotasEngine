package misc.meta.states;

import data.Conductor;
import data.Section.SwagSection;
import data.Song.SwagSong;
import data.Song;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
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
import misc.Timings.Judgement;
import misc.Timings;
import misc.scripts.ScriptManagerHaxe;
import objects.Character;
import objects.gameHud.CustomBar;
import objects.gameHud.notes.Note;
import objects.gameHud.notes.NoteSplash;
import objects.gameHud.notes.NoteStrum;
import misc.meta.substates.PauseSubState;
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
	public var camFollow:FlxObject;
	public var curStage:String = "";

	public var instrumental:FlxSound;
	public var vocals:FlxSound;
	public var vocalsP2:FlxSound;

	public var boyfriend:Character;
	public var dad:Character;

	public var playerStrumline:FlxTypedGroup<NoteStrum>;
	public var opponentStrumline:FlxTypedGroup<NoteStrum>;
	public var noteSplashes:FlxTypedGroup<NoteSplash>;
	public var unspawnNotes:Array<Note> = [];
	public var subunspawnNotes:Array<Note> = [];
	public var notes:FlxGroup;

    public static var isPixel:Bool = false;
	public var health:Float = 1.15;
	public var healthBar:CustomBar;

	private var score:Int = 0;
	private var accuracy:Float = 100.0;
	private var scoreText:FlxText;

	override public function create():Void
    {
        super.create();
		unspawnNotes = [];
		subunspawnNotes = [];
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		if (SONG == null)
			SONG = Song.loadFromJson('stress-pico', 'stress-pico');

		ScriptManagerHaxe.clear();

		var bfX:Int = 600;
		var bfY:Int = 500;
		var dadX:Int = 200;
		var dadY:Int = 100;

		curStage = SONG.stage;
		switch (curStage)
		{
			case 'stage':
				defaultCamZoom = 0.7;

				var stageback = new FlxSprite(-10500, -100).loadGraphic('assets/images/defaultBg/stageback.png');
				add(stageback);

				var stagefront = new FlxSprite(-100, 740).loadGraphic('assets/images/defaultBg/stagefront.png');
				add(stagefront);

				bfX = 1400;
				bfY = 450;
				dadX = 500;
			case 'military-stress':
				defaultCamZoom = 0.85;
				var bg = new FlxSprite().loadGraphic('assets/week7/images/pico/bg.png');
				bg.scale.set(1.15, 1.15);
				add(bg);

			default:
				var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
				add(bg);
		}

		camGame.zoom = defaultCamZoom;
		dad = new Character(dadX, dadY, SONG.player2, true);
		add(dad);

		boyfriend = new Character(bfX, bfY, SONG.player1, false);
		add(boyfriend);

		var strumY = downscroll ? (FlxG.height - 100) : -10;
		playerStrumline = new FlxTypedGroup<NoteStrum>();
		playerStrumline.camera = camHUD;
		var directions = ["left", "down", "up", "right"];
		for (i in 0...4)
		{
			var direction = directions[i];
			var strum = new NoteStrum(FlxG.width / 2 + 100 + i * 113, strumY, direction);
			playerStrumline.add(strum);
		}

		opponentStrumline = new FlxTypedGroup<NoteStrum>();
		opponentStrumline.camera = camHUD;
		for (i in 0...4)
		{
			var direction = directions[i];
			var strum = new NoteStrum(FlxG.width / 2 - 650 + i * 113, strumY, direction);
			opponentStrumline.add(strum);
		}

		notes = new FlxGroup();
		notes.camera = camHUD;
		noteSplashes = new FlxTypedGroup<NoteSplash>();
		noteSplashes.cameras = [camHUD];

		for (s in 0...4)
		{
			var splash:NoteSplash = new NoteSplash();
			splash.setupNoteSplash(0, 0, s);
			noteSplashes.add(splash);
		}

		healthBar = new CustomBar(100, 50, 200, 20, FlxColor.GREEN, FlxColor.BLACK);
		healthBar.setPosition(0, downscroll ? -10 : FlxG.height * 0.89);
		healthBar.scaleMultiplier.set(1.203, 0.85);
		healthBar.screenCenter(X);
		healthBar.scale.set(1.22, 1.20);
		healthBar.value = health;
		healthBar.setBarColors(FlxColor.fromRGB(111,252,80,255), FlxColor.fromRGB(250,17,12,255));
		healthBar.cameras = [camHUD];
		add(healthBar);

		generateSong();
		Conductor.songPosition = -Conductor.crochet * 5;

		add(opponentStrumline);
		add(playerStrumline);
        add(notes);
		add(noteSplashes);

		scoreText = new FlxText(0, FlxG.height * 0.89 + 30, 0, "Score: 0 | Accuracy: 00.0% | Misses: 0"); //o width no 500 faz os misses ficarem fudidos will VAI TOMA NO CU
		scoreText.screenCenter(X);
		scoreText.cameras = [camHUD];
        scoreText.setFormat(Paths.getFont('vcr', 'ttf'), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);

		reloadScripts();
    	ScriptManagerHaxe.call("create");

		var centerPos:Array<Float> = [(dad.x + boyfriend.x) / 2, (dad.y + boyfriend.y) / 2];
		camFollow = new FlxObject(centerPos[0], centerPos[1], 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, FlxCameraFollowStyle.LOCKON);
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
	public var curSong:String = '';

	public function generateSong()
	{
		generatedMusic = true;
		camZooming = true;
		var songData = SONG;
		var noteData:Array<SwagSection>;
		Conductor.changeBPM(songData.bpm);
		noteData = songData.notes;
		reloadSong(songData);

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
					noteX = FlxG.width / 2 - 610 + daNoteData * 113;
					direction = directions[daNoteData];
				}
				else
				{
					noteX = FlxG.width / 2 + 140 + daNoteData * 113;
					direction = directions[daNoteData];
				}

				var swagNote:Note = new Note(noteX - 3, FlxG.height + 50, direction, daStrumTime);
				swagNote.scrollFactor.set(0, 0);
				swagNote.sustainLength = songNotes[2];
				swagNote.isPlayer = gottaHitNote;
				unspawnNotes.push(swagNote);
				subunspawnNotes.push(swagNote);

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
					unspawnNotes.push(sustainNote);
					subunspawnNotes.push(sustainNote);
				}
			}

			unspawnNotes.sort(sortByShit);
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);

	function reloadSong(songData:SwagSong):Void
	{
		curSong = SONG.song;
		var vocalsPathOpponent = Paths.voicesopponent(PlayState.SONG.song, true);
		var vocalsPathPlayer = Paths.voices(PlayState.SONG.song, true);
		var vocalsPathDefault = Paths.voices(PlayState.SONG.song);

		instrumental = new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song));
		if (SONG.needsVoices)
		{
			var getPathSong = 'assets/songs/${Paths.getFormatPath(curSong)}/Voices-Opponent.ogg';
			if (FileSystem.exists(getPathSong))
			{
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, true));
				vocalsP2 = new FlxSound().loadEmbedded(Paths.voicesopponent(PlayState.SONG.song, true));
			}
			else
				vocals = new FlxSound().loadEmbedded(vocalsPathDefault);
		}
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(instrumental);
		FlxG.sound.list.add(vocals);
		if (vocalsP2 != null)
			FlxG.sound.list.add(vocalsP2);
	}

	public function startCountdown()
	{
		var daCount:Int = 0;
		var countTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			Conductor.songPosition = -Conductor.crochet * (4 - daCount);

			if(daCount == 0)
			{
				startedCountdown = true;
				areReset = false;
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

		// Check if the folder exists; if not, create it
		if (!FileSystem.exists(scriptsPath))
		{
			trace("Scripts folder not found. Creating...");
			FileSystem.createDirectory(scriptsPath);
			return; // No scripts to load after creating an empty folder
		}

		var scripts = FileSystem.readDirectory(scriptsPath);

		for (script in scripts)
		{
			if (StringTools.endsWith(script, ".hx"))
			{
				var fullPath = scriptsPath + script;
				trace("Loading script: " + fullPath);

				// Pass the entire PlayState instance as context
				ScriptManagerHaxe.load(fullPath, { playState: this });
			}
		}
	}

	function startSong():Void
	{
		startingSong = false;

		if (!paused || instrumental != null)
			instrumental.play();

		if (vocalsP2 != null)
			vocalsP2.play();
		
		vocals.play();

		if(paused) {
			instrumental.pause();
			vocals.pause();
			vocalsP2.pause();
		} else if (!paused) {
			instrumental.resume();
			vocals.resume();
			if (vocalsP2 != null) vocalsP2.resume();
		}
	}

	function quitSong()
	{
		instrumental.stop();
		vocals.stop();
		if (vocalsP2 != null)
			vocalsP2.stop();
		
		notes.clear();
		unspawnNotes = [];
		subunspawnNotes = [];

		CoolUtil.switchState(new FreeplayState());
	}

	function openPause()
	{
		instrumental.pause();
		vocals.pause();
		if (vocalsP2 != null)
			vocalsP2.pause();

		paused = true;
		openSubState(new PauseSubState());
	}

	function resyncVocals():Void
	{
		vocals.pause();

		instrumental.play();
		Conductor.songPosition = instrumental.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var pressed:Array<Bool> 		= [];
	public var justPressed:Array<Bool> 	= [];
	public var released:Array<Bool> 	= [];
	public var ghostTapping:Bool = false;
	public var isChartingMode:Bool = false;
	var perdidos:Int = 0;
	public var areReset:Bool = false;

	public function repositionStrums()
	{
		var strumY = downscroll ? (FlxG.height - 230) : -10;
		var healthY = downscroll ? -10 : FlxG.height * 0.89;

		for (strum in playerStrumline)
			strum.y = strumY;

		for (strum in opponentStrumline)
			strum.y = strumY;

		healthBar.y = healthY;
	}

	public var downscroll:Bool;

    override public function update(elapsed:Float):Void
    {
		super.update(elapsed);

		FlxG.camera.followLerp = elapsed * 3 * SONG.speed;

		if (FlxG.keys.justPressed.B && (isFreeplay || isChartingMode))
            isBotplay = !isBotplay;

        if (FlxG.keys.justPressed.ESCAPE)
			openPause();

		if(paused) {
			instrumental.pause();
			vocals.pause();
			vocalsP2.pause();
		} else if (!paused) {
			instrumental.resume();
			vocals.resume();
			if (vocalsP2 != null) vocalsP2.resume();
		}

		ScriptManagerHaxe.call("update", { playState: this, args: [elapsed] });
		if (camZooming)
		{
			if (camGame != null && camGame.zoom > defaultCamZoom)
				camGame.zoom = FlxMath.lerp(camGame.zoom, defaultCamZoom, elapsed * 6);

			if (camHUD != null && camHUD.zoom > 1)
				camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, elapsed * 6);
		}

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

		if (FlxG.keys.justPressed.SEVEN) // sete
		{
			downscroll = !downscroll;
			repositionStrums();
		}

		if (FlxG.keys.justPressed.R) // lol
        	resetSong();

		if (health > 2)
			health = 2;

		var camOffset = 13;
		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (!SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(
					dad.x + dad.width / 2 + dad.cameraPosition.x,
					dad.y + dad.height / 2 + dad.cameraPosition.y
				);

				switch (dad.animation.curAnim.name)
				{
					case "singLEFT":  camFollow.x -= camOffset * 0.5;
					case "singRIGHT": camFollow.x += camOffset * 0.5;
					case "singUP":    camFollow.y -= camOffset * 0.5;
					case "singDOWN":  camFollow.y += camOffset * 0.5;
				}
			}
			else
			{
				camFollow.setPosition(
					boyfriend.x + boyfriend.width / 2 + boyfriend.cameraPosition.x,
					boyfriend.y + boyfriend.height / 2 + boyfriend.cameraPosition.y
				);

				switch (boyfriend.animation.curAnim.name)
				{
					case "singLEFT":  camFollow.x -= camOffset * 0.5;
					case "singRIGHT": camFollow.x += camOffset * 0.5;
					case "singUP":    camFollow.y -= camOffset * 0.5;
					case "singDOWN":  camFollow.y += camOffset * 0.5;
				}

			}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].time - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		for (strum in playerStrumline)
		{
			
		}

		// Opponent strums
		for (strum in opponentStrumline)
		{
			if (strum.animation.curAnim != null && strum.animation.curAnim.name == 'confirm' 
				&& strum.animation.finished)
				strum.playAnim('static', false);
		}

		// strums lines gg
		for (strum in playerStrumline.members)
		{
			if (strum.animation.curAnim != null && strum.animation.curAnim.name == 'confirm' 
				&& strum.animation.finished)
				strum.playAnim('static', false);

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

		if (generatedMusic)
		{
			healthBar.value = FlxMath.lerp(healthBar.value, health, 0.33);

			for (note in notes.members)
			{
				if (note != null && note is Note)
				{
					var customNote = cast(note, Note);
					if (!areReset) {
						if (downscroll)
							customNote.y = Conductor.offset + (Conductor.songPosition - customNote.time) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2));
						else
							customNote.y = Conductor.offset - (Conductor.songPosition - customNote.time) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2));
					}

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
					
					if (!customNote.isPlayer)
					{
						var strumY = opponentStrumline.members[customNote.strumData].y;
						var noteDist = Math.abs(customNote.y - strumY);
						if (noteDist < 40)
							onGoodHitNote(customNote);
					}

					if (customNote.isPlayer && !customNote.beenHit && !customNote.beenMiss)
					{
						var strumY = playerStrumline.members[customNote.strumData].y;
						var passedStrumline = downscroll ? (customNote.y > strumY) : (customNote.y < strumY);

						if (passedStrumline && Conductor.songPosition - customNote.time > Judgement.worstTiming())
							onMissNote(customNote);
					}
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

		scoreText.text = "Score: " + CoolUtil.formatNumberWithCommas(score) + " | Accuracy: " + Std.int(accuracy) + "%" + " | Misses: " + perdidos;
		scoreText.screenCenter(X);
	}

	public static var paused:Bool = false;
	public var startedCountdown:Bool = true;
	public var startingSong:Bool = true;
	var zoomLevel:Float = 1.0;

	public function resetSong():Void
	{
		ScriptManagerHaxe.clear();
		
		var songData = SONG;
		areReset = true;
		for (note in notes.members)
		{
			if (note != null)
				FlxTween.tween(note, { y: FlxG.height + 50 }, 2, { ease: FlxEase.cubeInOut });
		}
		
		for (note in unspawnNotes)
		{
			if (note != null)
			{
				FlxTween.tween(note, { y: FlxG.height + 50 }, 2, { ease: FlxEase.cubeInOut });
				note.resetNotes();
			}
		}
		
		notes.clear();
		unspawnNotes = [];

		instrumental.stop();
		if (vocals != null)
			vocals.stop();

		if (vocalsP2 != null)
			vocalsP2.stop();

		generatedMusic = false;
		camZooming = false;

		reloadScripts();

		for (notes in subunspawnNotes)
			unspawnNotes.push(notes);

		generatedMusic = true;
		camZooming = true;
		// generateSong();
		reloadSong(songData);
		Conductor.changeBPM(songData.bpm);
		Conductor.songPosition = -Conductor.crochet * 5;
		startCountdown();
	}

	override function beatHit()
	{
		super.beatHit();

		//if (generatedMusic)
			//notes.sort(FlxSort.byY, downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

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
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20 || 
				(vocalsP2 != null && (vocalsP2.time > Conductor.songPosition + 20 || vocalsP2.time < Conductor.songPosition - 20)))
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

		var soundNum:Int = FlxG.random.int(1, 3);
		var soundName:String = 'missnote' + soundNum;
		FlxG.sound.play(Paths.sound(soundName), FlxG.random.float(0.3, 0.5));

		perdidos += 1;
		health -= 0.04;

		switch (note.type)
		{
			default:
				if (!note.beenAccurately)
				{
					boyfriend.playAnim(['singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'][note.strumData], false);
					boyfriend.holdTimer = 0;
				}
		}
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
			if (strum != null) strum.playAnim('confirm', true);
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
				opponentStrum.playAnim('confirm', true);

			note.kill();
		}
		else if (note.isPlayer)
		{
			score += 100;
			health += 0.04;
			updateAccuracy(true);
			char = boyfriend;

			if (strum != null)
				strum.playAnim('confirm', false);

			var judgementName = Judgement.getJudgementByTiming(Math.abs(note.time - Conductor.songPosition));
			if (judgementName == 'sick') {
				var splash = noteSplashes.members[note.strumData];
				splash.playSplash(strum.x, strum.y, note.strumData);
			}

			if (isBotplay && strum != null)
				strum.playAnim('confirm', false);

			note.kill();
		}

		if (char != null && note.type != "no animation")
		{
			char.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.strumData], false);
			char.holdTimer = 0;
		}
	}

	private function updateAccuracy(hit:Bool):Void
		accuracy = hit ? (accuracy * 0.9) + 100 * 0.1 : accuracy * 0.9;
}
