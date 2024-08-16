package states;

import backend.WeekData;
import backend.Highscore;

import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;
#if mobile
import mobile.states.CopyState;
#end

typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Float
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	
	public static var ignoreCopy:Bool = false;

	var blackScreen:FlxSprite;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		#if LUA_ALLOWED
        	#if (android && EXTERNAL || MEDIA)
        try {
        	#end
		Mods.pushGlobalMods();
            #if (android && EXTERNAL || MEDIA)
        } catch (e:Dynamic) {
            SUtil.showPopUp("Please create folder to\n" + #if EXTERNAL "/storage/emulated/0/." + lime.app.Application.current.meta.get('file') #else "/storage/emulated/0/Android/media/" + lime.app.Application.current.meta.get('packageName') #end + "\nPress OK to close the game", "Error!");
            Sys.exit(1);
        }
            #end
		#end

		#if mobile
		if(!CopyState.checkExistingFiles() && !ignoreCopy)
			FlxG.switchState(new CopyState());
		#end

		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = tjson.TJSON.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(#if mobile CopyState.checkExistingFiles() && #end FlxG.save.data.flashing == null && !FlashingState.leftState) {
			controls.isInSubstate = false; //idfk what's wrong
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var ourp:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxText;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		FlxG.sound.playMusic(Paths.music('title'), 1);

		Conductor.bpm = titleJSON.bpm;
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logoBl = new FlxSprite(-160, -160);
		logoBl.frames = Paths.getSparrowAtlas('menu/title/logobump');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logobump idle', 12, false);
		logoBl.animation.play('bump');
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.78));
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		ourp = new FlxSprite(FlxG.width, 0);
		ourp.loadGraphic(Paths.image('menu/title/ourp'));
		ourp.setGraphicSize(Std.int(ourp.width * 2.6));
		ourp.updateHitbox();
		ourp.screenCenter(Y);
		ourp.x -= ourp.width + 100;
		add(ourp);

		add(logoBl);

        titleText = new FlxText(-240, 600, FlxG.width,'PRESS ENTER TO BEGIN', 40);
        titleText.alignment = 'center';
		titleText.font = Paths.font("f.otf");
		titleText.alpha = 0.8;
        add(titleText);

		var vhs:FlxSprite = new FlxSprite(0, 0);
		vhs.frames = Paths.getSparrowAtlas('menu/title/VHS');
		vhs.antialiasing = ClientPrefs.data.antialiasing;
		vhs.animation.addByPrefix('loop', 'VHS', 12, true);
		vhs.animation.play('loop');
		vhs.setGraphicSize(FlxG.width + 100, FlxG.height);
		vhs.updateHitbox();
		vhs.screenCenter();
		vhs.alpha = 0.6;
		vhs.blend = LIGHTEN;
		add(vhs);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);

		skipIntro();
		initialized = true;

		Paths.clearUnusedMemory();
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if FLX_TOUCH
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
			}
			
			if(pressedEnter)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null)
			logoBl.animation.play('bump', true);
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxTween.tween(blackScreen, {alpha: 0}, 2);

			var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
			if (easteregg == null) easteregg = '';
			easteregg = easteregg.toUpperCase();
			
			skippedIntro = true;
		}
	}
}
