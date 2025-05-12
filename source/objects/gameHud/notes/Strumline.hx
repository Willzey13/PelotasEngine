package objects.gameHud.notes;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import objects.gameHud.notes.Note;
import objects.gameHud.notes.NoteStrum;

class Strumline
{
    public var strumline:FlxTypedGroup<NoteStrum>;
    public var notes:FlxGroup;
    private var velocity:Float;

    public function new(velocity:Float)
    {
        this.velocity = velocity;

        // Inicializar grupos
        strumline = new FlxTypedGroup<NoteStrum>();
        notes = new FlxGroup();

        // Criar strumline
        var directions = ["left", "down", "up", "right"];
        for (i in 0...4)
        {
            var strum = new NoteStrum(FlxG.width / 2 - 100 + i * 108, 50, directions[i]);
            strumline.add(strum);
        }

        // Iniciar o timer de notas
        var timer = new FlxTimer();
        timer.start(1, generateNotes, 0);
    }

    private function generateNotes(timer:FlxTimer):Void
    {
        var directions = ["left", "down", "up", "right"];
        var positions = [-63, 46, 157, 263];
        var randomIndex = FlxG.random.int(0, 3);

        var note = new Note(
            FlxG.width / 2 + positions[randomIndex],
            FlxG.height + 50,
            directions[randomIndex],
            FlxG.random.float(0.1, 30)
        );
        notes.add(note);

        timer.start(1, generateNotes, 0);
    }
}
