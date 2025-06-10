package misc.meta.states;

import data.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import lime.app.Application;
import objects.menus.BFAnimate;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;
import misc.meta.states.MainMenuState;

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
    var songTexts:Array<FlxText> = [];
    var diffText:FlxText;

    override function create()
    {
        super.create();

        loadSongs();

        bfOG = new BFAnimate(0, -100);
        bfOG.playAnim('first');
        add(bfOG);

        for (i in 0...songs.length)
        {
            var text = new FlxText(0, 0, FlxG.width, songs[i].song.toUpperCase(), 32);
            text.setFormat(Paths.getFont('5by7_b', 'ttf'), 32, 0xFFFFFFFF, "center");
            songTexts.push(text);
            add(text);
        }

        diffText = new FlxText(0, FlxG.height - 60, FlxG.width, "", 24);
        diffText.setFormat(Paths.getFont('vcr', 'ttf'), 24, 0xFFFFAA00, "center");
        add(diffText);

        updateList();
    }

    function loadSongs()
    {
        var pathMods = 'mods/weeks/freeplay.json';
        var pathAssets = 'assets/weeks/freeplay.json';

        var jsonRaw:String = null;
        if (FileSystem.exists(pathMods)) {
            jsonRaw = File.getContent(pathMods);
        } else if (Assets.exists(pathAssets)) {
            jsonRaw = Assets.getText(pathAssets);
        }

        if (jsonRaw != null)
            songs = haxe.Json.parse(jsonRaw);
        else
            songs = [];
    }

    function updateList()
    {
        var diff = songs[select].difficulties[curDiff];
        diffText.text = "Difficulty: " + diff.toUpperCase();

        for (i in 0...songTexts.length)
        {
            var text = songTexts[i];

            var pos = i - select;
            var absPos = Math.abs(pos);
            var direction = pos < 0 ? -1 : 1;
            var flip = (absPos % 10 >= 5) ? -1 : 1;

            text.y = Math.abs((FlxG.height / 2) + pos * 60);
            text.x = Math.abs((FlxG.width / 2) + flip * direction * absPos * 25);

            text.alpha = (i == select) ? 1 : 0.6;
            var scale = (i == select) ? 1.2 : 0.9;
            text.scale.set(scale, scale);

            text.x -= text.width / 2;
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var changed = false;

        if (controls.justPressed("up"))
        {
            select--;
            if (select < 0) select = songs.length - 1;
            curDiff = 0;
            changed = true;
        }

        if (controls.justPressed("down"))
        {
            select++;
            if (select >= songs.length) select = 0;
            curDiff = 0;
            changed = true;
        }

        if (controls.justPressed("left"))
        {
            curDiff--;
            if (curDiff < 0) curDiff = songs[select].difficulties.length - 1;
        }

        if (controls.justPressed("right"))
        {
            curDiff++;
            if (curDiff >= songs[select].difficulties.length) curDiff = 0;
        }

        if(controls.justPressed('escape'))
            CoolUtil.switchState(new MainMenuState());

        if (changed)
            updateList();

        if (FlxG.keys.justPressed.B)
            PlayState.isBotplay = !PlayState.isBotplay;

        if (controls.justPressed("accept"))
        {
            var songName = songs[select].song;
            var diff = songs[select].difficulties[curDiff];
            changeSong(songName, '-' + diff);
            bfOG.playAnim('confirm');

            new FlxTimer().start(0.8, function(tmr:FlxTimer)
            {
                CoolUtil.switchState(new PlayState());
            });
        }
    }

    public static function changeSong(song:String = "test", diff:String = "")
    {
        PlayState.SONG = Song.loadFromJson(song + diff, song);
        PlayState.diff = diff;
        PlayState.isFreeplay = true;
    }
}
