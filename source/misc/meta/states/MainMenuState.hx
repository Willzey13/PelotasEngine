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

class MainMenuState extends MusicBeatState
{
    var optionSheet:Array<String> = [
        'story_mode', 'freeplay', 'merch', 'donate', 'credits'
    ];
    
    var optionGrp:FlxTypedGroup<FlxSprite>;
    
    var background:FlxSprite;
    var magentaBG:FlxSprite;
    var camFollow:FlxObject;
    
    var scr:Float;
    static var currentSelect:Int = 0;
   
    override function create() {
        super.create();

        // #if desktop
        // DiscordClient.changePrecense('choosing a game mode in the main menu!');
        // #end https://www.makeship.com/shop/creator/friday-night-funkin

        // transIn = FlxTransitionableState.defaultTransIn;
		// transOut = FlxTransitionableState.defaultTransOut;

        var yPos = 50; // exemplo simples
        var yPosBg:Float = Math.max(0.20 - (0.05 * (optionSheet.length - 5)), 0.1);
        background = new FlxSprite(0, yPos).loadGraphic(Paths.image('mainmenu/menuBG'));
        background.scrollFactor.set(0, yPosBg);
        background.scale.set(1.20,1.20);
        background.screenCenter(X);
        add(background);
        
        magentaBG = new FlxSprite().loadGraphic(Paths.image('mainmenu/menuDesat'));
        magentaBG.scale.set(background.scale.x, background.scale.y);
        magentaBG.visible = false;
        magentaBG.updateHitbox();
        add(magentaBG);

        camFollow = new FlxObject(0, 0, 1, 1);
        add(camFollow);

        optionGrp = new FlxTypedGroup<FlxSprite>();
        add(optionGrp);

        for (i in 0...optionSheet.length)
        {
            var offset:Float = 108 - (Math.max(optionSheet.length, 5) - 5) * 80;
            var menuItem:FlxSprite = new FlxSprite(0, (i * 157) + offset);
            // menuItem.antialiasing = ClientPrefs.data.antialiasing;
           	menuItem.frames = Paths.getSparrowAtlas('mainmenu/' + optionSheet[i]);
			menuItem.animation.addByPrefix('idle', optionSheet[i] + " idle", 24);
			menuItem.animation.addByPrefix('selected', optionSheet[i] + " selected", 24);
			menuItem.animation.play('idle');
            menuItem.ID = i;
			optionGrp.add(menuItem);
			
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			menuItem.screenCenter(X);

        	if (optionSheet.length < 5)
		    	scr = 0;
            else 
                scr = (optionSheet.length - 5) * 0.135;
        }

        curOptions(currentSelect);
        FlxG.camera.follow(camFollow, null, 0.06);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.justPressed("up"))
        {
            curOptions(-1);
        }

        if (controls.justPressed("down"))
        {
            curOptions(1);
        }

        if (controls.justPressed("accept"))
        {
            var selectedOption = optionSheet[currentSelect];
    
            switch (selectedOption)
            {
                case 'freeplay':
                    CoolUtil.switchState(new FreeplayState());
            }
        }
    }

    public function curOptions(curOption:Int):Void
    {
        var len = optionGrp.length;
        currentSelect = ((currentSelect + curOption) % len + len) % len;

        for (i in 0...optionGrp.length)
        {
            var item = optionGrp.members[i];
            if (item != null)
            {
                if (item.ID == currentSelect)
                {
                    item.animation.play('selected');
                    item.centerOffsets();
                    camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y);
                }
                else
                {
                    item.animation.play('idle');
                    item.centerOffsets();
                }
            }
        }
    }
}