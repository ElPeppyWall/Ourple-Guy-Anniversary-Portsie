import flixel.effects.FlxFlicker;
import psychlua.LuaUtils;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.text.FlxTextFormatMarkerPair;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;

var noPause;
var noPauseTime = 0;
var beatsPerZoom = 2;

var camZoom = true;

var extraAdd = 0;

var black;
var cut;

var ending;
var blackScreen;

var pizzaGrp:FlxTypedGroup; var starGrp:FlxTypedGroup;
var creditFrame;
var creditTxt:FlxText;
//tbh i shouldve used the hscript hud setup for this so it isnt weird workarounds for hud changes butwhatever
function onCreate() 
{
    var y = 25;
    var bg = new FlxSprite(0,y).loadGraphic(Paths.image('bgs/gradient'));
    addBehindGF(bg);

    var floor = new FlxSprite(0,y).loadGraphic(Paths.image('bgs/bg'));
    addBehindGF(floor);

    var overlay = new FlxSprite(0,y).loadGraphic(Paths.image('bgs/overlay'));
    add(overlay);
    overlay.blend = 1;
    overlay.alpha = 0.3;

    for (i in [bg,floor,overlay]) {
        i.antialiasing = false;
    }

    cut = new FlxSprite();
    cut.frames = Paths.getSparrowAtlas('bgs/cut');
    cut.animation.addByPrefix('i','frame',10,false);
    cut.cameras = [game.camHUD];
    cut.setGraphicSize(FlxG.width);
    cut.updateHitbox();
    add(cut);

    cut.animation.finishCallback = (s)->{
        cut.visible = false;
        FlxG.camera.flash(FlxColor.WHITE,0.3);
    }
    
    blackScreen = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
	blackScreen.scrollFactor.set();
    blackScreen.cameras = [camOther];
    add(blackScreen);
}

function onCreatePost() {
    game.timeBar.visible = false;
    game.timeTxt.visible = false;

    FlxG.camera.snapToTarget();

    noPause = new FlxSprite().loadGraphic(Paths.image('noPause'));
    noPause.cameras = [camOther];
    add(noPause);
    noPause.screenCenter();
    noPause.alpha = 0;

    ending = new FlxSprite().loadGraphic(Paths.image('bgs/ending'));
    ending.cameras = [camOther];
    add(ending);
    ending.scale.set(0.5,0.5);
    ending.updateHitbox();
    ending.screenCenter();
    ending.visible = false;

    creditFrame = new FlxSprite().loadGraphic(Paths.image('ui/credit'));
    creditFrame.scale.set(1.5,1.5);
    creditFrame.updateHitbox();
    creditFrame.setPosition(-creditFrame.width, 90);
    creditFrame.cameras = [camOther];
    add(creditFrame);

    creditTxt = new FlxText(0,creditFrame.y+10,creditFrame.width);
    creditTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    creditTxt.text = "@FREDDYGAME@\nLEX3X\nREDTV53\nWRATHSTETIC\n\n@ART@\nYUMII\nLOSS\nMEWMARISSA\n\n@CODING@\nDATA\n\n@CHARTING@\nSRIFE5\n\n@PORTING@\nTEDYES & PEPPY";

    creditTxt.applyMarkup(creditTxt.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.WHITE,true,false,0xFFCB00E5),'@'),new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.WHITE),'^^')]);
    creditTxt.x = creditFrame.x;
    creditFrame.setGraphicSize(Std.int(creditFrame.width),Std.int(creditTxt.height)+25);
    creditFrame.updateHitbox();

    creditTxt.cameras = [camOther];
    add(creditTxt);

    game.scoreTxt.font = Paths.font('f.otf');
    game.scoreTxt.fieldWidth = 0;

    game.scoreTxt.size = 30;

    game.scoreTxt.setPosition(
        40,
        game.healthBar.y + (game.healthBar.height - game.scoreTxt.height)/2 
    );

    if(game.P2scoreTxt != null){
        game.P2scoreTxt.font = Paths.font("f.otf");
        game.P2scoreTxt.fieldWidth = 0;
        game.P2scoreTxt.size = 30;
        game.P2scoreTxt.setPosition(
            FlxG.width - 300,
            game.healthBar.y + (game.healthBar.height - game.P2scoreTxt.height)/2 
        );
    }

    game.iconP1.flipX = true;
    game.iconP2.flipX = true;

    game.healthBar.flipX = true;
    game.healthBar.y -= 20;

    game.camZoomingMult *= 2;

    starGrp = new FlxTypedGroup<FlxSprite>();
    insert(members.indexOf(uiGroup) + 1, starGrp);

    for(i in 0 ... 5)
    {
        var star = new FlxSprite(game.healthBar.x + (80 * i) + 40, game.healthBar.y - 10);
        star.frames = Paths.getSparrowAtlas('ui/star');
        star.animation.addByPrefix('bop','star', 30, false);
        star.animation.addByIndices('still', 'star', [19], "", 30, true);
        star.animation.play('still', true);
        star.cameras = [game.camHUD];
        star.scale.set(0.8,0.8);
        starGrp.add(star); //star.animation.play('idle', true);
    }
}

function onSongStart() {
    var oppPos = [for (i in game.opponentStrums) i.x];
    for (i in 0...4) {
        if (!ClientPrefs.data.middleScroll){
            game.opponentStrums.members[i].x = game.playerStrums.members[i].x;
            game.playerStrums.members[i].x = oppPos[i];
        }
    }

    cut.animation.play('i');
    FlxTween.tween(blackScreen, {alpha: 0}, 1, {ease: FlxEase.cubeIn});
    beatsPerZoom = 22222222;
}

function onSectionHit() {

    moveCam(!mustHitSection);

    FlxG.camera.snapToTarget();
}

function onUpdateScore(mi) {
    game.scoreTxt.text = 'Score: ' + game.songScore;
    game.scoreTxt.scale.set(1,1);

    if(game.P2scoreTxt != null){
        game.P2scoreTxt.text = 'Score: ' + game.P2songScore;
        game.P2scoreTxt.scale.set(1,1);
    }
}

function moveCam(isDad) {
    if(isDad)
    {
        game.camFollow.setPosition(610.5, 238.5);
        FlxG.camera.zoom = game.defaultCamZoom = 1.6;
    }
    else
    {
        game.camFollow.setPosition(317.5, 297.5);
        FlxG.camera.zoom = game.defaultCamZoom = 2.2 + extraAdd;
    }
}

function onUpdatePost(elapsed){
    game.iconP2.setPosition(game.healthBar.x+game.healthBar.width-100,game.healthBar.y-75);
	game.iconP1.setPosition(game.healthBar.x-100,game.healthBar.y-75);

    game.isCameraOnForcedPos = true;
    game.camZooming = false;

    FlxG.camera.zoom = FlxMath.lerp(game.defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 6.25 * camZoomingDecay * playbackRate));
    game.camHUD.zoom = FlxMath.lerp(1, game.camHUD.zoom, Math.exp(-elapsed * 6.25 * camZoomingDecay * playbackRate));

    game.canPause = false;

    if (controls.PAUSE) {
        FlxG.sound.play(Paths.sound('cancelMenu'));
        noPauseTime = 1;
    }

    noPause.alpha = FlxMath.bound(noPauseTime,0,1);

    noPauseTime -= elapsed;

    for (lmao in 0 ... game.grpNoteSplashes.length){
        game.grpNoteSplashes.members[lmao].scale.set(0.8, 0.8);
        game.grpNoteSplashes.members[lmao].alpha = 1;
    }

    updateRatingStuff();
}

function onBeatHit() {
    if (curBeat % beatsPerZoom == 0)
    {
        FlxG.camera.zoom += 0.015 * (camZoomingMult * 2);
        game.camHUD.zoom += 0.03 * camZoomingMult;
    }

    switch (curBeat){
        case 30:
            FlxTween.tween(creditTxt, {x: 10},1, {ease: FlxEase.cubeOut});
            FlxTween.tween(creditFrame, {x: 10}, 1, {ease: FlxEase.cubeOut, onComplete: function (f:FlxTween) {
                FlxTween.tween(creditTxt, {x: -creditFrame.width},1.5, {startDelay: 2,ease: FlxEase.cubeIn});
                FlxTween.tween(creditFrame, {x: -creditFrame.width},1.5, {startDelay: 2,ease: FlxEase.cubeIn, onComplete: function (f:FlxTween) {
                    remove(creditFrame);
                    creditFrame.destroy();
                    remove(creditTxt);
                    creditTxt.destroy();
                }});
            }});
    }

    starGrp.forEach(function(item:FlxSprite) {
        if(misses < 5){
            if(curBeat % 4 == 0)
            {
                item.animation.play("bop", true);
            }
        }
        else 
            item.animation.play('still', true);
    });
}

function updateRatingStuff() {
    if (misses > 0){
        for (i in 0...starGrp.members.length)
        {
            if (ratingPercent * 100 > 95)
            {
                starCheck(i, 100);
            }
            else if (ratingPercent * 100 > 90)
            {
                starCheck(i, 5);
            }
            else if (ratingPercent * 100 > 80)
            {
                starCheck(i, 4);
            }
            else if (ratingPercent * 100 > 70)
            {
                starCheck(i, 3);
            }
            else if (ratingPercent * 100 > 60)
            {
                starCheck(i, 2);
            }
            else if (ratingPercent * 100 > 50)
            {
                starCheck(i, 1);
            }
        }
    }else{
        for (i in 0...starGrp.members.length)
        {
            starCheck(i, 100);
        }
    }
}

function starCheck(i:Int, cap:Int)
{
    if (i < cap)
    {
        if (starGrp.members[i].color != 0xFFFCDD03)
        {
            starGrp.members[i].y -= 20;
            FlxTween.tween(starGrp.members[i], {y: starGrp.members[i].y + 20}, 0.25, {ease: FlxEase.sineOut});
        }
        starGrp.members[i].color = 0xFFFCDD03;
    }
    else
    {
        starGrp.members[i].color = 0xFFFFFFFF;
    }
}

function onEvent(ev,v1,v2,st) {
    if (ev == '') {
        if (v1 == 'ead') {
            extraAdd = Std.parseFloat(v2);
        }

        if (v1 == 'zzz') {
            new FlxTimer().start(0.05, function(tmr:FlxTimer) {
                FlxTween.tween(FlxG.camera,{zoom: FlxG.camera.zoom + 0.4},0.6, {ease: FlxEase.circInOut, onComplete:
                    function (twn:FlxTween){game.defaultCamZoom = FlxG.camera.zoom;}});
                });
        }
        if (v1 == 'endf') {
            blackScreen.alpha = 1;
        }
        if (v1 == 'end') {
            end();
        }
    }


}

function end() {
    FlxFlicker.flicker(ending, 0, 0.2, false, true, function(flk:FlxFlicker) {});
}

function onStepHit() {
	switch (curStep) {
        case 64: 
            beatsPerZoom = 2;
        case 896: 
            beatsPerZoom = 1;
        case 1152: 
            beatsPerZoom = 2222222222222222;
        case 1168: 
            beatsPerZoom = 1;
    }
}