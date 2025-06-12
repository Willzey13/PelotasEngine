package misc.meta.states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
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
import misc.meta.states.MainMenuState;
import objects.menus.*;
import flixel.util.FlxSort;

// import js.html.Client;
using StringTools;

class CreditsState extends MusicBeatState
{
    var credArray:Array<Array<Dynamic>> = [ // nome | icone | descricao | cor | url
        ['Pelotas Engine Team', 'none'],
        ['Willzinhu', 'will', 'Main coder', 0xFFFF7700, 'https://x.com/wilzey13lol'],
        ['JDaniel Aleatorio', 'jdaniel', 'Another coder?', 0xFF21D817, 'https://www.youtube.com/@JDanielAleatorio'],
        ['Peanut Cut', 'jdaniel', 'Damn 3 fucking coders', 0xFFF4FF58, 'https://x.com/peanut_cut'],
        ['Thurz', 'jdaniel', 'Bro?? 4 coders?????? ', 0xFFF4FF58, 'https://x.com/peanut_cut'],
        ['PHR Gamer BR', 'jdaniel', "Looks like we got a gamer in the area...\n(yes, he's also a coder, we got 5 coders...)", 0xFFF4FF58, 'https://x.com/peanut_cut'],
        ['Sigma Is Basic!', 'none'],
        ['Baldi', 'baldi', 'Awesome teacher!', 0xFF00FF00, 'https://store.steampowered.com/app/1275890/Baldis_Basics_Plus/'],
    ];

    var background:FlxSprite;

    var namesGroup:FlxTypedGroup<AlphabetGroup>; // vou ter que arrumar isso depois ou sei lá (arrumei já)
    var iconsGroup:FlxTypedGroup<FlxSprite>;
    var categoryText:AlphabetGroup;

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

        namesGroup = new FlxTypedGroup<AlphabetGroup>();
        add(namesGroup);
        iconsGroup = new FlxTypedGroup<FlxSprite>();
        add(iconsGroup);

        for(i in 0...credArray.length)
        {
            var broName = new AlphabetGroup(credArray[i][0], Center);
            broName.setX(FlxG.width/2);
            broName.ID = i;
            broName.visible = credArray[i][2]!=null;
            namesGroup.add(broName);
 
            var icon1 = new FlxSprite(0,0,Paths.image('credits/'+credArray[i][1]));
            icon1.visible = credArray[i][1] != 'none';
            icon1.x = broName.x-(broName.width/2+icon1.width+10);
            icon1.ID = i;
            icon1.flipX = true;
            iconsGroup.add(icon1);

            var icon2 = new FlxSprite(0,0, Paths.image('credits/${credArray[i][1]}'));
            icon2.x = broName.x+(broName.width/2)+10;
            icon2.ID = i;
            icon2.visible = credArray[i][1] != 'none';
            iconsGroup.add(icon2);
        }

        categoryText = new AlphabetGroup(credArray[0][0], Center);
        add(categoryText);

        box = new FlxSprite(640, 709).makeGraphic(1, 1, 0xFF000000);
        box.alpha = 0.5;
        add(box);

        text = new FlxText(0,0,0,'',32);
        text.setFormat('vcr.ttf', 32, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        text.borderSize = 2;
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

        if(controls.justPressed('escape'))
            CoolUtil.switchState(new MainMenuState());

        lerpsAndShit(elapsed);
    }

    function changeMyBalls(sus:Int)
    {
        selectingWho = FlxMath.wrap(selectingWho+sus, 0, credArray.length-1);

        categoryText.deleteText(getCurCat(selectingWho), Center); 
        categoryText.setPosition(FlxG.width/2, 50);

        if(credArray[selectingWho][2] == null) { 
            changeMyBalls(sus); 
            return; 
        }

        FlxTween.cancelTweensOf(background);
        FlxTween.color(background, 0.5, background.color, credArray[selectingWho][3]);

        FlxTween.cancelTweensOf(text);
        text.text = credArray[selectingWho][2];
        text.screenCenter(X);
        text.y = FlxG.height-text.height-10;
        box.y = text.y-5;

        FlxTween.tween(text, {y: FlxG.height-text.height-30}, 0.25);
    }

    function getCurCat(newton) // sei la
    {
        var returningValue = ' ';
        for(i in 0...newton+1)
            if(credArray[Math.floor(Math.abs(i-newton))][2] == null) {
                returningValue = credArray[Math.floor(Math.abs(i-newton))][0];
                break;
            }

        return returningValue;
    }

    // lerps and other shit
    function lerpsAndShit(elapsed:Float) {
        box.scale.set(FlxMath.lerp(box.scale.x, text.width+10, elapsed*8), FlxMath.lerp(box.scale.y, text.height+10, elapsed*8));
        box.updateHitbox();
        box.setPosition(FlxMath.lerp(box.x, text.x-5, elapsed*8), FlxMath.lerp(box.y, text.y-5, elapsed*8));

        for(i => spr in namesGroup) {
            var itemSize = FlxMath.bound(1-((Math.abs(spr.ID-selectingWho)/10)*2.5), 0, 1);
            spr.setY(FlxMath.lerp(spr.y, ((FlxG.height/2)+((spr.ID-selectingWho)*200)*itemSize), elapsed*8));
            spr.setAlpha(FlxMath.lerp(spr.alpha, itemSize, elapsed*8));
            spr.setScale(FlxMath.lerp(spr.scaleX, FlxMath.bound(itemSize*1.25, 0, 1), elapsed*8), FlxMath.lerp(spr.scaleY, FlxMath.bound(itemSize*1.25, 0, 1), elapsed*8));
            for(icon in iconsGroup) {
                if(icon.ID == spr.ID) {
                    icon.y = spr.y-icon.height/3;
                    icon.alpha = spr.alpha;
                    icon.scale.set(spr.scaleX, spr.scaleY);
                    //icon.x = broName.x+(broName.width/2), broName.y-75;
                }
            }
        }
    }
}