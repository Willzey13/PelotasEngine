package misc.meta.states;

import data.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import misc.meta.states.MainMenuState;
import objects.menus.BFAnimate;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

typedef FreeplayEntry = {
    var song:String;
    var difficulties:Array<String>;
}

class FreeplayState extends MusicBeatState {
    public var songs:Array<FreeplayEntry> = [];
    public var select:Int = 0;
    public var curDiff:Int = 0;

    var bfOG:BFAnimate;
    var diffText:FlxText;
    var songBoxes:Array<FlxGroup> = [];

    override function create() {
        super.create();

        loadSongs();

        bfOG = new BFAnimate(0, -100);
        bfOG.playAnim('first');
        add(bfOG);

        for (i in 0...songs.length) {
            var group = createCapsule(songs[i].song.toUpperCase(), i);
            songBoxes.push(group);
            add(group);
        }

        diffText = new FlxText(0, FlxG.height - 40, FlxG.width, "", 24);
        diffText.setFormat(Paths.getFont('vcr', 'ttf'), 24, FlxColor.YELLOW, "center");
        add(diffText);

        updateList();
    }

    function loadSongs() {
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

    function createCapsule(text:String, index:Int):FlxGroup {
        var group = new FlxGroup();

        var capsule = new FlxSprite().makeGraphic(300, 50, FlxColor.BLACK);
        capsule.alpha = 0.7;
        capsule.updateHitbox();

        var label = new FlxText(0, 0, 300, text, 28);
        label.setFormat(Paths.getFont('5by7_b', 'ttf'), 28, FlxColor.WHITE, "center");
        label.borderStyle = FlxTextBorderStyle.OUTLINE;
        label.borderColor = FlxColor.BLACK;

        group.add(capsule);
        group.add(label);

        return group;
    }

    function updateList() {
        var diff = songs[select].difficulties[curDiff];
        diffText.text = "Difficulty: " + diff.toUpperCase();

        var centerY = FlxG.height / 2;
        var spacingY = 60;

        for (i in 0...songBoxes.length) {
            var group = songBoxes[i];
            var capsule = cast(group.members[0], FlxSprite);
            var label = cast(group.members[1], FlxText);

            var pos = i - select;
            var y = centerY + pos * spacingY;
            var wave = Math.sin(pos * 0.5) * 80; // curva em S

            capsule.x = FlxG.width / 2 + wave - capsule.width / 2;
            capsule.y = y;
            label.x = capsule.x;
            label.y = capsule.y + 10;

            var alpha = (i == select) ? 1 : 0.6;
            var scale = (i == select) ? 1.2 : 1.0;

            capsule.alpha = alpha;
            label.alpha = alpha;
            capsule.scale.set(scale, scale);
            label.scale.set(scale, scale);
        }
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
