package misc.meta.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

// import js.html.Client;
using StringTools;

class CreditsState extends MusicBeatState
{
    var credArray:Array<Array<Dynamic>> = [ // nome | icone | descricao | cor | url
        ['Pelotas Engine Team', 'none'],
        ['Willzinhu', 'will', 'Main coder', 0xFFFF7700, 'https://x.com/wilzey13lol'],
        ['JDaniel Aleatorio', 'jdaniel', 'Another coder?', 0xFF21D817, 'https://www.youtube.com/@JDanielAleatorio']
    ];

    var background:FlxSprite;
    var namesGroup:FlxTypedGroup<FlxText>; // vou ter que arrumar isso depois ou sei lá

    var iconsGroup:FlxTypedGroup<FlxSprite>;
    var box:FlxSprite;
    var text:FlxText;

    var selectingWho:Int = 1;
   
    override function create() {
        super.create();

        background = new FlxSprite(0, 0).loadGraphic(Paths.image('mainmenu/menuDesat'));
        background.scale.set(1.20,1.20);
        background.color = credArray[1][3];
        background.screenCenter(X);
        add(background);

        namesGroup = new FlxTypedGroup<FlxText>();
        add(namesGroup);
        iconsGroup = new FlxTypedGroup<FlxSprite>();
        add(iconsGroup);

        for(i in 0...credArray.length)
        {
            var broName = new FlxText(0,25+160*i,0,credArray[i][0], 32);
            broName.screenCenter(X);
            namesGroup.add(broName);
 
            var icon1 = new FlxSprite(broName.x-150, broName.y-75, Paths.image('credits/'+credArray[i][1]));
            icon1.visible = credArray[i][1] != 'none';
            icon1.flipX = true;
            iconsGroup.add(icon1);

            var icon2 = new FlxSprite(broName.x+broName.width, broName.y-75, Paths.image('credits/${credArray[i][1]}'));
            icon2.visible = credArray[i][1] != 'none';
            iconsGroup.add(icon2);
        }

        box = new FlxSprite(640, 709).makeGraphic(1, 1, 0xFF000000);
        box.alpha = 0.5;
        add(box);

        text = new FlxText(0,0,0,'',32);
        text.setFormat('_sans', 32, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000); // trocar a fonte quando ela estiver no jogo
        add(text);

        changeMyBalls(0);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.justPressed("up"))
            changeMyBalls(-1);

        if (controls.justPressed("down"))
            changeMyBalls(1);

        if(controls.justPressed('accept'))
            FlxG.openURL(credArray[selectingWho][4]);

        box.scale.set(FlxMath.lerp(box.scale.x, text.width+10, elapsed*8), FlxMath.lerp(box.scale.y, text.height+10, elapsed*8));
        box.updateHitbox();
        box.setPosition(FlxMath.lerp(box.x, text.x-5, elapsed*8), FlxMath.lerp(box.y, text.y-5, elapsed*8));
    }

    function changeMyBalls(sus:Int)
    {
        namesGroup.members[selectingWho].alpha = 1;
        
        var len = credArray.length;
        selectingWho = ((selectingWho + sus) % len + len) % len;
        if(credArray[selectingWho][2] == null) { changeMyBalls(sus); return; }

        namesGroup.members[selectingWho].alpha = 0.5;

        FlxTween.cancelTweensOf(background);
        FlxTween.color(background, 0.5, background.color, credArray[selectingWho][3]);

        FlxTween.cancelTweensOf(text);
        text.text = credArray[selectingWho][2];
        text.screenCenter(X);
        text.y = FlxG.height-text.height-10;

        FlxTween.tween(text, {y: FlxG.height-text.height-30}, 0.25);
    }
}