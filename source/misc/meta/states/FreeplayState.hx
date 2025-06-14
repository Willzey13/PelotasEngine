package misc.meta.states;

import data.Song;
import shaders.GaussianBlurShader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import misc.meta.states.MainMenuState;
import objects.menus.BFAnimate;
import objects.menus.Capsule;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

typedef FreeplayEntry = {
    var song:String;
    var difficulties:Array<String>;
}

class FreeplayState extends MusicBeatState
{
    public var songs:Array<FreeplayEntry> = [];
    public var select:Int = 0;
    public var curDiff:Int = 0;

    var bfOG:BFAnimate;
    var diffText:FlxText;
    var songBoxes:Array<FlxGroup> = [];

    override function create() {
        super.create();
        MemoryManager.clearUnusedMemory();

        loadSongs();

        bfOG = new BFAnimate(0, -100);
        bfOG.playAnim('first');
        add(bfOG);

        for (i in 0...songs.length) {
            var group = createCapsule(capitalizeWords(songs[i].song), i);
            songBoxes.push(group);
            add(group);
        }

        diffText = new FlxText(0, FlxG.height - 40, FlxG.width, "", 24);
        diffText.setFormat(Paths.getFont('vcr', 'ttf'), 24, FlxColor.YELLOW, "center");
        add(diffText);

        updateList();
    }

    function loadSongs()
    {
        songs = [];

        var paths = [
            'assets/weeks/',
            'mods/weeks/'
        ];

        for (path in paths) {
            if (FileSystem.exists(path))
            {
                var files = FileSystem.readDirectory(path);
                for (file in files)
                {
                    if (CoolUtil.endsWith(file, '.json'))
                    {
                        var fullPath = path + file;
                        var jsonRaw:String = File.getContent(fullPath);
                        if (jsonRaw != null) {
                            try {
                                var parsed:Dynamic = Json.parse(jsonRaw);

                                if (Std.isOfType(parsed, Array)) 
                                    songs = songs.concat(parsed);
                                else if (Reflect.hasField(parsed, "songs") && Std.isOfType(Reflect.field(parsed, "songs"), Array))
                                {
                                    var songArray:Array<FreeplayEntry> = cast Reflect.field(parsed, "songs");
                                    songs = songs.concat(songArray);
                                } else if (Reflect.hasField(parsed, "song") && Reflect.hasField(parsed, "difficulties")) // parsed is a single FreeplayEntry object
                                    songs.push(cast parsed);
                                else
                                    trace('Invalid JSON format in ' + fullPath);
                            } catch (e) {
                                trace('Error reading ' + fullPath + ': ' + e);
                            }
                        }
                    }
                }
            } else {
                trace('Directory not found: ' + path);
            }
        }
    }

    var glowColor:FlxColor = 0xFF00ccff;

    function createCapsule(text:String, index:Int):FlxGroup {
        var group = new FlxGroup();

        var capsule = new Capsule(0, 0);
        capsule.playAnim('NO select', true);
        capsule.scale.set(0.83, 0.83);
        // capsule.alpha = 0.7;
        capsule.updateHitbox();

        var label = new FlxText(0, 0, 300, text, 28);
        label.setFormat(Paths.getFont('5by7_b', 'ttf'), 28, FlxColor.WHITE, "center");
        label.shader = new GaussianBlurShader(1);
        label.color = glowColor;
        label.borderStyle = FlxTextBorderStyle.OUTLINE;
        label.borderColor = FlxColor.BLACK;

        var wtLabel = new FlxText(0, 0, 300, text, 28);
        wtLabel.setFormat(Paths.getFont('5by7_b', 'ttf'), 28, FlxColor.WHITE, "center");

        group.add(capsule);
        group.add(label);
        group.add(wtLabel);

        return group;
    }

    function updateList()
    {
        var diff = songs[select].difficulties[curDiff];
        diffText.text = "Difficulty: " + diff.toUpperCase();

        var centerY = FlxG.height / 2 - 100;
        var spacingY = 130;

        for (i in 0...songBoxes.length) {
            var group = songBoxes[i];
            var capsule = cast(group.members[0], Capsule);
            var label = cast(group.members[1], FlxText);
            var wtLabel = cast(group.members[2], FlxText);

            var pos = i - select;
            var y = centerY + pos * spacingY;
            var wave = -Math.pow(Math.sin(pos * 0.5), 2) * 80;

            capsule.x = FlxG.width / 2 + wave - capsule.width / 2;
            capsule.y = y;

            label.x = capsule.x;
            label.y = capsule.y + 30;

            wtLabel.x = label.x;
            wtLabel.y = label.y;

            //var alpha = (i == select) ? 1 : 0.6;
            //var scale = (i == select) ? 1.2 : 1.0;

            if (i == select)
                capsule.playAnim('select');
            else
                capsule.playAnim('NO select', true);

            //capsule.alpha = alpha;
            //label.alpha = alpha;
            //capsule.scale.set(scale, scale);
            //label.scale.set(scale, scale);
        }
    }

    function capitalizeWords(text:String):String {
        return text
            .toLowerCase()
            .split(" ")
            .map(word -> word.charAt(0).toUpperCase() + word.substr(1))
            .join(" ");
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var changed = false;

        if (controls.justPressed("up")) {
            select--;
            if (select < 0) select = songs.length - 1;
            curDiff = 0;
            changed = true;
        }

        if (controls.justPressed("down")) {
            select++;
            if (select >= songs.length) select = 0;
            curDiff = 0;
            changed = true;
        }

        if (controls.justPressed("left")) {
            curDiff--;
            if (curDiff < 0) curDiff = songs[select].difficulties.length - 1;
        }

        if (controls.justPressed("right")) {
            curDiff++;
            if (curDiff >= songs[select].difficulties.length) curDiff = 0;
        }

        if (controls.justPressed("escape"))
            CoolUtil.switchState(new MainMenuState());

        if (changed)
            updateList();

        if (FlxG.keys.justPressed.B)
            PlayState.isBotplay = !PlayState.isBotplay;

        if (controls.justPressed("accept")) {
            var songName = songs[select].song;
            var diff = songs[select].difficulties[curDiff];
            changeSong(songName, '-' + diff);
            bfOG.playAnim('confirm');

            new FlxTimer().start(0.8, function(tmr:FlxTimer) {
                CoolUtil.switchState(new PlayState());
            });
        }
    }

    public static function changeSong(song:String = "test", diff:String = "") {
        PlayState.SONG = Song.loadFromJson(song + diff, song);
        PlayState.diff = diff;
        PlayState.isFreeplay = true;
    }
}
