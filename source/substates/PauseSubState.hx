package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.addons.transition.FlxTransitionableState;

import flixel.util.FlxStringUtil;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;

class PauseSubState extends MusicBeatSubstate
{
	var thinger:FlxSprite;
	var grpMenuShit:FlxTypedGroup<FlxSprite>;

	var menuItems:Array<String> = ['resume', 'options', 'restart', 'exit'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	public static var songName:String = null;

	override function create()
	{
		pauseMusic = new FlxSound();
		try
		{
			var pauseSong:String = getPauseSong();
			if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		}
		catch(e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		thinger = new FlxSprite().loadGraphic(Paths.image('menu/pause/pmbg'));
		thinger.setGraphicSize(FlxG.width + 240, FlxG.height);
		add(thinger);
		thinger.updateHitbox();
		thinger.x -= thinger.width;

		grpMenuShit = new FlxTypedGroup<FlxSprite>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var item:FlxSprite = new FlxSprite(44 + i, i - 20);
			item.frames = Paths.getSparrowAtlas('menu/pause/' + menuItems[i]);
			item.animation.addByPrefix('idle', 'pm_' + menuItems[i] + "i", 24);
			item.animation.addByPrefix('selected', 'pm_' + menuItems[i] + "c", 24);
			item.animation.play('idle');
			item.scale.set(1.5, 1.5);
			item.updateHitbox();
			item.ID = i;
			grpMenuShit.add(item);

			item.y += item.height;
			FlxTween.tween(item, {y: item.y - item.height}, 0.4, {ease: FlxEase.backOut, startDelay: (0.1 * i)});
		}

		FlxTween.tween(thinger, {x: thinger.x + thinger.width}, 0.4, {ease: FlxEase.quintOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		addVirtualPad(UP_DOWN, A);
		addVirtualPadCamera(false);

		curSelected = 0;
		changeSelection();

		super.create();
	}
	
	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if(formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if(controls.BACK)
		{
			close();
			return;
		}

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode))
		{
			switch (menuItems[curSelected])
			{
				case "resume":
					close();
				case "restart":
					restartSong();
				case 'options':
					PlayState.instance.paused = true; // For lua
					PlayState.instance.vocals.volume = 0;
					MusicBeatState.switchState(new OptionsState());
					if(ClientPrefs.data.pauseMusic != 'None')
					{
						FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
						FlxG.sound.music.time = pauseMusic.time;
					}
					OptionsState.onPlayState = true;
				case "exit":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					Mods.loadTopMod();
					if(PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else 
						MusicBeatState.switchState(new FreeplayState());

					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}

		if (virtualPad == null) //sometimes it dosent add the vpad, hopefully this fixes it
		{
			addVirtualPad(UP_DOWN, A);
			virtualPad.buttonDown.color = 0xFF00FFFF;
			virtualPad.buttonUp.color = 0xFF12FA05;
			addVirtualPadCamera(false);
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		grpMenuShit.forEach((thing) -> {
			if(thing.ID == curSelected){
				grpMenuShit.remove(thing);
				thing.animation.play('selected');
				grpMenuShit.insert(members.indexOf(thinger) + 2, thing);
			}
			else{
				grpMenuShit.remove(thing);
				thing.animation.play('idle');
				grpMenuShit.insert(members.indexOf(thinger) + 1, thing);
			}
		});
	}
}
