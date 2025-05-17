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
        'story_mode', 'freeplay', 'merch', 'merch', 'credits', 'options'
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

        var yPos = 30; // exemplo simples (exemplo do que mano)
        var yPosBg:Float = Math.max(0.20 - (0.05 * (optionSheet.length - 5)), 0.1);
        background = new FlxSprite(0, yPos).loadGraphic(Paths.image('mainmenu/menuBG'));
        background.scrollFactor.set(0, yPosBg);
        background.scale.set(1.20,1.20);
        background.screenCenter(X);
        add(background);
        
        magentaBG = new FlxSprite(background.x, background.y).loadGraphic(Paths.image('mainmenu/menuBGMagenta'));
        magentaBG.scrollFactor.set(0, yPosBg);
        magentaBG.scale.set(1.2, 1.2);
        magentaBG.visible = false;
        magentaBG.screenCenter(X);
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
			
            scr = optionSheet.length < 5 ? 0 : (optionSheet.length - 5) * 0.135;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			menuItem.screenCenter(X);
        }

        var theText = 'Turma Do Chaves: V1.0.0\nPelotas Engine: V0.1.0';
        var credOnShit = new FlxText(5, 5, 0, theText, 16);
        credOnShit.setFormat('_sans', 16, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000); // trocar a fonte quando ela estiver no jogo
        credOnShit.y = FlxG.height-credOnShit.height-5; // nao da para nolocar isso antes :sob:
        credOnShit.scrollFactor.set();
        add(credOnShit);

        curOptions(currentSelect);
        FlxG.camera.follow(camFollow, null, 0.06);
    }

    var canChange = true;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(canChange) {
            if (controls.justPressed("up"))
                curOptions(-1);

            if (controls.justPressed("down"))
                curOptions(1);

            if (controls.justPressed("accept"))
                acceptSomeBigShit();
        }

        for(option in optionGrp)
            option.y = optionSheet.length >= 5 ? FlxMath.lerp(option.y, (-50*currentSelect+157*option.ID)+75, elapsed*8) : (157 * option.ID)+75; // vai todo mundo se fuder
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
                    camFollow.setPosition(item.getGraphicMidpoint().x, optionSheet.length >= 4 ? (-48*currentSelect+160*item.ID)+185+(Math.abs(5*optionSheet.length-5)) : background.getGraphicMidpoint().y); // sou bom em matematica? talvez (nao)
                }
                else
                {
                    item.animation.play('idle');
                    item.centerOffsets();
                }
            }
        }
    }

    public function acceptSomeBigShit()
    {
        var selectedOption = optionSheet[currentSelect];
        canChange = false;

        FlxFlicker.flicker(optionGrp.members[currentSelect], 0.75, 0.1, true); // colocar para desabilitar com quando desativar o flash
        FlxFlicker.flicker(magentaBG, 0.75, 0.1, false, false, function(a:FlxFlicker) {
            switch (selectedOption)
            {
                case 'freeplay': CoolUtil.switchState(new FreeplayState());
                case 'merch': FlxG.openURL('https://needlejuicerecords.com/pages/friday-night-funkin'); canChange = true; return;
                default: canChange = true; return;
            }

            for(item in optionGrp)
                FlxTween.tween(item, {alpha: 0}, 0.5);
        });
    }
}