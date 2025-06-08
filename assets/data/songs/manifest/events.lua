local lastStep = 0
local codes = {}
local iconOffset = {}
local songTime = 0
local songTimeMax = 10000
local songTimePercent = 0

local blurTween = false

function setCamera(obj, cam)
    callMethod(obj..'.set_camera', {instanceArg(cam)})
    --callMethod(obj..'.set_camera', {getProperty(cam)})
end

function onCreate()
    makeLuaSprite('black', '', 0, 0)
    makeGraphic('black', 1300, 800, '000000')
    addLuaSprite('black')
    setCamera('black', 'camHUD')
    screenCenter('black')
    setProperty('black.alpha', 1)
end
function onCreatePost()
    luaDebugMode = true
    codes = getProperty('codes')
    setProperty('defaultCamZoom', 0.4)
    setProperty('camGame.zoom', 0.1)
    setProperty('floor.alpha', 0)
    
    makeLuaSprite('timeMax', '', 48)
    setProperty('timeMax.visible', false)
    
    makeLuaSprite('zoomBlur', '', 0, 0);
    makeLuaSprite('rgbZoom', '', 0, 0);
    makeLuaSprite('pixel', '', 1, 0);
    if shadersEnabled then
        initLuaShader('zoomBlur')
        initLuaShader('rgbZoom')
        initLuaShader('pixel')
        initLuaShader('lighting')
        initLuaShader('glitch')

        makeLuaSprite('glitch', '', 0, 0);
        setSpriteShader('glitch', 'glitch');

        setSpriteShader('zoomBlur', 'zoomBlur');
        setShaderFloat('zoomBlur', 'strength', 0);
        setShaderInt('zoomBlur', 'samples', 20);

        setSpriteShader('rgbZoom', 'rgbZoom');
        setShaderFloat('rgbZoom', 'amount', 0);
        setShaderInt('rgbZoom', 'distortionFactor', 0.05);

        setSpriteShader('pixel', 'pixel');
        setShaderFloat('pixel', 'pxSize', 1);

        runHaxeCode([[
            var filter1 = new ShaderFilter(game.getLuaObject('zoomBlur').shader);
            var filter2 = new ShaderFilter(game.getLuaObject('rgbZoom').shader);
            var filter3 = new ShaderFilter(game.getLuaObject('pixel').shader);
            var filter4 = new ShaderFilter(game.getLuaObject('glitch').shader);
    
            game.camHUD.setFilters([filter1, filter2]);
            game.camGame.setFilters([filter1, filter2, filter3]);
        ]]);
    end
    for i = 0, getProperty("unspawnNotes.length")-1 do
        if not getPropertyFromGroup("unspawnNotes", i, 'mustPress') and getPropertyFromGroup("unspawnNotes", i, 'strumTime') >= 7241 then
            setPropertyFromGroup("unspawnNotes", i, 'multSpeed', 1.5)
        end
    end
end
function onStepHit()
    if curStep >= 128 and curStep < 256 and curStep % 4 == 0 then
        playAnim('floor', 'bump', 'true')
    end
    if getProperty('dad.animation.curAnim.name') == 'idle' and curStep % 8 == 0 then
        playAnim('dad', 'idle', true)
    end
    for i = lastStep + 1, curStep do
        onStepEvent(i)
    end
    lastStep = curStep
end

local shake = 0
function onUpdate(elapsed)
    if not inGameOver then
        if curStep >= 112 and curStep < 128 then
            local intensity = rangePercent(112, 128)
            shake = intensity
            cameraShake("game", intensity*0.08, 0.02)
            cameraShake("hud", intensity*0.04, 0.02)
        elseif curStep >= 240 and curStep < 256 then
            local intensity = rangePercent(240, 256)
            shake = intensity
            cameraShake("game", intensity*0.08, 0.02)
            cameraShake("hud", intensity*0.04, 0.02)
        elseif curStep >= 560 and curStep < 576 then
            local intensity = rangePercent(560, 576)
            shake = intensity
            cameraShake("game", intensity*0.08, 0.02)
            cameraShake("hud", intensity*0.04, 0.02)
        elseif curStep >= 1104 and curStep < 1120 then
            local intensity = rangePercent(1104, 1120)
            shake = intensity
            cameraShake("game", intensity*0.08, 0.02)
            cameraShake("hud", intensity*0.04, 0.02)
        elseif curStep >= 1232 and curStep < 1248 then
            local intensity = rangePercent(1232, 1248)
            shake = intensity
            cameraShake("game", intensity*0.08, 0.02)
            cameraShake("hud", intensity*0.04, 0.02)
        elseif curStep >= 1504 and curStep < 1760 then
            local intensity = 0.2
            shake = intensity
            cameraShake("game", intensity*0.08, 0.02)
            cameraShake("hud", intensity*0.04, 0.02)
        elseif curStep >= 2000 and curStep < 2016 then
            local intensity = rangePercent(2000, 2016)
            shake = intensity
            cameraShake("game", intensity*0.08, 0.02)
            cameraShake("hud", intensity*0.04, 0.02)
        elseif shake > 0 then
            shake = tonumber(lerp(shake, 0, elapsed*10))
            cameraShake("game", shake*0.08, 0.02)
            cameraShake("hud", shake*0.04, 0.02)
        end
        if curStep >= 448 and curStep < 704 then
            for i = 4, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', getPropertyFromGroup('strumLineNotes', i, 'angle') + elapsed*80)
            end
        end
        iconOffset = {getProperty('iconP2.offset.x'), getProperty('iconP1.offset.y')}

        songTime = getSongPosition()
        songTimeMax = getProperty('timeMax.x')
        songTimePercent = songTime / (songTimeMax*1000)
        setProperty('songPercent', songTimePercent)
        if timeBarType == 'Time Left' then
            setProperty('timeTxt.text', disp_time(((songTimeMax*1000)-songTime)/1000))
        elseif timeBarType == 'Time Elapsed' then
            setProperty('timeTxt.text', disp_time(songTime/1000)) 
        end

        if curStep >= 448 and curStep < 704 then
            setProperty('camGame.angle', continuous_sin(curDecBeat/4)*5)
        end
        if curStep >= 992 and curStep < 1120 then
            setProperty('camGame.angle', continuous_sin(curDecBeat/4)*5)
        end
        if curStep >= 1504 and curStep < 1760 then
            setProperty('camGame.angle', continuous_sin(curDecBeat/4)*3)
        end

        if curStep >= 896 and curStep < 980 then
            setProperty('defaultCamZoom', lerp(0.85, 1, (curStep-896) / (980-896)))
        end
        if shadersEnabled and curStep >= 1504 then
            setShaderFloat('glitch', 'iTime', getSongPosition()/1000);
        end
    end
end

function rangePercent(min, max) 
    return (curStep - min + 2) / (max - min)
end
function onUpdatePost(elapsed)
    if not inGameOver then
        if curStep < 128 then
            setProperty('camFollow.x', 700)
            setProperty('camFollow.y', 548)
            setProperty('defaultCamZoom' ,lerp(0.1, 0.85, curStep / 128))
        end
        if shadersEnabled and blurTween then
            setShaderFloat('zoomBlur', 'strength', getProperty('zoomBlur.x'));
        end

        if getHealth() >= 1.8 then
            setProperty('iconP2.offset.x', getRandomFloat(-5, 5))
            setProperty('iconP2.offset.y', getRandomFloat(-5, 5))
        end
    end
end

function onSongStart()
    setProperty('acolor.alpha', 0)
    doTweenAlpha('black', 'black', 0, 1)
    doTweenAlpha('floorA', 'floor', 1, crochet/1000*4*4,'expoIn')
    doTweenAlpha('colorA', 'acolor', 0.5, crochet/1000*4*4,'expoIn')
    setProperty('updateTime', false)

    if shadersEnabled then
        startTween('pixelTween', 'pixel', {x = 0.01}, 3, {onUpdate = 'updatePIXELTween', onComplete = 'updatePIXELTween'})
    end
end

function onStepEvent(curStep)
    if curStep == 64 then
        for i, v in pairs(codes) do
            doTweenAlpha(v[1]..'a', v[1], i * 0.05 * 0.5, 3)
            setProperty(v[1]..'.velocity.x', v[2]*5)
            doTweenX(v[1]..'x', v[1]..'.velocity', v[2], 4, 'sineOut')
        end

        doTweenAlpha('bfshadow', 'bfshadow', 0.8, 3,'sineOut')
    doTweenAlpha('gfshadow', 'gfshadow', 0.8, 3,'sineOut')
    doTweenAlpha('skyshadow', 'skyshadow', 0.8, 3,'sineOut')
    end
    if curStep == 128 then
        setProperty('defaultCamZoom', 0.85)
    end
    if curStep == 296 then
        callMethod("moveCamera", {false})
    end
    if curStep == 328 then
        for i, v in pairs(codes) do
            doTweenX(v[1]..'x', v[1]..'.velocity', v[2]*5, crochet/500, 'sineIn')
        end
    end
    if curStep == 448 then
        playAnim('floor','idle',true)
        setVar('enableParticle', true)
    end
    if curStep == 576 then
        for i, v in pairs(codes) do
            doTweenX(v[1]..'x', v[1]..'.velocity', v[2], 4)
        end
    end
    if curStep == 256 or curStep == 704 then
        setProperty('camZoomingMult', 0)
        setProperty('camZoomingDecay', 1.25)
    end
    if curStep == 448 or curStep == 896 then
        setProperty('camZoomingMult', 1)
        setProperty('camZoomingDecay', 1)
    end
    if curStep == 704 then
        for i = 4, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end
        setProperty('cameraSpeed', 1.8)
        doTweenX('timeMax', 'timeMax', 74, 1, 'quadOut')
        setProperty('camGame.angle', 0)
    end
    if curStep == 896 then
        setVar('enableParticle', false)
        setProperty('black.alpha', 1)
        doTweenAlpha('black', 'black', 0, 2, 'sineIn')
        setProperty('gf.alpha', 0)
        setProperty('dad.alpha', 0)
        setProperty('eyes.alpha', 0)
        setProperty('iconP2.alpha', 0)
        setProperty('bfshadow.alpha', 0.5)
        setProperty('gfshadow.alpha', 0)
        setProperty('skyshadow.alpha', 0)

        setProperty("acolor.color", getColorFromHex("03dbfc"))
        setProperty("groundglow.color", getColorFromHex("03dbfc"))
        for i, v in pairs(codes) do
            cancelTween(v[1]..'a')
            setProperty(v[1]..".color", getColorFromHex("03dbfc"))
            setProperty(v[1]..'.alpha', i * 0.05 * 0.5)
        end

        for i = 0, 3 do
            noteTweenAlpha('alphaan'..i, i, 0, 2, 'quadIn')
        end
        doTweenAngle("camGameAn", "camGame", 0, 0.25, "quadOut")
    end
    if curStep == 900 then
        setProperty('cameraSpeed', 1)
    end
    if curStep == 986 then
        doTweenColor("acolorc", "acolor", "FF0000", getPropertyFromClass('backend.Conductor', 'crochet')/1000*1.4, "quadIn")
        doTweenColor("groundglowc", "groundglow", "FF0000", getPropertyFromClass('backend.Conductor', 'crochet')/1000*1.5, "quadIn")
        for i, v in pairs(codes) do
            doTweenColor(v[1].."vv", v[1], "FF0000", getPropertyFromClass('backend.Conductor', 'crochet')/1000*1.5, "quadIn")
        end
        for i = 0, 3 do
            noteTweenAlpha('alphaan'..i, i, 1, 0.5)
        end
        setProperty('defaultCamZoom', 0.85)
    end
    if curStep == 992 then
        setVar('enableParticle', true)
        cancelTween('acolorc')
        setProperty('acolor.alpha', 1)
        doTweenAlpha("acolora", "acolor", 0.5, 0.2)
        cameraFlash('hud', 'FF0000', 0.5, true)
        setProperty('gf.alpha', 1)
        setProperty('dad.alpha', 1)
        setProperty('eyes.alpha', 1)
        setProperty('iconP2.alpha', 1)
        setProperty('bfshadow.alpha', 0.8)
        setProperty('gfshadow.alpha', 0.8)
        setProperty('skyshadow.alpha', 0.8)
        for i, v in pairs(codes) do
            cancelTween(v[1]..'x')
            cancelTween(v[1]..'a')
            cancelTween(v[1]..'vv')
            setProperty(v[1]..'.velocity.x', v[2]*2)
            setProperty(v[1]..'.alpha', i * 0.05 * 0.5)
        end
        playAnim('floor','idle',true)

        doTweenX('timeMax', 'timeMax', 104, 1, 'quadOut')
    end




    if curStep == 1120 then
        setVar('enableParticle', false)
        setProperty('cameraSpeed', 16)

        setProperty("acolor.color", getColorFromHex("03dbfc"))
        setProperty("groundglow.color", getColorFromHex("03dbfc"))
        for i, v in pairs(codes) do
            cancelTween(v[1]..'a')
            setProperty(v[1]..".color", getColorFromHex("03dbfc"))
            setProperty(v[1]..'.alpha', i * 0.05 * 0.5)
        end

        playAnim('floor','bump',true)
        setProperty('camGame.angle', 0)
    end
    if curStep == 1132 then
        setProperty('camGame.alpha', 0)
    end
    if curStep == 1136 then
        setProperty('cameraSpeed', 1)
        setVar('enableParticle', true)
        setProperty('acolor.alpha', 0.7)
        cameraFlash('hud', 'FF0000', 0.5, true)

        for i, v in pairs(codes) do
            cancelTween(v[1]..'x')
            cancelTween(v[1]..'a')
            cancelTween(v[1]..'vv')
            setProperty(v[1]..'.velocity.x', v[2]*3)
            setProperty(v[1]..'.alpha', i * 0.05 * 0.5)
            setProperty(v[1]..'.color', getColorFromHex("FF0000"))
        end
        playAnim('floor','idle',true)
        setProperty('camGame.alpha', 1)
        setProperty('acolor.color', getColorFromHex("FF0000"))
        setProperty('groundglow.color', getColorFromHex("FF0000"))
    end
    if curStep == 1248 then
        setVar('enableParticle', false)
        doTweenAlpha('acolora', 'acolor', 0, 2)
        doTweenAlpha('bgold', 'bgOld', 1, 3)
        doTweenAlpha('bfshadow', 'bfshadow', 0, 3)
        doTweenAlpha('gfshadow', 'gfshadow', 0, 3)
        doTweenAlpha('skyshadow', 'skyshadow', 0, 3)
        setProperty('floor.alpha', 0)
        for i, v in pairs(codes) do
            doTweenColor(v[1].."vv", v[1], "80FFFFFF", 2)
            doTweenX(v[1]..'x', v[1]..'.velocity', v[2]*0.5, 3, 'sineOut')
        end
        playAnim('floor','bump',true)
    end
    if curStep == 1488 then
        doTweenX('timeMax', 'timeMax', getProperty('songLength')/1000, 1, 'quadOut')
    end
    if curStep == 1504 then
        cancelTween('bgold')
        setProperty('bgOld.alpha', 0)
        setProperty('cameraSpeed', 1)
        setVar('enableParticle', true)
        setProperty('acolor.alpha', 0.8)
        cameraFlash('hud', 'FF0000', 1, true)
        setProperty('floor.alpha', 1)
        setProperty('bfshadow.alpha', 0.9)
        setProperty('gfshadow.alpha', 0.9)
        setProperty('skyshadow.alpha', 0.9)

        if shadersEnabled then
            runHaxeCode([[
                var filter1 = new ShaderFilter(game.getLuaObject('zoomBlur').shader);
                var filter2 = new ShaderFilter(game.getLuaObject('rgbZoom').shader);
                var filter3 = new ShaderFilter(game.getLuaObject('pixel').shader);
                var filter4 = new ShaderFilter(game.getLuaObject('glitch').shader);

                game.camHUD.setFilters([filter1, filter2, filter4]);
                game.camGame.setFilters([filter1, filter2, filter3, filter4]);
            ]]);
        end

        for i, v in pairs(codes) do
            cancelTween(v[1]..'x')
            cancelTween(v[1]..'a')
            cancelTween(v[1]..'vv')
            setProperty(v[1]..'.velocity.x', v[2]*5)
            setProperty(v[1]..'.alpha', i * 0.05 * 0.5)
            setProperty(v[1]..'.color', getColorFromHex("FF0000"))
        end
        playAnim('floor','idle',true)
        setProperty('camGame.alpha', 1)
        setProperty('acolor.color', getColorFromHex("FF0000"))
        setProperty('groundglow.color', getColorFromHex("FF0000"))
    end
    if curStep == 1760 then
        setProperty('camGame.angle', 0)
    end
    if shadersEnabled and curStep == 1944 then
        startTween('pixelTween', 'pixel', {x = 3}, crochet/1000*2, {ease = 'quadOut',onUpdate = 'updatePIXELTween', onComplete = 'updatePIXELTween'})
    end
    if curStep == 1952 then
        cancelTween('pixelTween')
        setProperty('pixel.x', 0.01)
        updatePIXELTween()
    end
    if shadersEnabled and curStep == 2080 then
        runHaxeCode([[
            var filter1 = new ShaderFilter(game.getLuaObject('zoomBlur').shader);
            var filter2 = new ShaderFilter(game.getLuaObject('rgbZoom').shader);
            var filter3 = new ShaderFilter(game.getLuaObject('pixel').shader);

            game.camHUD.setFilters([filter1, filter2]);
            game.camGame.setFilters([filter1, filter2, filter3]);
        ]]);
    end
    if shadersEnabled and curStep == 2092 then
        startTween('pixelTween', 'pixel', {x = 8}, crochet/1000*14, {ease = 'quadIn',onUpdate = 'updatePIXELTween', onComplete = 'updatePIXELTween'})
    end
end

function blurFlash(value, duration)
    setProperty('zoomBlur.x', value)
    doTweenX('blurTween', 'zoomBlur', 0, duration)
    blurTween = true
end


function onTweenCompleted(tag)
    if tag == 'blurTween' then
        blurTween = false
    end
end

function updateRGBTween(tag, vars)
    if shadersEnabled then
        setShaderFloat('rgbZoom', 'amount', getProperty('rgbZoom.x'));
    end
end

function updatePIXELTween(tag, vars)
    if shadersEnabled then
        setShaderFloat('pixel', 'pxSize', getProperty('pixel.x'));
    end
end

function updatebfshadowTween(tag, vars)
    if shadersEnabled then
        setShaderFloat('boyfriend', '_alpha', getProperty('pixel.x'));
    end
end

function onMoveCamera(character)
    if curStep >= 704 and curStep < 896 then
        if character == 'dad' then
            doTweenAngle('camGameAn', 'camGame', -10, 0.9, 'quadOut')
        else
            doTweenAngle('camGameAn', 'camGame', 10, 0.9, 'quadOut')
        end
    end
end


function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Add Camera Zoom' then
        local multiply = curStep >= 2000 and 4 or 1
        if tonumber(value1) >= 0.01 then
            setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.1)
            blurFlash(0.25, crochet/1000)
            setProperty('rgbZoom.x', 0.5)
            startTween('test', 'rgbZoom', {x = 0}, crochet/1000*multiply, {ease = 'quadOut',onUpdate = 'updateRGBTween', onComplete = 'updateRGBTween'})

            if getHealth() >= 0.4 then
                addHealth(-0.05)
                setProperty('iconP1.color', 0)
                doTweenColor('iconP1F', 'iconP1', 'FFFFFF', 0.5)
            end
            setProperty('bfshadow.alpha', 0)
            doTweenAlpha('bfshadow', 'bfshadow', 0.8, crochet/1000*multiply)
            if curStep < 980 or curStep >= 992 then
                setProperty('gfshadow.alpha', 0)
                setProperty('skyshadow.alpha', 0)
                doTweenAlpha('gfshadow', 'gfshadow', 0.8, crochet/1000*multiply)
                doTweenAlpha('skyshadow', 'skyshadow', 0.8, crochet/1000*multiply)
            end

        else
            for i, v in pairs(codes) do
                setProperty(v[1]..'.velocity.x', v[2]*2)
                setProperty(v[1]..'.alpha', (0.9 + getRandomFloat(-0.1, 0.1)) * i * 0.08)
                doTweenX(v[1]..'x', v[1]..'.velocity', v[2]*0.05, crochet/1000*1.5*multiply, 'sineOut')
                doTweenAlpha(v[1]..'a', v[1], i * 0.05 * 0.5, crochet/1000*1.5*multiply, 'sineOut')
            end
        end
    end
end


function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if getHealth() >= 0.2 then
        addHealth(-0.005 * (isSustainNote and 0.25 or 1) * (healthLossMult))
    end
end

function lerp(a, b, t)
	return a + (b - a) * t
end

function continuous_sin(x)
    return math.sin((x % 1) * 2*math.pi)
end

function disp_time(time)
    local minutes = math.floor((time%3600)/60)
    local seconds = math.floor((time%60))
    return string.format("%01d:%02d",minutes,seconds)
end