import sys.FileSystem;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxPoint;
import substates.GameOverSubstate;
import flixel.math.FlxBasePoint;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.text.FlxTextFormatMarkerPair;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;

//bg1
var bg;
var front;
var sparkles;
var rainback;
var rain;
var trees;
var spotlight1;
var spotlight2;

//bg2
var backbg;
var skyback;
var gradient;

//bg3
var bar;
var outside;
var door;
var lime;
var cup;
var brookesit;
var legs;

//brooke walking segment
var brookewalking;
var skywalk;
var hill;
var leaves;
var bush1;
var bush2;
var tree1;
var tree2;
var treesback;
var endingScene;
var finalPortrait;
var grace:Character;

//misc
var blackScreen;
var ongoing:Bool = false;
var fakeCam;
var isEndingCut:Bool = true;

//tweaking
var twkBg;
var scenes:Array<FlxSprite> = [];

var vhsShader; //did not work lol

var ico1Pos:FlxBasePoint; var ico2Pos:FlxBasePoint;

var fakeScore:FlxText;
var creditFrame;
var creditTxt:FlxText;

function onCreate() 
    {
        GameOverSubstate.characterName = 'brookearcade';
        game.addCharacterToList('prangethink', 1);
        game.addCharacterToList('prangesneak', 1);
        game.addCharacterToList('prangetable', 1);
        game.addCharacterToList('brookebig', 0);
        game.addCharacterToList('brookehand', 0);
        game.addCharacterToList('bfwalk', 0);
        game.addCharacterToList('gfwalk', 2);
        game.addCharacterToList('gracethink', 2);

        //brooke walking

        skywalk = new FlxSprite(0, -1300).loadGraphic(Paths.image('bgs/walking/sky'));
        skywalk.scale.set(1.5, 1.5);
        addBehindGF(skywalk);

        grace = new Character(skywalk.getMidpoint().x + 500, skywalk.getMidpoint().y - 400, 'gracesky');
        grace.alpha = 0.45;
        addBehindGF(grace);

        setVar('graceC', grace);

        hill = new FlxSprite(600, -100).loadGraphic(Paths.image('bgs/walking/hill'));
        hill.y += 450;
        hill.scale.x = 3;
        addBehindGF(hill);

        treesback = new FlxBackdrop(Paths.image('bgs/walking/treesback'), 0x01, 0);
        treesback.y += 240;
        addBehindGF(treesback);

        leaves = new FlxBackdrop(Paths.image('bgs/walking/leaves'), 0x01, 0);
        leaves.y += 240;
        addBehindGF(leaves);

        tree1 = new FlxBackdrop(Paths.image('bgs/walking/tree1'), 0x01, 0);
        addBehindGF(tree1);

        tree2 = new FlxBackdrop(Paths.image('bgs/walking/tree2'), 0x01, 0);
        tree1.y += 300;
        tree2.y += 300;
        addBehindGF(tree2);

        brookewalking = new FlxSprite(700, 1000);
        brookewalking.frames = Paths.getSparrowAtlas('bgs/walking/brookewalking');
        brookewalking.animation.addByPrefix('walk','frame', 6);
        brookewalking.animation.play('walk', true);
        addBehindGF(brookewalking);

        bush1 = new FlxBackdrop(Paths.image('bgs/walking/bush1'), 0x01, 1500);
        bush1.x -= 1550;
        addBehindGF(bush1);

        bush2 = new FlxBackdrop(Paths.image('bgs/walking/bush2'), 0x01, 700);
        bush2.x += 1550;
        bush1.y += 400;
        bush2.y += 400;
        addBehindGF(bush2);

        endingScene = new FlxSprite(0, 0);
        endingScene.frames = Paths.getSparrowAtlas('bgs/walking/ending');
        endingScene.animation.addByPrefix('idle','brookeending', 4, true);
        endingScene.animation.addByPrefix('house','house', 4, true);
        endingScene.animation.play('idle', true);
        endingScene.cameras = [camOther];
        endingScene.alpha = 0;
        addBehindGF(endingScene);

        finalPortrait = new FlxSprite(600, -100).loadGraphic(Paths.image('bgs/walking/portrait'));
        finalPortrait.cameras = [camOther];
        finalPortrait.alpha = 0;
        addBehindGF(finalPortrait);

        //bg3
        outside = new FlxSprite(100, 90).loadGraphic(Paths.image('bgs/inside/outside'));
        outside.scrollFactor.set(0.7, 0.7);
        addBehindGF(outside);
        outside.antialiasing = false;

        bar = new FlxSprite(0, 80).loadGraphic(Paths.image('bgs/inside/bar'));
        addBehindGF(bar);
        bar.antialiasing = false;

        lime = new Character(240, 167 + 80, 'lime');
        lime.playAnim('clean', true);
        lime.specialAnim = true;
        addBehindGF(lime);

        setVar('limeC', lime);

        cup = new FlxSprite(59, 158 + 80);
        cup.frames = Paths.getSparrowAtlas('bgs/inside/cup');
        cup.animation.addByPrefix('bye','byecup', 12, false);
        cup.animation.play('bye', true);
        cup.visible = false;
        cup.animation.finishCallback = (s)->{
            if (cup.visible)
                cup.kill();
        };
        lime.animation.callback = (name, frameNum, frameIndex)->{
            if (name == 'bye' && frameNum == 4){
                cup.animation.play('bye', true);
                cup.visible = true;
            }
        };
        addBehindGF(cup);

        legs = new FlxSprite(59, 158 + 80);
        legs.frames = Paths.getSparrowAtlas('bgs/inside/legs');
        legs.animation.addByPrefix('walk','walk', 18, true);
        legs.animation.play('walk', true);
        legs.visible = false;
        addBehindBF(legs);

        brookesit = new FlxSprite(472, 226 + 80);
        brookesit.frames = Paths.getSparrowAtlas('bgs/inside/sitbrooke');
        brookesit.animation.addByPrefix('sit','sit', 4, true);
        brookesit.animation.addByPrefix('drinksit','drinksit', 4, true);
        brookesit.animation.addByPrefix('drinking','drinking', 4, true);
        brookesit.animation.play('sit', true);
        brookesit.visible = false;
        addBehindGF(brookesit);

        door = new FlxSprite(0, 80).loadGraphic(Paths.image('bgs/inside/door'));
        addBehindGF(door);
        door.antialiasing = false;

        //tweak
        twkBg = new FlxSprite(0, 80).loadGraphic(Paths.image('bgs/tweaking/bg1'));
        addBehindGF(twkBg);
        twkBg.antialiasing = false;
        twkBg.visible = false;
        var fpsArray:Array<Int> = [12,12,24,12,24,12,12,10,10,14];
        for (i in 0...10){
            var spr = new FlxSprite(0, 80);
            spr.frames = Paths.getSparrowAtlas('bgs/tweaking/scene' + (i+1));
            spr.animation.addByPrefix('scene','i', fpsArray[i], false);
            spr.animation.play('scene', true);
            spr.visible = false;
            scenes.push(spr);
            addBehindGF(spr);
            
        };

        //bg2
        skyback = new FlxSprite(50, 100).loadGraphic(Paths.image('bgs/behind/bg'));
        skyback.scrollFactor.set(0.7, 0.7);
        addBehindGF(skyback);
        skyback.antialiasing = false;

        backbg = new FlxSprite(60, 150).loadGraphic(Paths.image('bgs/behind/bg1'));
        backbg.scale.set(1.5, 1.5);
        addBehindGF(backbg);
        backbg.antialiasing = false;

        gradient = new FlxSprite(60, 150).loadGraphic(Paths.image('bgs/behind/gradient'));
        gradient.scale.set(1.5, 1.5);
        addBehindGF(gradient);
        gradient.antialiasing = false;

        //bg1
        bg = new FlxSprite(0, 0).loadGraphic(Paths.image('bgs/back'));
        bg.scale.set(1.2, 1.2);
        bg.scrollFactor.set(0.7, 0.7);
        bg.updateHitbox();
        addBehindGF(bg);
        bg.antialiasing = false;
        
        front = new FlxSprite(0, 0).loadGraphic(Paths.image('bgs/front'));
        front.scale.set(1.2, 1.2);
        front.updateHitbox();
        addBehindGF(front);
        front.antialiasing = false;

        sparkles = new FlxSprite(206 - 50, 273 - 50);
        sparkles.frames = Paths.getSparrowAtlas('bgs/sparkle');
        sparkles.animation.addByPrefix('sparkle','sparkle',30);
        sparkles.animation.play('sparkle', true);
        sparkles.visible = false;
        add(sparkles);

        rainback = new FlxSprite(front.getMidpoint().x - 350, 60);
        rainback.frames = Paths.getSparrowAtlas('bgs/rain');
        rainback.animation.addByPrefix('rain','rain',30);
        rainback.animation.play('rain', true);
        rainback.scale.set(1.25, 1.25);
        rainback.updateHitbox();
        rainback.alpha = 0;
        rainback.blend = "add";
        add(rainback);

        blackScreen = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blackScreen.scrollFactor.set();

        spotlight1 = new FlxSprite(145, -15).loadGraphic(Paths.image('bgs/spotlight'));
        spotlight1.blend = "add";
        spotlight1.updateHitbox();
        add(spotlight1);
        spotlight1.antialiasing = false;

        spotlight2 = new FlxSprite(464, -15).loadGraphic(Paths.image('bgs/spotlight'));
        spotlight2.blend = "add";
        spotlight2.updateHitbox();
        spotlight1.alpha = 0;
        spotlight2.alpha = 0.3;
        spotlight2.visible = false;
        add(spotlight2);
        spotlight2.antialiasing = false;

        trees = new FlxSprite(-100, 0).loadGraphic(Paths.image('bgs/trees'));
        trees.scale.set(1.25, 1.25);
        trees.scrollFactor.set(1.4, 1.4);
        trees.updateHitbox();
        trees.alpha = 0;
        add(trees);
        trees.antialiasing = false;

        rain = new FlxSprite(front.getMidpoint().x - 500, 60);
        rain.frames = Paths.getSparrowAtlas('bgs/rain');
        rain.animation.addByPrefix('rain','rain',30);
        rain.animation.play('rain', true);
        rain.scale.set(1.5, 1.5);
        rain.updateHitbox();
        rain.alpha = 0;
        rain.blend = "add";
        rain.scrollFactor.set(1.3, 1.3);
        add(rain);
        //FlxG.camera.filtersEnabled = false;
    }

    var pizzaGrp:FlxTypedGroup; var starGrp:FlxTypedGroup;
    
    var funnyTween:FlxTween;

    function onCreatePost() {
        camHUD.alpha = 0;

        game.timeBar.visible = false;
        game.timeTxt.visible = false;
        remove(boyfriendGroup);
        insert(members.indexOf(gfGroup)+1, boyfriendGroup);
        insert(members.indexOf(boyfriendGroup)+1, blackScreen);
        dad.alpha = 0;

        fakeCam = new FlxCamera();
        fakeCam.bgColor = 0x0;
        FlxG.cameras.remove(game.camOther, false);
        FlxG.cameras.remove(game.camHUD, false);
        FlxG.cameras.remove(game.camControls, false);

        FlxG.cameras.add(fakeCam, false);
        FlxG.cameras.add(game.camHUD, false);
        FlxG.cameras.add(game.camOther, false);
        FlxG.cameras.add(game.camControls, false);

        game.healthBar.leftBar.scale.y = 0.9;
        game.healthBar.rightBar.scale.y = 0.9;

        game.healthBar.y -= 20;

        pizzaGrp = new FlxTypedGroup<FlxSprite>();
		add(pizzaGrp);

        starGrp = new FlxTypedGroup<FlxSprite>();
		insert(members.indexOf(uiGroup) + 1, starGrp);

        for(i in 0 ... 2)
        {
            var pizza = new FlxSprite(game.healthBar.x, game.healthBar.y).loadGraphic(Paths.image('ui/pizza'));
            pizza.updateHitbox();
            pizza.y -= (pizza.height / 2) - 10;
            switch(i){
                case 0:
                    pizza.x -= pizza.width / 2;
                    ico2Pos = new FlxBasePoint((pizza.x + pizza.width)-game.iconP2.width, pizza.y - 10);
                case 1:
                    pizza.x += healthBar.width - pizza.width / 2;
                    ico1Pos = new FlxBasePoint(pizza.x, pizza.y - 10);
            }
            pizza.cameras = [game.camHUD];
            pizzaGrp.add(pizza);
        }

        for(i in 0 ... 5)
        {
            var star = new FlxSprite(game.healthBar.x + (80 * i) + 40, game.healthBar.y - 10);
            star.frames = Paths.getSparrowAtlas('ui/star');
            star.animation.addByPrefix('bop','star', 24, false);
			star.animation.addByIndices('still', 'star', [19], "", 30, true);
            star.cameras = [game.camHUD];
            star.scale.set(0.8,0.8);
            starGrp.add(star); //star.animation.play('idle', true);
        }

        fakeScore = new FlxText(0, 0, null,'',48);
        fakeScore.alignment = 'center';
        fakeScore.cameras = [game.camHUD];
        add(fakeScore);

        fakeScore.font = Paths.font("DIGILF.ttf");
        fakeScore.size = 42;
        fakeScore.screenCenter();

        creditFrame = new FlxSprite().loadGraphic(Paths.image('ui/credit'));
        creditFrame.scale.set(1.5,1.5);
        creditFrame.updateHitbox();
        creditFrame.setPosition(-creditFrame.width, 40);
        creditFrame.cameras = [camOther];
        add(creditFrame);
    
        creditTxt = new FlxText(0,creditFrame.y+10,creditFrame.width);
        creditTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        creditTxt.text = "@AFTER-MIDNIGHT@\nGREGGREG\n\n@ART@\nMABOI9798\nLOSS\nYUMII\nINFRY\nLIBUR\nHEADDZO\nSTUFFY\n\n@CODING@\nPENI\nDATA\n\n@CHARTING@\nROTTY\nBROOKLYN\nDOUYHE\n\n@PORTING@\nTEDYES & PEPPY";
    
        creditTxt.applyMarkup(creditTxt.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.WHITE,true,false,0xFFCB00E5),'@'),new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.WHITE),'^^')]);
        creditTxt.x = creditFrame.x;
        creditFrame.setGraphicSize(Std.int(creditFrame.width),Std.int(creditTxt.height)+25);
        creditFrame.updateHitbox();
    
        creditTxt.cameras = [camOther];
        add(creditTxt);
    }

    function onBeatHit(){
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

        switch (curBeat){
            case 30:
                FlxTween.tween(creditTxt, {x: 10},1, {ease: FlxEase.cubeOut});
                FlxTween.tween(creditFrame, {x: 10}, 1, {ease: FlxEase.cubeOut, onComplete: function (f:FlxTween) {
                    FlxTween.tween(creditTxt, {x: -creditFrame.width},1.5, {startDelay: 1,ease: FlxEase.cubeIn});
                    FlxTween.tween(creditFrame, {x: -creditFrame.width},1.5, {startDelay: 1,ease: FlxEase.cubeIn, onComplete: function (f:FlxTween) {
                        remove(creditFrame);
                        creditFrame.destroy();
                        remove(creditTxt);
                        creditTxt.destroy();
                    }});
                }});
        }
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
    
    var panelOn:Bool = false;
    var flicker:Bool = false;
    var limesection:Bool = false;
    var forcedCharFocus:Character;
    
    function onEvent(ev,v1,v2,st) {
        if (ev == 'endingoff'){
            if (v1 == '1'){
               FlxTween.tween(game.camGame, {alpha: 0}, 1, {ease: FlxEase.sineOut});
               FlxTween.tween(game.camHUD, {alpha: 0}, 1, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween){
                   FlxTween.tween(endingScene, {alpha: 1}, 4, {ease: FlxEase.sineOut});
                }});
                endingScene.screenCenter();
                endingScene.animation.play('idle', true);
            }
            if (v1 == '2'){
                endingScene.animation.play('house', true);
            }
            if (v1 == '3'){
               FlxTween.tween(endingScene, {alpha: 0}, 6, {ease: FlxEase.sineOut});
            }
            if (v1 == '4'){
                finalPortrait.screenCenter();
                finalPortrait.scale.set(0.7, 0.7);
               FlxTween.tween(finalPortrait, {alpha: 1}, 5, {ease: FlxEase.sineOut});
            }
            if (v1 == '5'){
                finalPortrait.screenCenter();
               FlxTween.tween(finalPortrait, {alpha: 0}, 2, {ease: FlxEase.sineOut});
            }
        }
        if (ev == 'blackfadein'){
            FlxTween.tween(blackScreen, {alpha: 1}, 1, {ease: FlxEase.sineOut});
        }
        if (ev == 'blackfadeout'){
            FlxTween.tween(blackScreen, {alpha: 0}, 1, {ease: FlxEase.sineOut});
        }
        if (ev == 'limesection'){
            limesection = !limesection;
            if (!limesection) moveCam(limesection);
        }
        if (ev == 'brookecam'){
            boyfriend.animation.callback = null;
            moveCam(false);
            for (i in [rain, rainback, gradient, backbg, skyback, boyfriend, dad, gf, sparkles, outside, lime, door, bar, legs, blackScreen, brookesit, twkBg]){
                i.kill();
            }
            game.isCameraOnForcedPos = true;
            game.camFollow.setPosition(brookewalking.getMidpoint().x, brookewalking.getMidpoint().y - 200);
            FlxG.camera.snapToTarget();
            game.defaultCamZoom = 0.7;
            isEndingCut = true;
            treesback.velocity.x = 40;
            leaves.velocity.x = 40;
            tree1.velocity.x = 90;
            tree2.velocity.x = 90;
            bush1.velocity.x = 250;
            bush2.velocity.x = 250;
        }
        if (ev == 'midnCam'){
            ongoing = true;
            game.isCameraOnForcedPos = true;
            FlxTween.tween(FlxG.camera, {zoom: 2.2}, 1.85, {ease: FlxEase.sineInOut, onComplete:
                function (twn:FlxTween)
                {
                    ongoing = false;
                }
            });
            FlxTween.tween(game.camFollow, {x: 415, y: 280}, 1.7, {ease: FlxEase.cubeIn});
        }
        if (ev == 'camend'){
            game.isCameraOnForcedPos = false;
            game.defaultCamZoom = 2.5;
        }
        if (ev == 'Change Character' && v2 == 'prangealt'){
            sparkles.visible = true;
        }
        if (ev == 'Change Character' && v2 == 'prangesneak'){
            dad.cameras = [camGame];
            dad.setPosition(-81, 165 + 80);
            dad.animation.finishCallback = (s)->{
                if (s == 'spin'){
                    game.triggerEvent('Change Character', 'dad', 'prangetable');
                    dad.setPosition(196, 132 + 80);
                }
            };
            dad.animation.callback = (s)->{
                sparkles.setPosition(dad.getMidpoint().x - sparkles.width/2, dad.getMidpoint().y - sparkles.height/2);
            };
            sparkles.scale.set(1, 1);
            sparkles.cameras = [camGame];
            FlxTween.tween(dad, {x: dad.x + 212}, 13, {ease: FlxEase.linear});
        }
        if (ev == 'Change Character' && v2 == 'bfwalk'){
            boyfriend.cameras = [camGame];
            boyfriend.setPosition(637 + 100, 245 + 80);
            FlxTween.tween(boyfriend, {x: boyfriend.x - 200}, 13, {ease: FlxEase.linear});
            remove(legs);
            insert(members.indexOf(gfGroup)+1, legs);
            legs.visible = true;
        }
        if (ev == 'Change Character' && v2 == 'gfwalk'){
            gf.cameras = [camGame];
            gf.setPosition(691 + 50, 216 + 80);
            FlxTween.tween(gf, {x: gf.x - 110}, 13, {ease: FlxEase.linear});
        }
        if (ev == 'spotlight'){
            spotlight1.alpha = 0.8;
            blackScreen.alpha = 0.8;
            FlxTween.tween(spotlight1, {alpha: 0.3}, 1, {ease: FlxEase.sineOut});
            FlxTween.tween(blackScreen, {alpha: 0.4}, 1, {ease: FlxEase.sineOut});
        }
        if (ev == 'flicker'){
            flicker = !flicker;
            spotlight2.visible = flicker;
        }
        if (ev == 'Camera Follow Pos'){
            game.defaultCamZoom = 2.5;
        }
        if (ev == 'endingcut'){
            //for (i in [trees, front, bg, rainback, rain, sparkles, skyback, backbg]){
            //    i.visible = false;
            //}
        }
        if (ev == 'end'){
            remove(spotlight1);
            remove(spotlight2);
            remove(blackScreen);
        }
        if (ev == 'bgchange'){
            FlxG.sound.play(Paths.sound('spin'), 0.4);
            FlxTween.tween(FlxG.camera.flashSprite, {scaleX: -1}, getSecondTimeFromBeat(curBeat)/2, {type: FlxTween.PINGPONG, ease: FlxEase.cubeInOut, onComplete: (tw)->{
                if (tw.executions == 2) {
                    for (i in [trees, front, bg]){
                        i.visible = false;
                    }
                }
                if (tw.executions == 4) {
                    tw.cancel();
                }
            }}); 
        }
        if (ev == 'insidebar'){
            for (i in [skyback, backbg, gradient]){
                i.visible = false;
            }
            game.isCameraOnForcedPos = false;
           forcedCharFocus = null;
            game.defaultCamZoom = 2.1;
            remove(rainback);
            insert(members.indexOf(outside)+1, rainback);
            remove(rain);
            insert(members.indexOf(rainback)+1, rain);
            rainback.scrollFactor.set(0.85, 0.85);
            rain.scrollFactor.set(0.9, 0.9);
            rain.setPosition(outside.getMidpoint().x - rain.width/2, outside.getMidpoint().y - rain.height/2);
            rainback.setPosition(outside.getMidpoint().x - rainback.width/2, outside.getMidpoint().y - rainback.height/2);
            FlxG.camera.snapToTarget();
            FlxG.camera.angle = 0;
            boyfriend.alpha = 1;
            dad.alpha = 1;
            gf.alpha = 1;
            FlxTween.tween(FlxG.camera, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});
            moveCam(true);
        }
        if (ev == 'endzoom'){
            ongoing = true;
            FlxTween.tween(FlxG.camera, {zoom: 0.25}, 7, {ease: FlxEase.sineInOut, onComplete:
                function (twn:FlxTween)
                {
                    ongoing = false;
                }
            });
            FlxTween.tween(game.camFollow, {x: skywalk.getMidpoint().x - 100, y: skywalk.getMidpoint().y + 300}, 6, {ease: FlxEase.cubeInOut});
        }
        if (ev == 'Change Character' && v2 == 'prangethink'){
            ongoing = true;
            FlxTween.tween(FlxG.camera, {zoom: 1.6}, 1, {ease: FlxEase.quartInOut, onComplete:
                function (twn:FlxTween)
                {
                    ongoing = false;
                    game.defaultCamZoom = 1.6;
                }
            });
            game.isCameraOnForcedPos = true;
            game.camFollow.setPosition(backbg.getMidpoint().x, backbg.getMidpoint().y);
            FlxG.camera.snapToTarget();
            dad.cameras = [fakeCam];
            sparkles.cameras = [fakeCam];
            sparkles.scale.set(1.5, 1.5);
            sparkles.x -= 100;
            dad.setPosition(-110,100 + 500);
            FlxTween.tween(dad, {y: 160}, 1, {ease: FlxEase.quartInOut});
            forcedCharFocus = game.dad;
        }
        if (ev == 'Change Character' && v2 == 'brookebig'){
            boyfriend.cameras = [fakeCam];
            boyfriend.setPosition(320,100 + 500);
            FlxTween.tween(boyfriend, {y: 165}, 1, {ease: FlxEase.quartInOut});
        }
        if (ev == 'Change Character' && v2 == 'brookehand'){
            game.healthLoss = 0;
            blackScreen.alpha = 0;
            insert(members.indexOf(sparkles)+1, blackScreen);
            remove(boyfriendGroup);
            boyfriend.setPosition(bar.getMidpoint().x - boyfriend.width/2, bar.getMidpoint().y - boyfriend.height/2 + 200);
            FlxTween.tween(boyfriend, {y: boyfriend.y - 200}, 0.1, {ease: FlxEase.expoOut});
            boyfriend.visible = true;
            boyfriend.playAnim('shootup');
            boyfriend.animation.finishCallback = (s)->{
                if (s == 'shootup'){
                    boyfriend.playAnim('shootdown', true);
                }
                if (s == 'teleport'){
                    boyfriend.kill();
                }
            };
            boyfriend.animation.callback = (s,n,i)->{
                if (s == 'shootup' || s == 'blink' || s == 'teleport'){
                    game.vocals.volume = 1;
                }
            };
            insert(members.indexOf(blackScreen)+1, boyfriendGroup);
            game.defaultCamZoom = 2.6;
            FlxG.camera.zoom = 2.6;
            boyfriend.animation.callback = (s,n,i)->{
                if (!panelOn)
                moveCam(true, boyfriend);
            };
            FlxTween.tween(blackScreen, {alpha: 1}, 0.6, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){
                twkBg.setPosition(boyfriend.getMidpoint().x - twkBg.width/2,boyfriend.getMidpoint().y - twkBg.height/2);
                twkBg.visible = true;
                dad.kill();
                sparkles.kill();
                gf.kill();
                FlxTween.tween(blackScreen, {alpha: 0}, 0.6, {ease: FlxEase.quadOut});
            }});
            moveCam(true, boyfriend);
            FlxG.camera.snapToTarget();

            for (i in [game.iconP1, game.iconP2, fakeScore, game.scoreTxt, game.healthBar])
                FlxTween.tween(i, {alpha: 0}, 3, {ease: FlxEase.sineIn});

            for (i in pizzaGrp)
                FlxTween.tween(i, {alpha: 0}, 3, {ease: FlxEase.sineIn});

            for (i in starGrp)
                FlxTween.tween(i, {alpha: 0}, 3, {ease: FlxEase.sineIn});

            for (i in game.opponentStrums.members)
                FlxTween.tween(i, {alpha: 0}, 3, {ease: FlxEase.sineIn});
        }
        if (ev == 'Change Character' && v2 == 'gracethink'){
            gf.cameras = [fakeCam];
            gf.setPosition(340,100 + 500);
            FlxTween.tween(gf, {y: 210}, 1, {ease: FlxEase.quartInOut});
        }
        if (ev == 'insidetrans'){
            game.defaultCamZoom = 1.3;
            ongoing = true;
            FlxTween.tween(FlxG.camera, {zoom: 15, alpha: 0, angle: 360 * 3}, 0.8, {ease: FlxEase.sineIn, onComplete:
                function (twn:FlxTween)
                {
                    ongoing = false;
                    game.defaultCamZoom = 2.5;
                    FlxG.camera.angle = 0;
                }
            });
            FlxTween.tween(boyfriend, {x: boyfriend.x + 100, alpha: 0}, 0.7, {ease: FlxEase.quartInOut});
            FlxTween.tween(gf, {x: gf.x + 100, alpha: 0}, 0.7, {ease: FlxEase.quartInOut});
            FlxTween.tween(dad, {x: dad.x - 100, alpha: 0}, 0.7, {ease: FlxEase.quartInOut});
        }
        if (ev == 'limebye') lime.playAnim('bye', true); lime.specialAnim = true;
        if (ev == 'Play Animation' && v1 == 'ball' && v2 == 'bf') {
            legs.kill();
            FlxTween.tween(boyfriend, {y: 156 + 80}, 0.3, {ease: FlxEase.expoOut, onComplete: function(twn){
                FlxTween.tween(boyfriend, {y: 206 + 80}, 0.2, {ease: FlxEase.quadIn, startDelay: 0.05});
            }});
            FlxTween.tween(boyfriend, {x: 470}, 0.6, {ease: FlxEase.quadOut, onComplete: function(twn){
                boyfriend.visible = false;
                brookesit.visible = true;
                brookesit.scale.set(1.1,0.9);
                FlxTween.tween(brookesit.scale, {x: 1, y: 1},0.1);
            }});
        }
        if (ev == 'Play Animation' && v1 == 'ball' && v2 == 'gf') {
            legs.kill();
            FlxTween.tween(gf, {y: 156 + 80}, 0.3, {ease: FlxEase.expoOut, onComplete: function(twn){
                FlxTween.tween(gf, {y: 198 + 80}, 0.2, {ease: FlxEase.quadIn, startDelay: 0.05});
            }});
            FlxTween.tween(gf, {x: 586}, 0.6, {ease: FlxEase.quadOut, onComplete: function(twn){
                gf.playAnim('sit', true);
                gf.specialAnim = true;
                gf.setPosition(567, 192 + 80);
                gf.scale.set(1.1,0.9);
                FlxTween.tween(gf.scale, {x: 1, y: 1},0.1);
            }});
        }
        if (ev == 'scene'){
            var pickedScene = scenes[Std.parseInt(v1) - 1];
            
            if (pickedScene != null){
                if (pickedScene.visible) {
                    pickedScene.animation.finishCallback = null;
                    pickedScene.kill(); 
                    boyfriend.visible = true; 
                    panelOn = false; return;
                }
                panelOn = true;
                boyfriend.visible = false;
                pickedScene.setPosition(boyfriend.getMidpoint().x - pickedScene.width/2,boyfriend.getMidpoint().y - pickedScene.height/2);
                if (Std.parseInt(v1) == 7) pickedScene.setPosition(boyfriend.getMidpoint().x - pickedScene.width/2 + 25,boyfriend.getMidpoint().y - pickedScene.height/2 + 25);
                if (pickedScene.members == null){
                    pickedScene.animation.play('scene', true);
                    pickedScene.animation.finishCallback = (s)->{
                        pickedScene.destroy();
                        boyfriend.visible = true;
                        panelOn = false;
                    };
                }
                pickedScene.visible = true;
                FlxG.camera.snapToTarget();
            }
        }
        if (ev == 'drinksit'){
            brookesit.animation.play('drinksit', true);
            brookesit.offset.x = -5;
        }
        if (ev == 'drinking'){
            brookesit.animation.play('drinking', true);
        }
    }

    function getSecondTimeFromBeat(beat) {

        var ti = Conductor.beatToSeconds(beat-1);
        var real = (Conductor.beatToSeconds(beat) - ti) / 1000;
        return real;
    }
    
    function onSongStart() {
        FlxTween.tween(dad, {alpha: 1}, 5, {ease: FlxEase.cubeIn});
        FlxTween.tween(trees, {alpha: 1}, 5, {ease: FlxEase.cubeIn});
        FlxTween.tween(rainback, {alpha: 0.15}, 5, {ease: FlxEase.cubeIn});
        FlxTween.tween(rain, {alpha: 0.4}, 5, {ease: FlxEase.cubeIn});
        FlxTween.tween(blackScreen, {alpha: 0}, 10, {ease: FlxEase.cubeIn});
        FlxTween.tween(game.camHUD, {alpha: 1}, 12, {ease: FlxEase.cubeIn});

        game.isCameraOnForcedPos = true;
        game.camFollow.setPosition(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y - 30);
        ongoing = true;
        FlxTween.tween(FlxG.camera, {zoom: 2.5}, 12.5, {ease: FlxEase.sineInOut, onComplete:
            function (twn:FlxTween)
            {
                FlxTween.cancelTweensOf(FlxG.camera, ['zoom']);
                FlxG.camera.zoom = 3.5;
                game.defaultCamZoom = 3.5;
                ongoing = false;
                game.camFollow.setPosition(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);
                FlxG.camera.snapToTarget();
            }
        });
    }

    var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

    function onSpawnNote(note){
        if (note.noteType == 'Lime Sing'){
            note.noAnimation = true;
        }
    }
    
    function onSectionHit() {
        
    }
    
    function onUpdate(elapsed) {
        if (ongoing) {
            game.defaultCamZoom = FlxG.camera.zoom;
        }

        if (limesection){
            moveCam(limesection);
            limesection = !limesection;
        }
    }

    var fuckT = 0;

    function onUpdatePost(elapsed) {
        updateRatingStuff();
        
        if(ico1Pos != null)
            game.iconP1.setPosition(ico1Pos.x, ico1Pos.y);

        if(ico2Pos != null)
            game.iconP2.setPosition(ico2Pos.x, ico2Pos.y);

        game.scoreTxt.visible = false;

        if(fakeScore != null){
            fakeScore.text = "Score:\n" + game.songScore;

            if(ClientPrefs.data.downScroll)
            {
                if(ClientPrefs.data.middleScroll)
                    fakeScore.screenCenter().y -= 160;
                else
                    fakeScore.screenCenter().y += 260;
            }
            else
            {
                if(ClientPrefs.data.middleScroll)
                    fakeScore.screenCenter().y += 200;
                else
                    fakeScore.screenCenter().y -= 260;
            }
        }

        if (ongoing) {
            game.defaultCamZoom = FlxG.camera.zoom;
        }
        fakeCam.scroll.x = FlxG.camera.scroll.x;
        fakeCam.scroll.y = FlxG.camera.scroll.y;
        fakeCam.zoom = FlxG.camera.zoom;
        if (legs.visible){
            if (boyfriend.animation.curAnim.name == 'idle'){
                boyfriend.animation.curAnim.curFrame = legs.animation.curAnim.curFrame;
            }
            legs.setPosition(boyfriend.x + 20, boyfriend.y + 71);
        }

        for (lmao in 0 ... game.grpNoteSplashes.length){
            game.grpNoteSplashes.members[lmao].scale.set(0.8, 0.8);
            game.grpNoteSplashes.members[lmao].alpha = 1;
        }
    }

    function goodNoteHit(note){
        if(!note.isSustainNote)
            tweenScore();
    }

    var scoreTween:FlxTween;

    function tweenScore(){
        if(fakeScore != null){
            if(scoreTween != null) {
				scoreTween.cancel();
			}
            fakeScore.scale.x = 1.075;
            fakeScore.scale.y = 1.075;
            scoreTween = FlxTween.tween(fakeScore.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTween = null;
				}
			});
        }
    }

    var defaultCamZoomPlus;
    var lastPlus;

    function moveCam(move:Bool, ?char = lime)
    {
        if (char == null) char = lime;
        if (move){
            game.isCameraOnForcedPos = true;
            var cam_DISPLACEMENT = outside.getMidpoint();
            cam_DISPLACEMENT.set(0, 0);
            if (char.animation.curAnim != null) 
            {
                //if (char.animation.curAnim.curFrame < 3)  {
                    switch (char.animation.curAnim.name.substring(4)) {
                        case 'UP':
                            cam_DISPLACEMENT.y = -game.camOffset;
                        case 'DOWN':
                            cam_DISPLACEMENT.y = game.camOffset;
                        case 'LEFT':
                            cam_DISPLACEMENT.x = -game.camOffset;
                        case 'RIGHT':
                            cam_DISPLACEMENT.x = game.camOffset;
                    }
                //}
            }
            if (char == lime){
                trace('limetime!!!');
            }

            if (char != boyfriend){
                game.camFollow.setPosition(char.getMidpoint().x + 180, char.getMidpoint().y - 45);
            }
            else{
                game.camFollow.setPosition(455 + 193, 207 + 70);
            }

            game.camFollow.x += char.cameraPosition[0];
            game.camFollow.y += char.cameraPosition[1];

            game.camFollow.x += cam_DISPLACEMENT.x;
            game.camFollow.y += cam_DISPLACEMENT.y;

            cam_DISPLACEMENT.put();
        }else{
            game.isCameraOnForcedPos = false;
        }
    }