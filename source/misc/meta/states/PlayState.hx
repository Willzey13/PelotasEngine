package misc.meta.states;

import data.Conductor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import haxe.Json;
import objects.gameHud.notes.Note;

class PlayState extends FlxState
{
    public static var isPixel:Bool = false;
    var notes:FlxGroup;
    var chartNotes:Array<Note>;
    public static var missCount:Int = 0;
    public static var strumlineY:Float = 500;
    public static var song:String = "assets/songs/transformer/transformer.ogg";
    public static var isPlaying:Bool = false;

    override public function create()
    {
        super.create();

        FlxG.sound.playMusic(song, 1, false);
        Conductor.songStartTime = FlxG.sound.music.time;
        isPlaying = true;

        notes = new FlxGroup();
        chartNotes = [];

        chartNotes = loadChart(Paths.data('gay'));
        for (note in chartNotes)
        {
            notes.add(note);
        }
        add(notes);
    }

	function loadChart(path:String):Array<Note>
	{
		var data = Json.parse(sys.io.File.getContent(path));
		var noteArray:Array<Note> = [];
		var notes:Array<Dynamic> = data.notes;
		
		for (note in notes)
		{
			var newNote = new Note(10, Conductor.getNotePosition(note.time), note.direction, note.time);
			noteArray.push(newNote);
		}
	
		return noteArray;
	}

    override public function update(elapsed:Float):Void
    {
		super.update(elapsed);
    }
}
